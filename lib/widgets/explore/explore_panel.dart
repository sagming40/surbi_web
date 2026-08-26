// lib/widgets/explore/explore_panel.dart

import 'dart:math' as math; // max — 헤더 높이 계산
import 'dart:ui' as ui; // ImageFilter — 업종 미선택 카드 블러

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';

/// 하단 시트가 지금 얼마나 펼쳐져 있는지 — 좁은 화면에서만 의미가 있다.
/// 넓은 화면(좌측 고정 패널)은 항상 [SheetLevel.max]로 취급한다.
enum SheetLevel { min, mid, max }

/// 시트가 멈춰 설 두 자리의 **콘텐츠 높이(px)**.
///
/// [mid]가 null이면 "계산으로는 정할 수 없다"는 뜻이다. ①(안내)·②(동 목록)은
/// 스크롤되는 덩어리라 "여기까지가 한 화면"이라는 자연스러운 경계가 없다.
/// 경계가 없으면 잴 것도 없으므로, 그때는 부모가 고정 비율로 처리한다.
class SheetContentHeights {
  final double min;
  final double? mid;

  const SheetContentHeights({required this.min, this.mid});
}

/// 통합 지도 화면의 패널 — 넓은 화면에서는 좌측 고정, 좁은 화면에서는 하단 시트
///
/// **선택이 어디까지 됐는지에 따라 내용이 달라진다.**
///   ① 아무것도 안 고름 → 무엇을 하는 화면인지 안내
///   ② 구만 고름       → 그 구의 행정동 목록
///   ③ 동까지 고름     → 동 요약 + 업종 선택 + 업종별 지표
///
/// **거기에 더해 [level]이 "얼마나 보여줄지"를 가른다** (2026-08-24 회의 —
/// 카카오맵 실측으로 확인).
///   min → 헤더만 (①②③ 공통)
///   mid → ③은 헤더+지역 지표+업종 드롭다운 / ①②는 전체
///   max → 전부 (업종 지표 + 점수 버튼까지)
///
/// **min이 세 상태 모두 "헤더만"인 이유** — ②는 짧지 않다. 강남구는 행정동이
/// 22개다. 목록 전체를 min의 기준으로 삼으면 동이 많은 구에서는 시트가 아예
/// 접히지 않는다. "구마다 동작이 다른 앱"이 되는 것보다는 규칙 하나가 낫다.
///
/// Riverpod은 모른다. 값과 콜백만 받는다 — ExploreTopBar와 같은 원칙.
class ExplorePanel extends StatelessWidget {
  final String? selectedGu;
  final List<Region> regionsInGu;
  final Region? selectedRegion;

  final List<Map<String, String>> categories;
  final Map<String, String>? selectedCategory;
  final ValueChanged<Map<String, String>> onCategoryChanged;

  final ValueChanged<Region> onRegionTap;
  final VoidCallback? onScoreTap;
  final ValueChanged<bool>? onMenuVisibilityChanged;
  final VoidCallback? onStepBack;
  final ScrollController? scrollController;

  /// 지금 시트가 어디까지 펼쳐져 있는지. 넓은 화면은 항상 [SheetLevel.max].
  final SheetLevel level;

  /// 이 패널이 **하단 시트 안**에 있는지. 넓은 화면의 좌측 고정 패널이면 false.
  ///
  /// 업종 드롭다운 메뉴를 어느 쪽으로 펼칠지가 [level]과 함께 여기서 갈린다.
  final bool isBottomSheet;

  const ExplorePanel({
    super.key,
    required this.selectedGu,
    required this.regionsInGu,
    required this.selectedRegion,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onRegionTap,
    required this.onScoreTap,
    required this.level,
    this.isBottomSheet = false,
    this.onMenuVisibilityChanged,
    this.onStepBack,
    this.scrollController,
  });

  // ═══════════════════════════════════════════════════════════
  // 레이아웃 상수 · 문구
  //
  // **아래 build()와 measureStops()가 이 값들을 함께 읽는다.**
  // 같은 숫자를 두 군데에 따로 적어두면, 여백 하나를 20→24로 고쳤을 때
  // 한쪽만 고쳐도 컴파일이 통과해버린다. 상수 하나를 공유하면 어긋나는 것
  // 자체가 불가능해진다. (2026-08-24 — §5 계산식의 유일한 단점이 이것이었다)
  // ═══════════════════════════════════════════════════════════

  static const EdgeInsets panelPadding = EdgeInsets.fromLTRB(20, 8, 20, 28);

  static const double _gapBeforeMetrics = 20;
  static const double _gapBeforeApiNote = 4;
  static const double _gapBeforeDivider = 24;
  static const double _dividerHeight = 1;
  static const double _gapAfterDivider = 20;
  static const double _gapBeforeDropdown = 10;

  /// ⚠️ 이 스타일은 **measureStops가 읽어 mid 높이를 계산한다.**
  ///    크기를 바꾸면 시트 높이가 따라 움직인다 — 따로 적지 않았으니 자동이다.
  static const TextStyle _pickerTitleStyle = TextStyle(
    color: SurbiColors.accent,
    fontSize: SurbiText.subtitle,
    fontWeight: FontWeight.bold,
  );

  static const String _emptyTitle = '어느 동네가 좋을까요?';
  static const String _analysisNote = 'GET /api/analysis 연동 후 실제 값이 표시됩니다';
  static const String _pickerTitle = '어떤 업종으로 창업하시나요?';

  /// 시트 **맨 아래에 고정**되는 CTA(점수 보기) 영역의 여백.
  ///
  /// 버튼을 스크롤 내용에 섞지 않는 이유 — CTA는 "언제든 누를 수 있어야 하는 것"이라
  /// 스크롤에 딸려 사라지면 안 된다. 손잡이를 ListView 밖으로 뺀 것과 같은 논리다.
  /// (2026-08-26)
  static const EdgeInsets footerPadding = EdgeInsets.fromLTRB(20, 12, 20, 20);

  /// CTA 영역이 차지하는 전체 높이 = 버튼 + 위아래 여백.
  /// 시트 높이 계산(measureStops)이 이 값을 그대로 읽는다.
  static const double footerHeight =
      _ScoreButton.height + 12 + 20; // footerPadding.vertical

  static String _regionCountSubtitle(int count) => '행정동 $count개';
  static String _guSubtitle(String guName) => '서울특별시 · $guName';

  /// CTA를 띄울 상태인가 — 동까지 골랐고, 접어둔 상태(min)가 아닐 때.
  ///
  /// min에 안 두는 이유 — min은 "지금 어디인지만 확인하는 상태"라는 정의다.
  /// 업종을 아직 안 골랐으면 비활성 회색 버튼이라, min 높이를 두 배로 키우면서
  /// 아무 일도 하지 못한다.
  bool get _hasFooter => selectedRegion != null && level != SheetLevel.min;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      controller: scrollController,
      padding: panelPadding,
      children: _contentFor(level),
    );

    // ⚠️ **트리 모양을 항상 같게 유지한다.** (2026-08-26에 데인 것)
    //
    //    예전엔 footer가 없을 때 `return list;`로 ListView를 그대로
    //    돌려줬다. 그러면 min ↔ mid를 오갈 때마다 ListView가 트리에서
    //    **자리를 옮긴다** — 루트 ↔ Column의 첫째 자식. 자리가 바뀌면
    //    Flutter는 Element를 재사용하지 못하고 통째로 다시 만드는데,
    //    그때 거기 매달려 있던 ScrollPosition도 같이 버려진다.
    //
    //    DraggableScrollableSheet의 animateTo는 바로 그 ScrollPosition 위에서
    //    돌아가는 활동(activity)이라, 위치가 버려지면 **애니메이션이
    //    한가운데서 죽는다.**
    //      · 탭  — min을 지나 mid로 가던 시트가 중간 높이에 멈췄다.
    //             단계는 가까운 곳(mid)으로 판정되니 내용은 mid인데
    //             실제 높이는 모자라 드롭다운이 잘리고 CTA만 보였다.
    //      · 드래그 — min 경계를 지나는 동안 프레임마다 같은 일이 반복돼
    //             시트가 덜덜 떨렸다.
    //
    //    그래서 자리는 늘 지키고 **내용만 비운다.**
    //    (집 구조를 바꾸는 게 아니라 방을 비워두는 것)
    //
    // ⚠️ Expanded를 쓰므로 **부모가 높이를 확정해줘야 한다.**
    //    좁은 화면은 Expanded 안, 넓은 화면은 Row(stretch) 안이라 둘 다 확정된다.
    return Column(
      children: [
        Expanded(child: list),
        if (_hasFooter)
          Padding(
            padding: footerPadding,
            child: _ScoreButton(onTap: onScoreTap),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 높이 계산 — 그리지 않고 더한다
  // ═══════════════════════════════════════════════════════════

  /// min·mid 상태의 콘텐츠 높이(px)를 **화면에 그리지 않고** 계산한다.
  ///
  /// 손잡이(SheetHandle)는 이 패널 밖이라 여기 포함되지 않는다 —
  /// 부르는 쪽이 더해야 한다.
  ///
  /// [sheetWidth]가 필요한 이유: 폭이 좁으면 글자가 줄바꿈돼 줄 수가 달라진다.
  /// 높이는 폭의 함수다.
  static SheetContentHeights measureStops({
    required BuildContext context,
    required double sheetWidth,
    required String? selectedGu,
    required int regionCountInGu,
    required Region? selectedRegion,
    required bool hasStepBack,
  }) {
    final contentWidth = sheetWidth - panelPadding.horizontal;

    // 헤더 글자는 상태마다 다르다 — _contentFor의 분기와 **같은 순서**로 읽는다.
    final String title;
    final String? subtitle;
    if (selectedGu == null) {
      title = _emptyTitle;
      subtitle = null;
    } else if (selectedRegion == null) {
      title = selectedGu;
      subtitle = _regionCountSubtitle(regionCountInGu);
    } else {
      title = selectedRegion.regionName;
      subtitle = _guSubtitle(selectedRegion.guName);
    }

    final minHeight =
        panelPadding.vertical +
        _PanelHeader.measure(
          title: title,
          subtitle: subtitle,
          hasStepBack: hasStepBack,
          maxWidth: contentWidth,
          context: context,
        );

    // mid를 계산할 수 있는 건 ③(동까지 고른 상태)뿐이다.
    if (selectedGu == null || selectedRegion == null) {
      return SheetContentHeights(min: minHeight);
    }

    final midHeight =
        minHeight +
        _gapBeforeMetrics +
        _SkeletonRow.measure(context) * 3 +
        _gapBeforeApiNote +
        _ApiNote.measure(
          _analysisNote,
          maxWidth: contentWidth,
          context: context,
        ) +
        _gapBeforeDivider +
        _dividerHeight +
        _gapAfterDivider +
        measureText(
          _pickerTitle,
          _pickerTitleStyle,
          maxWidth: contentWidth,
          context: context,
        ) +
        _gapBeforeDropdown +
        SurbiDropdown.collapsedHeight +
        // 시트 하단에 고정된 CTA. mid·max에만 있고 min에는 없다 (_hasFooter).
        footerHeight;

    return SheetContentHeights(min: minHeight, mid: midHeight);
  }

  /// 글자를 화면에 그리지 않고 "이 폭에 넣으면 몇 픽셀 높이인가"만 잰다.
  ///
  /// **왜 fontSize를 그대로 쓰면 안 되나** — `fontSize: 20`은 글자 크기지
  /// 줄 높이가 아니다. 실제 줄 높이는 폰트가 정하고, 한글은 폴백 폰트를 타서
  /// 대략 fontSize의 1.15~1.4배로 폰트마다 다르다. 게다가 폭이 좁으면
  /// 줄바꿈이 일어나 줄 수 자체가 달라진다.
  /// [TextPainter]는 그 둘을 한 번에 해결한다 — 실제로 배치해보고 결과만 준다.
  /// (옷을 입혀보는 대신 줄자로 재는 것. 2026-08-24에 실패한 Offstage 그림자가
  ///  '입혀보기'였고, 탈의실(부모 제약)이 좁아서 세 번 다 터졌다)
  ///
  /// **⚠️ 반드시 테마와 병합해서 재야 한다** (2026-08-25에 배운 것) —
  /// [Text] 위젯은 우리가 준 스타일만 쓰지 않는다. 주변 [Material]이 깔아둔
  /// `DefaultTextStyle`(= `theme.textTheme.bodyMedium`)과 **병합**해서 그린다.
  /// Material 3의 bodyMedium에는 `height: 1.43`과 `letterSpacing: 0.25`가
  /// 들어 있고, 우리 스타일에 height가 없으므로 그 1.43이 그대로 살아남는다.
  /// 즉 제목의 실제 줄 높이는 20 × 1.43 = 28.6px인데, 병합 없이 재면 폰트
  /// 기본값(약 1.17배)인 23.4px이 나와 **한 줄당 5px씩 모자란다.**
  /// 그만큼 시트가 콘텐츠보다 짧아지고, 휠로 그 몇 px이 스크롤된다.
  /// (줄자로만 재고 어깨뽕 있는 재킷 위에 입힌 셈)
  static double measureText(
    String text,
    TextStyle style, {
    required BuildContext context,
    required double maxWidth,
  }) {
    // Text 위젯이 실제로 쓰게 될 스타일을 그대로 재현한다.
    // Material은 textStyle을 따로 받지 않으면 theme.textTheme.bodyMedium을
    // DefaultTextStyle로 깔아두므로, 같은 값을 꺼내 병합하면 정확히 일치한다.
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    final painter = TextPainter(
      text: TextSpan(text: text, style: base.merge(style)),
      textDirection: TextDirection.ltr,
      // 사용자가 OS에서 글꼴을 키워뒀다면 모든 글자가 그만큼 커진다.
      // 빼먹으면 접근성 설정을 켠 사람에게만 헤더가 잘린다.
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);

    final height = painter.size.height;
    painter.dispose(); // 네이티브 자원을 쓰므로 다 쓰면 반드시 놓아준다
    return height;
  }

  // ═══════════════════════════════════════════════════════════
  // 화면 내용
  // ═══════════════════════════════════════════════════════════

  List<Widget> _contentFor(SheetLevel level) {
    if (selectedGu == null) return _emptyState(level);
    if (selectedRegion == null) return _regionListState(level);
    return _regionDetailState(level);
  }

  // ── ① 아무것도 안 고른 상태 ─────────────────────
  List<Widget> _emptyState(SheetLevel level) {
    const header = _PanelHeader(_emptyTitle);
    if (level == SheetLevel.min) return const [header];

    return const [
      header,
      SizedBox(height: 10),
      Text(
        '서울 25개 자치구 중 하나를 고르면\n그 안의 행정동을 하나씩 살펴볼 수 있어요.',
        style: TextStyle(
          color: SurbiColors.textGray,
          height: 1.7,
          fontSize: SurbiText.body,
        ),
      ),
      SizedBox(height: 24),
      _HintRow(icon: Icons.map_outlined, text: '지도에서 구역을 확인하세요'),
      SizedBox(height: 12),
      _HintRow(icon: Icons.tune_rounded, text: '위쪽 [구 선택]으로 시작합니다'),
    ];
  }

  // ── ② 구만 고른 상태 — 동 목록 ──────────────────
  List<Widget> _regionListState(SheetLevel level) {
    final header = _PanelHeader(
      selectedGu!,
      subtitle: _regionCountSubtitle(regionsInGu.length),
      onStepBack: onStepBack,
    );
    if (level == SheetLevel.min) return [header];

    return [
      header,
      const SizedBox(height: 16),
      ...regionsInGu.map(
        (region) =>
            _RegionTile(region: region, onTap: () => onRegionTap(region)),
      ),
    ];
  }

  // ── ③ 동까지 고른 상태 — level에 따라 범위가 갈린다 ──
  //
  // **계단식으로 쌓는다.** 각 단계는 "이전 단계 + 한 덩어리"다.
  // 단계마다 목록을 따로 적으면 항목 하나 고칠 때 세 군데를 고쳐야 하고,
  // 그중 하나를 빠뜨려도 컴파일은 통과한다.
  List<Widget> _regionDetailState(SheetLevel level) {
    final region = selectedRegion!;

    final header = _PanelHeader(
      region.regionName,
      subtitle: _guSubtitle(region.guName),
      onStepBack: onStepBack,
    );

    if (level == SheetLevel.min) return [header];

    // 지역 지표 — 업종과 무관하게 그 동네 자체의 성격
    final regionMetrics = [
      const SizedBox(height: _gapBeforeMetrics),
      const _SkeletonRow(label: '유동인구', widthFactor: 0.55),
      const _SkeletonRow(label: '상권변화', widthFactor: 0.35),
      const _SkeletonRow(label: '임대료', widthFactor: 0.45),
      const SizedBox(height: _gapBeforeApiNote),
      const _ApiNote(_analysisNote),
    ];

    // 업종 고르는 자리.
    //
    // **mid에 포함시킨 이유** — DraggableScrollableSheet은 시트가 max가 아닌
    // 동안에는 목록 스크롤보다 시트 확대를 항상 우선한다(applyUserOffset).
    // 즉 "mid에서 스크롤해 드롭다운까지 내려가기"는 구조적으로 불가능하다.
    // 드롭다운을 max에만 두면 업종 하나 고르려고 지도를 100% 가려야 한다.
    // 고르는 행위는 '판단' 단계이므로 지도가 보이는 mid에 있어야 맞다.
    final categoryPicker = [
      const SizedBox(height: _gapBeforeDivider),
      // 선에는 선 색을 쓴다 — placeholderGray는 '채우는 면'용이라 선으로는 진하다
      const Divider(height: _dividerHeight, color: SurbiColors.divider),
      const SizedBox(height: _gapAfterDivider),
      const Text(_pickerTitle, style: _pickerTitleStyle),
      const SizedBox(height: _gapBeforeDropdown),
      SurbiDropdown<Map<String, String>>(
        value: selectedCategory,
        hintText: '업종 선택',
        items: categories,
        labelBuilder: (category) => category['name']!,
        // 메뉴를 아래로 펼치려면 드롭다운 밑에 280px(+여백 8)가 있어야 한다.
        //
        // 시트 위끝에서 드롭다운 아래끝까지는 351px로 **고정**이다 —
        // 콘텐츠 순서가 그 거리를 정하지, 시트 크기가 정하지 않는다.
        // 그래서 아래에 남는 공간은 "시트 높이 − 351"이 되고,
        //   · mid → 시트가 379px이므로 남는 건 28px  → 위로 펼쳐야 한다
        //   · max → 시트가 화면 전체이므로 넉넉하다   → 아래로 펼친다
        // 넓은 화면 좌측 패널은 세로가 화면 전체라 항상 아래로 펼친다.
        //
        // ⚠️ 시트 영역이 약 640px보다 낮은 기기에서는 max에서도 메뉴 아래쪽이
        //    잘릴 수 있다(640 − 351 = 289 ≈ 280+8). 그때는 이 판단을
        //    level이 아니라 실제 남는 공간으로 계산해 넘겨야 한다.
        openUpward: isBottomSheet && level != SheetLevel.max,
        onMenuVisibilityChanged: onMenuVisibilityChanged,
        onChanged: onCategoryChanged,
      ),
    ];

    if (level == SheetLevel.mid) {
      return [header, ...regionMetrics, ...categoryPicker];
    }

    // max — 고른 결과(업종 지표)까지.
    // 점수 보기 버튼은 여기 없다 — 시트 하단에 고정된다 (build 참고).
    return [
      header,
      ...regionMetrics,
      ...categoryPicker,
      const SizedBox(height: 16),
      _CategoryMetrics(isLocked: selectedCategory == null),
    ];
  }
}

// ─────────────────────────────────────────────
// 조각들
// ─────────────────────────────────────────────

/// 업종이 정해져야 나오는 지표들.
///
/// 업종 미선택이면 흐리게 가리고 안내를 얹는다. 값을 '숨기는' 것이 아니라
/// **아직 계산될 수 없다는 사실**을 보여주는 것이다 —
/// 경쟁업소 수는 "이 동네의 그 업종 가게 수"라 업종 없이는 값 자체가 존재하지 않는다.
///
/// 흐린 뒤에 진짜 숫자를 깔지 않고 회색 막대를 두는 이유: 임시 숫자는
/// 개발 중에도 팀에 보여줄 때도 진짜 값으로 오해받는다.
class _CategoryMetrics extends StatelessWidget {
  final bool isLocked;

  const _CategoryMetrics({required this.isLocked});

  @override
  Widget build(BuildContext context) {
    const metrics = Column(
      children: [
        _SkeletonRow(label: '경쟁업소', widthFactor: 0.3),
        _SkeletonRow(label: '예상 월매출', widthFactor: 0.6),
        _SkeletonRow(label: '창업 점수', widthFactor: 0.25),
      ],
    );

    if (!isLocked) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [metrics, _ApiNote('GET /api/scores 연동 후 실제 값이 표시됩니다')],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: metrics,
        ),
        // 잠금 안내 — 왜 못 보는지와, 어디서 풀 수 있는지를 함께 말한다
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: SurbiColors.accent,
            ),
            SizedBox(height: 6),
            Text(
              '업종을 선택하면 볼 수 있어요',
              style: TextStyle(
                color: SurbiColors.accent,
                fontSize: SurbiText.label,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 패널 머리말 — 제목(+부제)과, 좁은 화면에서만 붙는 `‹` 되돌리기 버튼.
///
/// 제목과 부제를 한 위젯으로 묶은 이유: `‹`가 붙으면 **둘 다 오른쪽으로
/// 밀려야** 정렬이 맞는다. 따로 두면 제목만 밀리고 부제는 제자리에 남아
/// 계단처럼 어긋난다.
class _PanelHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onStepBack;

  const _PanelHeader(this.title, {this.subtitle, this.onStepBack});

  /// 버튼의 한 변. 눈에 보이는 아이콘은 26px이지만 누를 수 있는 영역은 44px —
  /// 손가락 끝은 마우스 커서만큼 정확하지 않다. (SheetHandle과 같은 원칙)
  static const double _tapSize = 44;
  static const double _gapAfterButton = 4;
  static const double _gapBetweenTexts = 6;

  /// 위 여백 8 = (버튼 44 ÷ 2) − (제목 한 줄 높이 ≈ 28 ÷ 2)
  /// 아이콘 중심과 제목 첫 줄의 중심을 같은 높이에 맞춘다
  static const double _topAlignGap = 8;

  static const TextStyle titleStyle = TextStyle(
    color: SurbiColors.accent,
    fontSize: SurbiText.title,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle subtitleStyle = TextStyle(
    color: SurbiColors.textGray,
    fontSize: SurbiText.label,
  );

  /// 이 헤더가 차지할 높이(px)를 그리지 않고 계산한다. build()와 **같은 상수**를
  /// 읽으므로, 여백이나 글자 크기를 고치면 계산식도 자동으로 따라온다.
  static double measure({
    required String title,
    String? subtitle,
    required bool hasStepBack,
    required double maxWidth,
    required BuildContext context,
  }) {
    // `‹`가 붙으면 글자가 쓸 수 있는 폭이 그만큼 줄어든다 → 줄바꿈이 더 일찍 온다
    final textWidth = hasStepBack
        ? maxWidth - _tapSize - _gapAfterButton
        : maxWidth;

    var textsHeight = ExplorePanel.measureText(
      title,
      titleStyle,
      maxWidth: textWidth,
      context: context,
    );
    if (subtitle != null) {
      textsHeight +=
          _gapBetweenTexts +
          ExplorePanel.measureText(
            subtitle,
            subtitleStyle,
            maxWidth: textWidth,
            context: context,
          );
    }

    if (!hasStepBack) return textsHeight;

    // Row는 자식 중 가장 큰 것을 따른다 — 44짜리 버튼이 글자보다 클 수 있다
    return math.max(_tapSize, _topAlignGap + textsHeight);
  }

  @override
  Widget build(BuildContext context) {
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle),
        if (subtitle != null) ...[
          const SizedBox(height: _gapBetweenTexts),
          Text(subtitle!, style: subtitleStyle),
        ],
      ],
    );

    if (onStepBack == null) return texts;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _tapSize,
          height: _tapSize,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias, // 물결 효과를 원 밖으로 안 넘치게
            child: InkWell(
              onTap: onStepBack,
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 26,
                color: SurbiColors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(width: _gapAfterButton),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: _topAlignGap),
            child: texts,
          ),
        ),
      ],
    );
  }
}

class _ApiNote extends StatelessWidget {
  final String text;
  const _ApiNote(this.text);

  /// 지역지표 라벨(label 13)보다 **한 단계 아래**다 — 이건 임시 안내 각주라
  /// 데이터보다 눈에 덜 띄어야 한다.
  /// ⚠️ measureStops가 읽어 mid 높이를 계산한다.
  static const TextStyle style = TextStyle(
    color: SurbiColors.textGray,
    fontSize: SurbiText.caption,
  );

  /// 이 문장은 폭이 좁으면 두 줄이 된다 — 그래서 maxWidth가 필요하다.
  static double measure(
    String text, {
    required double maxWidth,
    required BuildContext context,
  }) {
    return ExplorePanel.measureText(
      text,
      style,
      maxWidth: maxWidth,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) => Text(text, style: style);
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SurbiColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: SurbiColors.textGray,
              fontSize: SurbiText.label,
            ),
          ),
        ),
      ],
    );
  }
}

/// 목록의 동 한 줄
class _RegionTile extends StatelessWidget {
  final Region region;
  final VoidCallback onTap;

  const _RegionTile({required this.region, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      // 그림자는 Container가 그린다 — Material은 boxShadow를 못 받고,
      // Material(elevation:)을 쓰면 M3 surfaceTint가 배경에 덧씌워진다.
      // (SurbiCard가 Card 대신 Container를 쓰는 그 이유 그대로)
      //
      // 색은 안 준다. 흰 바탕은 아래 Material이 칠하고, 여기서는 모양(둥근
      // 사각형)만 알려주면 그 모양대로 그림자가 깔린다.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SurbiRadius.chip),
          boxShadow: SurbiShadow.row,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SurbiRadius.chip),
          child: InkWell(
            borderRadius: BorderRadius.circular(SurbiRadius.chip),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      region.regionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // 드롭다운 항목과 같은 크기 — 같은 것(동 이름)을 고르는
                      // 두 가지 방법이므로 글자가 달라 보이면 안 된다
                      style: const TextStyle(
                        color: SurbiColors.accent,
                        fontSize: SurbiText.subtitle,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: SurbiColors.placeholderGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 값이 아직 없는 지표 자리.
class _SkeletonRow extends StatelessWidget {
  final String label;
  final double widthFactor;

  const _SkeletonRow({required this.label, required this.widthFactor});

  static const double labelWidth = 84;
  static const double barHeight = 12;
  static const double bottomGap = 14;
  static const TextStyle labelStyle = TextStyle(
    color: SurbiColors.textGray,
    fontSize: SurbiText.label,
  );

  /// 한 줄이 차지하는 높이(px).
  ///
  /// 라벨을 인자로 받지 않는 이유 — 지표 라벨은 전부 같은 스타일의 한 줄짜리
  /// 한글이라 글자가 달라도 높이가 같다. 대표로 하나만 재면 충분하다.
  static double measure(BuildContext context) {
    final labelHeight = ExplorePanel.measureText(
      '유동인구',
      labelStyle,
      maxWidth: labelWidth,
      context: context,
    );
    // Row는 더 큰 쪽을 따른다 — 글자가 작아도 막대(12px)보다 낮아질 수는 없다
    return math.max(labelHeight, barHeight) + bottomGap;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: bottomGap),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: labelStyle),
          ),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: SurbiColors.placeholderGray,
                  // 막대 높이의 절반 = 양 끝이 완전한 반원.
                  // 6이라는 숫자가 아니라 '캡슐 모양'이 의도였으므로 계산식으로 적는다.
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ScoreButton({required this.onTap});

  static const double _verticalPadding = 16;

  /// 글자 한 줄의 높이 = SurbiText.body(14) × Material 3 줄높이 1.43 ≈ 20.
  ///
  /// ⚠️ 이 값은 **아래 Text의 fontSize와 짝이다.** 글자 크기를 바꾸면 여기도
  ///    바꿔야 한다. 안 바꾸면 컴파일은 통과하고 시트 높이만 조용히 어긋난다.
  ///    (그래서 아래 Text에 fontSize를 명시했다 — 예전엔 아예 안 적어
  ///     ElevatedButton 기본값 labelLarge에 얹혀 있었다)
  static const double _lineHeight = 20;

  /// 버튼 높이 = 세로 패딩 16×2 + 글자 한 줄.
  /// 시트 높이 계산(measureStops)이 이 값을 읽으므로 계산식으로 적었다.
  static const double height = _verticalPadding * 2 + _lineHeight;

  @override
  Widget build(BuildContext context) {
    final isReady = onTap != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: SurbiColors.accent,
          disabledBackgroundColor: SurbiColors.placeholderGray,
          padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SurbiRadius.pill),
          ),
        ),
        child: Text(
          'AI 창업 점수 보기 →',
          style: TextStyle(
            // 명시하지 않으면 ElevatedButton 기본값(labelLarge 14)을 탄다 —
            // 프레임워크가 정한 값에 시트 높이 계산이 얹히면 안 된다
            fontSize: SurbiText.body,
            color: isReady ? Colors.white : SurbiColors.textGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 하단 시트 손잡이 — 순수 시각 위젯.
///
/// (2026-08-24) 예전엔 이 안에 GestureDetector가 있어서 탭을 직접 받았지만,
/// 이제 손잡이가 ListView 밖으로 나오면서 explore_page.dart가
/// 탭·드래그를 모두 감싸 처리한다. 위젯은 "어떻게 생겼는지"만 알고
/// "탭하면 뭐가 일어나는지"는 모른다 (공용 위젯 원칙 — DEVLOG 8/20).
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  /// 손잡이가 차지하는 높이(px).
  ///
  /// **시트 높이 계산이 이 값을 읽는다.** 손잡이는 ExplorePanel 밖이지만
  /// 시트 안이라, 빼먹으면 min에서 헤더가 딱 이만큼 잘린다.
  static const double height = 26;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: SurbiColors.textGray,
            borderRadius: BorderRadius.circular(SurbiRadius.tiny),
          ),
        ),
      ),
    );
  }
}
