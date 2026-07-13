import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // ⭐ 새로 추가
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../models/commercial_area.dart';
import '../providers/area_provider.dart';

/// Step 2: 선택 지역 상권 분석 대시보드
class Step2DashboardPage extends ConsumerWidget {
  const Step2DashboardPage({super.key, required this.regionCode});

  final String regionCode; // Step 1에서 넘어몬 행정동 코드 (route parameter)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areas = ref.watch(areasProvider);

    return Scaffold(
      backgroundColor: SurbiColors.primary,
      appBar: AppBar(
        backgroundColor: SurbiColors.primary,
        elevation: 0,
        title: const Text(
          '상권 분석',
          style: TextStyle(
            color: SurbiColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: SurbiColors.accent),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildFootTrafficChart(areas), // ⭐ 새로 추가
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: areas.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildAreaCard(context, ref, areas[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 지역별 유동인구 비교 막대그래프
  Widget _buildFootTrafficChart(List<CommercialArea> areas) {
    return Container(
      height: 240, // 220 → 240으로 살짝 늘림 (숫자 라벨 공간 확보)
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SurbiRadius.card),
        border: Border.all(color: SurbiColors.placeholderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지역별 유동인구 비교',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: SurbiColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20000,
                // ⭐ 막대그래프 수정
                barTouchData: BarTouchData(
                  enabled: true, // ⭐ false → true
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => SurbiColors.accent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final area = areas[group.x];
                      return BarTooltipItem(
                        '${area.regionName}\n${rod.toY.toInt()}명',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ), // ⭐ 막대그래프 수정
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
                      reservedSize: 32, // ⭐ 새로 추가 — 라벨 자리를 32픽셀로 넉넉하게 확보
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= areas.length) {
                          return const SizedBox.shrink();
                        }
                        final shortName = areas[index].regionName
                            .split(' ')
                            .last;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            shortName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: SurbiColors.textGray,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: areas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final area = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: area.footTraffic.toDouble(),
                        // ⭐ 막대그래프 수정
                        color: area.score >= 70
                            ? SurbiColors.success
                            : SurbiColors.accent, // ⭐ 점수 기준 색상 분기
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 20000,
                          color: SurbiColors.placeholderGray.withOpacity(0.3),
                          // ⭐ 막대그래프 수정
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

  /// 상권 카드 한 개 (지역명 + 점수 + 유동인구/경쟁도/폐업위험도 요약)
  Widget _buildAreaCard(
    BuildContext context,
    WidgetRef ref,
    CommercialArea area,
  ) {
    // ⭐ Material => Container가 갖고 있던 color: Colors.white 역할
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(SurbiRadius.card),
      // ⭐ GestureDetector → InkWell => UX 개선(터치감, 피드백 부재)
      child: InkWell(
        onTap: () {
          ref.read(selectedAreaProvider.notifier).state = area;
          context.push('/step3/${area.regionCode}');
        },
        borderRadius: BorderRadius.circular(SurbiRadius.card),
        splashColor: SurbiColors.accent.withOpacity(0.1),
        highlightColor: SurbiColors.accent.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SurbiRadius.card),
            border: Border.all(color: SurbiColors.placeholderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    area.regionName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SurbiColors.accent,
                    ),
                  ),
                  _buildScoreBadge(area.score),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatRow('유동인구', '${area.footTraffic}명'),
              _buildStatRow(
                '경쟁도',
                '${(area.competitionRate * 100).toStringAsFixed(0)}%',
              ),
              _buildStatRow(
                '폐업 위험도',
                '${(area.closureRisk * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 점수 배지 — 70점 이상이면 초록, 아니면 회색
  Widget _buildScoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: score >= 70 ? SurbiColors.success : SurbiColors.textGray,
        borderRadius: BorderRadius.circular(SurbiRadius.pill),
      ),
      child: Text(
        '${score.toStringAsFixed(1)}점',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 통계 한 줄 (라벨 + 값)
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: SurbiColors.textGray)),
          Text(
            value, // label → value로 수정
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
