import 'package:intl/intl.dart'; // 콤마 포맷용
import 'package:flutter/material.dart';
import 'package:surbi_web/models/score_result.dart';
import 'package:surbi_web/widgets/step4/score_gauge.dart';
import 'package:surbi_web/widgets/step4/shap_bar_chart.dart';

class Step4ScorePage extends StatelessWidget {
  final String buildingId;

  const Step4ScorePage({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA), // 은백색 배경
      appBar: AppBar(title: const Text('AI 창업 점수')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        // 내용 길어져도 스크롤 가능하게
        // Center 제거 SingleChildScrollView만
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── 카드 1: 종합 점수 ──
              _buildCard(title: '종합 창업 점수', child: const ScoreGauge(score: 75)),
              const SizedBox(height: 20),

              // ── 카드 2: 예상 성과 (신규 추가) ──
              _buildCard(
                title: '예상 성과',
                child: _buildPerformanceRow(
                  predictedSales: 8500000, // 테스트용 임시 값 (원)
                  closureRiskPct: 12.0, // 테스트용 임시 값 (%)
                ),
              ),
              const SizedBox(height: 20),

              // ── 카드 3: 점수 상세 분석 (SHAP) ──
              _buildCard(
                title: '점수 상세 분석',
                subtitle: '항목을 길게 누르면 자세한 설명을 볼 수 있어요',
                child: ShapBarChart(
                  factors: [
                    ShapFactor(name: '유동인구', value: 16, maxScore: 20),
                    ShapFactor(name: '경쟁 강도', value: -10, maxScore: 15),
                    ShapFactor(name: '정책 지원 적합도', value: 18, maxScore: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 예상 매출 / 폐업 위험도 헬퍼 함수
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
            '예상 월매출',
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

  // 카드 생성 헬퍼 함수 ㅡ 반복되는 스타일 재사용
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
            color: Colors.black.withOpacity(0.05),
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
          Center(child: child), // 게이지는 가운데 정렬, SHAP 리스트는 왼쪽 정렬 유지
        ],
      ),
    );
  }
}
