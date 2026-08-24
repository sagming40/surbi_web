// lib/widgets/explore/explore_panel.dart

import 'dart:ui' as ui; // ImageFilter — 업종 미선택 카드 블러

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';

/// 통합 지도 화면의 패널 — 넓은 화면에서는 좌측 고정, 좁은 화면에서는 하단 시트
///
/// **선택이 어디까지 됐는지에 따라 내용이 달라진다.**
///   ① 아무것도 안 고름 → 무엇을 하는 화면인지 안내
///   ② 구만 고름       → 그 구의 행정동 목록
///   ③ 동까지 고름     → 동 요약 + 업종 선택 + 업종별 지표
///
/// 이 위젯은 Riverpod을 모른다. 값과 콜백만 받는다 — ExploreTopBar와 같은 원칙.
class ExplorePanel extends StatelessWidget {
  final String? selectedGu;
  final List<Region> regionsInGu;
  final Region? selectedRegion;

  /// 업종 목록·선택값 — **상단 바가 아니라 여기 있다.**
  /// 8/21 회의에서 지역 선택(구·동)과 업종 선택을 나누기로 했고,
  /// 데이터도 그렇게 갈린다: 구·동만으로 나오는 값과 업종까지 있어야 나오는 값.
  final List<Map<String, String>> categories;
  final Map<String, String>? selectedCategory;
  final ValueChanged<Map<String, String>> onCategoryChanged;

  final ValueChanged<Region> onRegionTap;

  /// `AI 창업 점수 보기` — null이면 아직 조건이 안 갖춰진 상태라 비활성
  final VoidCallback? onScoreTap;

  /// 드롭다운 메뉴가 열리고 닫힐 때 통지 (지도 스크롤 잠금용)
  final ValueChanged<bool>? onMenuVisibilityChanged;

  /// `‹` 되돌리기 — **좁은 화면에서만 넘어온다.** null이면 그리지 않는다.
  ///
  /// 상단 바에 이미 같은 버튼이 있는데 또 두는 이유는 '엄지 영역' 때문이다.
  /// 폰을 한 손으로 쥐면 엄지가 편히 닿는 곳은 화면 아래쪽이다. 그런데 조작은
  /// 전부 하단 시트에서 하면서 되돌리기만 화면 꼭대기에 있으면, 한 단계
  /// 되돌릴 때마다 폰을 고쳐 쥐어야 한다.
  ///
  /// 데스크톱에는 그 이유가 없어(마우스는 어디든 한 번에 닿는다) 넘기지 않는다.
  /// 같은 일을 하는 버튼을 둘 두는 것은 보통 나쁜 설계이고,
  /// **'물리적으로 닿기 어렵다'는 근거가 있을 때만** 정당하다.
  final VoidCallback? onStepBack;

  final ScrollController? scrollController;
  final bool showHandle;
  final VoidCallback? onHandleTap;

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
    this.onMenuVisibilityChanged,
    this.onStepBack,
    this.scrollController,
    this.showHandle = false,
    this.onHandleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        if (showHandle && onHandleTap != null) SheetHandle(onTap: onHandleTap!),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildBody(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBody() {
    if (selectedGu == null) return _emptyState();
    if (selectedRegion == null) return _regionListState();
    return _regionDetailState();
  }

  // ── ① 아무것도 안 고른 상태 ─────────────────────
  // 되돌릴 선택이 없으므로 `‹`를 넘기지 않는다 (onStepBack도 어차피 null이다)
  List<Widget> _emptyState() {
    return [
      const _PanelHeader('어느 동네가 좋을까요?'),
      const SizedBox(height: 10),
      const Text(
        '서울 25개 자치구 중 하나를 고르면\n그 안의 행정동을 하나씩 살펴볼 수 있어요.',
        style: TextStyle(color: SurbiColors.textGray, height: 1.7, fontSize: 14),
      ),
      const SizedBox(height: 24),
      const _HintRow(icon: Icons.map_outlined, text: '지도에서 구역을 확인하세요'),
      const SizedBox(height: 12),
      const _HintRow(icon: Icons.tune_rounded, text: '위쪽 [구 선택]으로 시작합니다'),
    ];
  }

  // ── ② 구만 고른 상태 — 동 목록 ──────────────────
  List<Widget> _regionListState() {
    return [
      _PanelHeader(
        selectedGu!,
        subtitle: '행정동 ${regionsInGu.length}개',
        onStepBack: onStepBack, // → 서울 전체로
      ),
      const SizedBox(height: 16),
      // 드롭다운이 '아는 곳으로 가는 지름길'이라면, 이 목록은 '훑어보다 고르는' 쪽이다.
      // 같은 선택을 두 경로로 열어두는 이유 — 사용자가 늘 목적지를 아는 건 아니다.
      ...regionsInGu.map(
        (region) =>
            _RegionTile(region: region, onTap: () => onRegionTap(region)),
      ),
    ];
  }

  // ── ③ 동까지 고른 상태 — 요약 + 업종 ────────────
  List<Widget> _regionDetailState() {
    final region = selectedRegion!;

    return [
      _PanelHeader(
        region.regionName,
        subtitle: '서울특별시 · ${region.guName}',
        onStepBack: onStepBack, // → 동 목록으로
      ),
      const SizedBox(height: 20),

      // ── 지역만 정해지면 나오는 값 ──
      // 유동인구·상권변화·임대료는 그 동네의 성질이라 업종과 무관하다.
      // 그래서 업종을 고르기 전에도 보여준다 — 오히려 업종을 고르는 근거가 된다.
      const _SkeletonRow(label: '유동인구', widthFactor: 0.55),
      const _SkeletonRow(label: '상권변화', widthFactor: 0.35),
      const _SkeletonRow(label: '임대료', widthFactor: 0.45),
      const SizedBox(height: 4),
      const _ApiNote('GET /api/analysis 연동 후 실제 값이 표시됩니다'),

      const SizedBox(height: 24),
      const Divider(height: 1, color: SurbiColors.placeholderGray),
      const SizedBox(height: 20),

      // ── 업종까지 있어야 나오는 값 ──
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
        children: [
          metrics,
          _ApiNote('GET /api/scores 연동 후 실제 값이 표시됩니다'),
        ],
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
            Icon(Icons.lock_outline_rounded, size: 20, color: SurbiColors.accent),
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
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
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

/// 하단 시트 손잡이 — 끌 수도 있고 탭할 수도 있다.
///
/// 보이는 막대는 44×4로 얇지만 누를 수 있는 영역은 24px로 잡는다.
/// **보이는 크기와 누를 수 있는 크기는 달라도 된다.**
///
/// ⚠️ 커서 모양(`MouseRegion`)은 지도 위에서 적용되지 않는다 —
/// Platform View 위에서는 hover 계열이 동작하지 않는다(2026-08-21 확인).
/// 그래서 커서에 기대지 않고 막대를 조금 굵게 그려 잡을 수 있음을 알린다.
class SheetHandle extends StatelessWidget {
  final VoidCallback onTap;

  const SheetHandle({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 투명한 여백도 탭을 받도록
      child: SizedBox(
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
      ),
    );
  }
}
