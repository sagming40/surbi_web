import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/providers/region_provider.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';
import 'package:surbi_web/services/kakao_map_view_registry.dart'; // ⭐ 추가

/// Step 1: 지역 및 카테고리 선택 화면
class RegionSelectPage extends ConsumerWidget {
  const RegionSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guNameList = ref.watch(guNameListProvider);
    final categories = ref.watch(categoryListProvider);
    final selection = ref.watch(regionNotifierProvider);

    // ⭐ 선택 변화를 지도에 반영 (2026-08-20 — 동 선택 반응 추가)
    ref.listen<RegionSelection>(regionNotifierProvider, (previous, next) {
      // ① 구가 바뀌면 — 이전 동의 경계를 지우고, 새 구의 동 마커를 다시 찍음
      if (previous?.selectedGu != next.selectedGu) {
        clearRegionBoundaryStep1();
        addRegionMarkers(ref.read(regionsByGuProvider(next.selectedGu)));
      }

      // ② 동이 바뀌면 — 그 동의 경계를 칠하고 화면을 맞춤
      //    기존에는 동을 골라도 지도가 아무 반응이 없어, 내가 고른 동이
      //    지도의 어느 핀인지 알 수 없었음
      if (previous?.regionCode != next.regionCode && next.regionCode != null) {
        final region = _findSelectedRegion(
          ref.read(regionsByGuProvider(next.selectedGu)),
          next.regionCode,
        );
        if (region != null) focusRegionStep1(region);
      }
    });

    return Scaffold(
      backgroundColor: SurbiColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              _buildGuRegionDropdowns(ref, guNameList, selection),
              const SizedBox(height: 24),
              _buildCategoryButtons(ref, categories, selection),
              const SizedBox(height: 24),
              _buildMapArea(ref, selection, categories), // ⭐ 선택 배지 추가
              const SizedBox(height: 24),
              _buildStartButton(context, selection),
            ],
          ),
        ),
      ),
    );
  }

  /// 드롭다운 메뉴가 열려 있는 동안 Step 1 지도의 드래그·휠을 잠금 (2026-08-20 추가)
  ///
  /// 메뉴는 Flutter 오버레이, 지도는 Platform View라 휠·드래그 이벤트가 양쪽에
  /// 이중 전달돼 목록을 스크롤하면 지도가 같이 움직였다. 업소 지도와 동일한 처리이나
  /// Step 1은 지도 인스턴스가 별개(kakaoMapInstanceStep1)라 전용 함수를 쓴다.
  void _lockMapWhileMenuOpen(bool isMenuOpen) {
    setMapInteractiveStep1(!isMenuOpen);
  }

  /// regions 목록에서 code와 일치하는 Region을 찾아 반환.
  /// 없으면 null — collection 패키지의 firstOrNull 대신 기본 문법으로 직접 구현
  /// (pubspec.yaml에 collection이 정식 등록돼 있지 않아, 이 작업만으로 의존성을
  ///  새로 추가하지 않기 위한 선택)
  Region? _findSelectedRegion(List<Region> regions, String? code) {
    if (code == null) return null;
    for (final region in regions) {
      if (region.regionCode == code) return region;
    }
    return null;
  }

  /// 구 → 동 2단계 드롭다운 (커스텀 SurbiDropdown 사용)
  Widget _buildGuRegionDropdowns(
    WidgetRef ref,
    List<String> guNameList,
    RegionSelection selection,
  ) {
    final regionsInGu = ref.watch(regionsByGuProvider(selection.selectedGu));
    final selectedRegion = _findSelectedRegion(
      regionsInGu,
      selection.regionCode,
    );

    return Row(
      children: [
        Expanded(
          child: SurbiDropdown<String>(
            value: selection.selectedGu,
            hintText: '구 선택',
            items: guNameList,
            labelBuilder: (gu) => gu,
            onMenuVisibilityChanged: _lockMapWhileMenuOpen, // ⭐ 추가
            onChanged: (guName) {
              ref.read(regionNotifierProvider.notifier).selectGu(guName);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SurbiDropdown<Region>(
            value: selectedRegion,
            hintText: '동 선택',
            items: regionsInGu,
            labelBuilder: (region) => region.regionName,
            onMenuVisibilityChanged: _lockMapWhileMenuOpen, // ⭐ 추가
            onChanged: selection.selectedGu == null
                ? null
                : (region) {
                    ref
                        .read(regionNotifierProvider.notifier)
                        .selectRegion(region.regionCode);
                  },
          ),
        ),
      ],
    );
  }

  /// 분석 시작 버튼 — 지역·카테고리 모두 선택돼야 활성화
  Widget _buildStartButton(BuildContext context, RegionSelection selection) {
    final isReady =
        selection.regionCode != null && selection.categoryCode != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isReady
            ? () {
                // 새 플로우: 선택 → 지도 → 분석 → 점수
                context.push(
                  '/map/${selection.regionCode}/${selection.categoryCode}',
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: SurbiColors.accent,
          disabledBackgroundColor: SurbiColors.placeholderGray,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SurbiRadius.pill),
          ),
        ),
        child: Text(
          '분석 시작 →',
          style: TextStyle(
            color: isReady ? Colors.white : SurbiColors.textGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 지역 지도 영역 — Kakao 지도 + 현재 선택 상태 배지
  ///
  /// 2026-08-20 — 선택(구/동/업종)이 지도에 아무 흔적을 남기지 않아
  /// "내가 뭘 고른 상태인지" 알 수 없던 문제를 배지로 해소.
  /// TODO: 점수 기반 색칠 히트맵은 별도 구현 예정 (Task 4-3)
  Widget _buildMapArea(
    WidgetRef ref,
    RegionSelection selection,
    List<Map<String, String>> categories,
  ) {
    final regionsInGu = ref.watch(regionsByGuProvider(selection.selectedGu));
    final selectedRegion = _findSelectedRegion(
      regionsInGu,
      selection.regionCode,
    );

    return Container(
      width: double.infinity,
      height: 300,
      clipBehavior: Clip.antiAlias, // 모서리를 둥글게 자르되, 내부 지도까지 잘리게 함
      decoration: BoxDecoration(
        color: SurbiColors.placeholderGray,
        borderRadius: BorderRadius.circular(SurbiRadius.card),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: HtmlElementView(viewType: 'kakao-map-view-step1'),
          ),
          // 구를 고르기 전에는 표시할 내용이 없으므로 배지 자체를 띄우지 않음
          if (selection.selectedGu != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildSelectionBadge(
                selection,
                selectedRegion,
                categories,
              ),
            ),
        ],
      ),
    );
  }

  /// 지도 위 선택 상태 배지 — `서울특별시 › 마포구 › 망원1동` + 업종 칩
  ///
  /// 업소 지도(map_page)의 컨텍스트 바와 같은 형태로 맞춰, 두 화면을 오갈 때
  /// 사용자가 같은 정보를 같은 자리에서 읽도록 함.
  Widget _buildSelectionBadge(
    RegionSelection selection,
    Region? selectedRegion,
    List<Map<String, String>> categories,
  ) {
    final parts = <String>['서울특별시'];
    if (selection.selectedGu != null) parts.add(selection.selectedGu!);
    if (selectedRegion != null) parts.add(selectedRegion.regionName);

    final categoryName = _findCategoryName(categories, selection.categoryCode);

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SurbiRadius.pill),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  parts.join(' › '),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SurbiColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (categoryName != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: SurbiColors.accent,
                    borderRadius: BorderRadius.circular(SurbiRadius.pill),
                  ),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 업종 코드로 표시용 이름을 찾음. 선택 전이거나 못 찾으면 null
  String? _findCategoryName(List<Map<String, String>> categories, String? code) {
    if (code == null) return null;
    for (final category in categories) {
      if (category['code'] == code) return category['name'];
    }
    return null;
  }

  Widget _buildCategoryButtons(
    WidgetRef ref,
    List<Map<String, String>> categories,
    RegionSelection selection,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isSelected = selection.categoryCode == category['code'];

        return GestureDetector(
          onTap: () {
            ref
                .read(regionNotifierProvider.notifier)
                .selectCategory(category['code']!);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? SurbiColors.accent : Colors.white,
              borderRadius: BorderRadius.circular(SurbiRadius.chip),
              border: Border.all(
                color: isSelected
                    ? SurbiColors.accent
                    : SurbiColors.placeholderGray,
              ),
            ),
            child: Text(
              category['name']!,
              style: TextStyle(
                color: isSelected ? Colors.white : SurbiColors.textGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
