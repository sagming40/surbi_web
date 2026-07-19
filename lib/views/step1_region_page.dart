import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/providers/region_provider.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';

/// Step 1: 지역 및 카테고리 선택 화면
class Step1RegionPage extends ConsumerWidget {
  const Step1RegionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guNameList = ref.watch(guNameListProvider);
    final categories = ref.watch(categoryListProvider);
    final selection = ref.watch(regionNotifierProvider);

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
              _buildHeatmapPlaceholder(),
              const SizedBox(height: 24),
              _buildStartButton(context, selection),
            ],
          ),
        ),
      ),
    );
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
                context.push('/step2/${selection.regionCode}');
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

  /// 지역 히트맵 영역 (현재는 placeholder)
  /// TODO: districts.geom 컬럼 적재 완료 후 실제 히트맵 렌더링으로 교체 예정 (Task 4-3)
  Widget _buildHeatmapPlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: SurbiColors.placeholderGray,
        borderRadius: BorderRadius.circular(SurbiRadius.card),
      ),
      child: Center(
        child: Text(
          '히트맵 영역(Step 1)',
          style: TextStyle(
            color: SurbiColors.textGray,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 창업 카테고리 선택 버튼 목록
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
