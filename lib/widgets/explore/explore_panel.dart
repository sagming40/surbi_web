// lib/widgets/explore/explore_panel.dart

import 'dart:ui' as ui; // ImageFilter — 업종 미선택 카드 블러

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';

/// 하단 시트가 지금 얼마나 펼쳐져 있는지 — 좁은 화면에서만 의미가 있다.
/// 넓은 화면(좌측 고정 패널)은 항상 [SheetLevel.max]로 취급한다.
enum SheetLevel { min, mid, max }

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
///   mid → ③은 헤더+지역 지표 / ①②는 전체 (스크롤로 이어봄)
///   max → 전체
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
    this.onMenuVisibilityChanged,
    this.onStepBack,
    this.scrollController,
  });

  /// 패널 안쪽 여백. 시트 높이 계산(Step 2)에서도 이 값을 그대로 읽으므로
  /// **public**이다 — 같은 숫자를 두 군데 적으면 언젠가 어긋난다.
  static const EdgeInsets panelPadding = EdgeInsets.fromLTRB(20, 8, 20, 28);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: panelPadding,
      children: _contentFor(level),
    );
  }

  List<Widget> _contentFor(SheetLevel level) {
    if (selectedGu == null) return _emptyState(level);
    if (selectedRegion == null) return _regionListState(level);
    return _regionDetailState(level);
  }

  // ── ① 아무것도 안 고른 상태 ─────────────────────
  List<Widget> _emptyState(SheetLevel level) {
    const header = _PanelHeader('어느 동네가 좋을까요?');
    if (level == SheetLevel.min) return const [header];

    return const [
      header,
      SizedBox(height: 10),
      Text(
        '서울 25개 자치구 중 하나를 고르면\n그 안의 행정동을 하나씩 살펴볼 수 있어요.',
        style: TextStyle(
          color: SurbiColors.textGray,
          height: 1.7,
          fontSize: 14,
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
      subtitle: '행정동 ${regionsInGu.length}개',
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
  List<Widget> _regionDetailState(SheetLevel level) {
    final region = selectedRegion!;

    final header = _PanelHeader(
      region.regionName,
      subtitle: '서울특별시 · ${region.guName}',
      onStepBack: onStepBack,
    );

    if (level == SheetLevel.min) return [header];

    final regionMetrics = [
      const SizedBox(height: 20),
      const _SkeletonRow(label: '유동인구', widthFactor: 0.55),
      const _SkeletonRow(label: '상권변화', widthFactor: 0.35),
      const _SkeletonRow(label: '임대료', widthFactor: 0.45),
      const SizedBox(height: 4),
      const _ApiNote('GET /api/analysis 연동 후 실제 값이 표시됩니다'),
    ];

    if (level == SheetLevel.mid) return [header, ...regionMetrics];

    // max — 업종 선택까지 전부
    return [
      header,
      ...regionMetrics,
      const SizedBox(height: 24),
      const Divider(height: 1, color: SurbiColors.placeholderGray),
      const SizedBox(height: 20),
      const Text(
        '어떤 업종으로 창업하시나요?',
        style: TextStyle(
          color: SurbiColors.accent,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      SurbiDropdown<Map<String, String>>(
        value: selectedCategory,
        hintText: '업종 선택',
        items: categories,
        labelBuilder: (category) => category['name']!,
        onMenuVisibilityChanged: onMenuVisibilityChanged,
        onChanged: onCategoryChanged,
      ),
      const SizedBox(height: 16),
      _CategoryMetrics(isLocked: selectedCategory == null),
      const SizedBox(height: 28),
      _ScoreButton(onTap: onScoreTap),
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
                fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: SurbiColors.accent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(color: SurbiColors.textGray, fontSize: 13),
          ),
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
        const SizedBox(width: 4),
        // 위 여백 8 = (버튼 44 ÷ 2) − (제목 한 줄 높이 ≈ 28 ÷ 2)
        // 아이콘 중심과 제목 첫 줄의 중심을 같은 높이에 맞춘다
        Expanded(
          child: Padding(padding: const EdgeInsets.only(top: 8), child: texts),
        ),
      ],
    );
  }
}

class _ApiNote extends StatelessWidget {
  final String text;
  const _ApiNote(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: SurbiColors.textGray, fontSize: 12),
    );
  }
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
            style: const TextStyle(color: SurbiColors.textGray, fontSize: 13),
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
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SurbiRadius.chip),
        child: InkWell(
          borderRadius: BorderRadius.circular(SurbiRadius.chip),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    region.regionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SurbiColors.accent,
                      fontSize: 15,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(color: SurbiColors.textGray, fontSize: 13),
            ),
          ),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: SurbiColors.placeholderGray,
                  borderRadius: BorderRadius.circular(6),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SurbiRadius.pill),
          ),
        ),
        child: Text(
          'AI 창업 점수 보기 →',
          style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: SurbiColors.textGray,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
