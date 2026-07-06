import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../providers/region_provider.dart';

/// Step 1: 지역 및 카테고리 선택 화면
class Step1RegionPage extends ConsumerWidget {
  const Step1RegionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districts = ref.watch(districtListProvider);
    final categories = ref.watch(categoryListProvider); // ⭐ 새로 추가
    final selection = ref.watch(regionNotifierProvider); // ⭐ 새로 추가

    return Scaffold(
      backgroundColor: SurbiColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              _buildSearchField(context, ref, districts),
              const SizedBox(height: 24),
              _buildCategoryButtons(ref, categories, selection), // ⭐ 새로 추가
              const SizedBox(height: 24),
              _buildHeatmapPlaceholder(), // ⭐ 새로 추가
              const SizedBox(height: 24),
              _buildStartButton(context, selection), // ⭐ 새로 추가
            ],
          ),
        ),
      ),
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

  /// 행정동 검색 자동완성 필드
  Widget _buildSearchField(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, String>> districts,
  ) {
    return Autocomplete<Map<String, String>>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) {
          return const Iterable<Map<String, String>>.empty();
        }
        return districts.where(
          (district) => district['name']!.contains(value.text),
        );
      },
      displayStringForOption: (option) => option['name']!,
      onSelected: (Map<String, String> selection) {
        ref
            .read(regionNotifierProvider.notifier)
            .selectRegion(selection['code']!);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: '시/구/동을 검색하세요',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SurbiRadius.pill),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}
