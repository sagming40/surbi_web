// lib/widgets/step4/score_hub_panel.dart

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/score_provider.dart';
import 'package:surbi_web/widgets/step4/score_gauge.dart';
import 'package:surbi_web/widgets/step4/shap_bar_chart.dart';

// Step4-1 허브 패널 — 게이지 + 예상성과 + SHAP 카드 3종
// step4_score_page.dart(구버전)에서 추출. Step4Shell의 좌측(넓은 화면)
// 또는 상단(좁은 화면) 고정 영역으로 재사용됨
class ScoreHubPanel extends ConsumerWidget {
  const ScoreHubPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreResult = ref.watch(scoreResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCard(
            title: '종합 창업 점수',
            child: ScoreGauge(score: scoreResult.totalScore),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: '예상 성과',
            child: _buildPerformanceRow(
              predictedSales: scoreResult.predictedSales,
              closureRiskPct: scoreResult.closureRiskPct,
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: '점수 상세 분석',
            subtitle: '막대그래프를 길게 누르면 이 점수가 무엇을 뜻하는 지 볼 수 있어요',
            child: ShapBarChart(factors: scoreResult.shapFactors),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow({
    required int predictedSales,
    required double closureRiskPct,
  }) {
    final formattedSales = NumberFormat('#,###').format(predictedSales);
    final riskColor = closureRiskPct >= 30
        ? Colors.red
        : (closureRiskPct >= 15 ? Colors.orange : Colors.green);

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '예상 월 매출',
            '$formattedSales원',
            const Color(0xFF1E3A5F),
          ),
        ),
        Container(width: 1, height: 40, color: Colors.grey.shade300),
        Expanded(
          child: _buildStatItem(
            '폐업 위험도',
            '${closureRiskPct.toInt()}%',
            riskColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
          Center(child: child),
        ],
      ),
    );
  }
}
