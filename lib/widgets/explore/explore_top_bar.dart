// lib/widgets/explore/explore_top_bar.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/widgets/common/surbi_back_button.dart';
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
      // 상단 바는 본문보다 한 톤 밝고 아래에 얇은 선을 둔다 — SurbiAppBar와 같은 규칙
      decoration: const BoxDecoration(
        color: SurbiColors.barSurface,
        border: Border(
          bottom: BorderSide(
            color: SurbiColors.divider,
            width: SurbiBar.dividerHeight,
          ),
        ),
      ),
      // 높이를 명시한다 — SurbiAppBar와 같은 값을 읽어야 두 화면을 오갈 때
      // 바가 널뛰지 않는다. 내용(드롭다운 52)이 알아서 만드는 높이에 맡기면
      // 나중에 컨트롤을 바꿀 때 한쪽만 조용히 달라진다.
      //
      // ⚠️ height(구분선 포함) - **totalHeight**를 쓴다. 여기서는 구분선이
      //    Container의 border라 이 높이 안에 들어오기 때문이다.
      //    (SurbiAppBar는 구분선이 bottom으로 바 '밖'에 붙어 height + 1이 된다)
      //    같은 77을 서로 다른 방식으로 만들어 눈에 보이는 결과가 같아진다.
      height: SurbiBar.totalHeight,
      padding: const EdgeInsets.fromLTRB(
        SurbiBackButton.gutter,
        SurbiBar.verticalPadding,
        SurbiBar.horizontalPadding,
        SurbiBar.verticalPadding,
      ),
      child: Row(
        children: [
          // ‹ — 화면을 나가는 것이 아니라 선택을 한 단계 되돌린다
          //     (동 있으면 동 해제 → 구만 있으면 구 해제 → 없으면 비활성)
          SurbiBackButton(
            onPressed: onStepBack,
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
