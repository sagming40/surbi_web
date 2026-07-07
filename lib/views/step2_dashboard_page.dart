import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: areas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildAreaCard(areas[index]);
          },
        ),
      ),
    );
  }

  /// 상권 카드 한 개 (지역명 + 점수 + 유동인구/경쟁도/폐업위험도 요약)
  Widget _buildAreaCard(CommercialArea area) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
