// lib/widgets/explore/explore_top_bar.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';

/// 통합 지도 화면의 상단 바 — `[‹] [구▾] [동▾]`
///
/// **업종 드롭다운은 여기 없다.** 8/21 회의에서 지역 선택(구·동)과 업종 선택을
/// 나누기로 결정했고, 이는 데이터 구조와도 맞다 —
///   · 구·동만으로 나오는 것: 유동인구 · 상권변화 · 임대료 · 매출 TOP5
///   · 업종까지 있어야 나오는 것: 점수 · 경쟁업소 수 · 예상매출
/// 업종은 동을 고른 뒤 열리는 패널에서 선택한다 (Step 1-C).
///
/// 이 위젯은 Riverpod을 모른다. 값과 콜백만 받아, 지역 선택 UI가 필요한
/// 다른 화면에서도 그대로 쓸 수 있게 한다.
class ExploreTopBar extends StatelessWidget {
  final List<String> guNameList;
  final List<Region> regionsInGu;
  final String? selectedGu;
  final Region? selectedRegion;

  final ValueChanged<String> onGuChanged;
  final ValueChanged<Region> onRegionChanged;

  /// `‹` 버튼 — null이면 되돌릴 선택이 없다는 뜻이라 회색으로 비활성 처리된다.
  final VoidCallback? onStepBack;

  /// 드롭다운 메뉴가 열리고 닫힐 때 통지 (지도 스크롤 잠금용)
  final ValueChanged<bool>? onMenuVisibilityChanged;

  const ExploreTopBar({
    super.key,
    required this.guNameList,
    required this.regionsInGu,
    required this.selectedGu,
    required this.selectedRegion,
    required this.onGuChanged,
    required this.onRegionChanged,
    required this.onStepBack,
    this.onMenuVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canStepBack = onStepBack != null;

    return Container(
      color: SurbiColors.primary,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Row(
        children: [
          // ‹ — 화면을 나가는 것이 아니라 선택을 한 단계 되돌린다
          //     (동 있으면 동 해제 → 구만 있으면 구 해제 → 없으면 비활성)
          IconButton(
            onPressed: onStepBack,
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            color: SurbiColors.accent,
            disabledColor: SurbiColors.placeholderGray,
            tooltip: canStepBack ? '이전 단계로' : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SurbiDropdown<String>(
              value: selectedGu,
              hintText: '구 선택',
              items: guNameList,
              labelBuilder: (gu) => gu,
              onMenuVisibilityChanged: onMenuVisibilityChanged,
              onChanged: onGuChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SurbiDropdown<Region>(
              value: selectedRegion,
              hintText: '동 선택',
              items: regionsInGu,
              labelBuilder: (region) => region.regionName,
              onMenuVisibilityChanged: onMenuVisibilityChanged,
              // 구를 고르기 전에는 고를 동이 없으므로 잠근다
              onChanged: selectedGu == null ? null : onRegionChanged,
            ),
          ),
        ],
      ),
    );
  }
}
