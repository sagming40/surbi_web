// lib/views/analysis_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../models/area_analysis.dart';
import '../providers/area_provider.dart';
import '../widgets/common/surbi_app_bar.dart';
import '../widgets/common/surbi_card.dart';

/// 상권 분석 대시보드 — 선택한 행정동 1곳의 상세 지표
class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({
    super.key,
    required this.regionCode,
    required this.categoryCode,
  });

  final String regionCode; // 행정동 코드 (route parameter)
  final String categoryCode; // 업종 코드 (route parameter)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(areaAnalysisProvider);

    return Scaffold(
      backgroundColor: SurbiColors.primary,
      appBar: SurbiAppBar(
        title: '상권 분석',
        // 뒤로 = 지도 화면. go 통일로 스택이 없으므로 목적지를 직접 지정
        // 2026-08-23 — `/map/:동/:업종` 폐기 → 통합 화면 `/explore/:동/:업종`
        onBackPressed: () => context.go('/explore/$regionCode/$categoryCode'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(analysis),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSalesChart(analysis),
                      const SizedBox(height: 20),
                      _buildIndicators(analysis),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildScoreButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 — 지금 어느 동네·업종을 보고 있는지 + 기준 분기
  Widget _buildHeader(AreaAnalysis a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${a.districtName} · ${a.categoryName}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: SurbiColors.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_periodLabel(a.periodCode)} 기준',
          style: const TextStyle(fontSize: 13, color: SurbiColors.textGray),
        ),
      ],
    );
  }

  /// 20261 → 2026년 1분기
  String _periodLabel(String periodCode) {
    if (periodCode.length != 5) return periodCode;
    return '${periodCode.substring(0, 4)}년 ${periodCode.substring(4)}분기';
  }

  /// 업종별 매출 TOP5 — 선택 업종을 강조 색으로 표시
  Widget _buildSalesChart(AreaAnalysis a) {
    final maxSales = a.topSales.isEmpty
        ? 1
        : a.topSales.map((s) => s.monthlySales).reduce((x, y) => x > y ? x : y);

    return SurbiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 동네 업종별 매출 TOP 5',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: SurbiColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '선택한 업종이 이 동네에서 어느 위치인지 확인하세요',
            style: TextStyle(fontSize: 12, color: SurbiColors.textGray),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxSales.toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => SurbiColors.accent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = a.topSales[group.x];
                      return BarTooltipItem(
                        '${item.categoryName}\n${_salesLabel(item.monthlySales)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= a.topSales.length) {
                          return const SizedBox.shrink();
                        }
                        final isSelected =
                            a.topSales[index].categoryCode == a.categoryCode;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            a.topSales[index].categoryName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? SurbiColors.accent
                                  : SurbiColors.textGray,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: a.topSales.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = item.categoryCode == a.categoryCode;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.monthlySales.toDouble(),
                        // 선택 업종만 강조색, 나머지는 흐리게
                        color: isSelected
                            ? SurbiColors.accent
                            : SurbiColors.placeholderGray,
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 핵심 지표 4종
  Widget _buildIndicators(AreaAnalysis a) {
    return SurbiCard(
      child: Column(
        children: [
          _buildIndicatorRow(
            icon: Icons.people_outline,
            label: '유동인구',
            value: _populationLabel(a.dailyPopulation),
            note: '하루 평균',
          ),
          const Divider(height: 24),
          _buildIndicatorRow(
            icon: Icons.storefront_outlined,
            label: '경쟁 업소',
            value: '${a.competitorCount}개',
            note: '동일 업종 영업중',
          ),
          const Divider(height: 24),
          _buildIndicatorRow(
            icon: Icons.trending_up,
            label: '상권 변화',
            value: '${a.trendGradeName} (${a.trendGrade})',
            note: '서울시 상권변화지표',
          ),
          const Divider(height: 24),
          _buildIndicatorRow(
            icon: Icons.home_work_outlined,
            label: '임대료',
            value: '${a.rentPerSqm.toStringAsFixed(1)}만원/㎡',
            // ⚠️ rent_stats는 행정동이 아니라 상권명·자치구 단위 (대조표 🟢 7번)
            note: '${a.rentGuName} ${a.rentAreaName} 기준',
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow({
    required IconData icon,
    required String label,
    required String value,
    required String note,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: SurbiColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: SurbiColors.textGray,
                ),
              ),
              Text(
                note,
                style: const TextStyle(
                  fontSize: 11,
                  color: SurbiColors.textGray,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: SurbiColors.accent,
          ),
        ),
      ],
    );
  }

  /// 497272 → 49.7만명 (대조표 🟢 2번 — 자릿수 대응)
  String _populationLabel(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}만명';
    }
    return '${NumberFormat('#,###').format(count)}명';
  }

  /// 12169413866 → 121.7억
  String _salesLabel(int sales) {
    if (sales >= 100000000) {
      return '${(sales / 100000000).toStringAsFixed(1)}억';
    }
    if (sales >= 10000) {
      return '${(sales / 10000).toStringAsFixed(0)}만';
    }
    return NumberFormat('#,###').format(sales);
  }

  /// AI 창업 점수 화면으로 이동
  Widget _buildScoreButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.go('/score/$regionCode/$categoryCode');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: SurbiColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SurbiRadius.pill),
          ),
        ),
        child: const Text(
          'AI 창업 점수 보기 →',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
