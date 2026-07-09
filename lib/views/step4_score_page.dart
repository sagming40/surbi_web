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
        child: Center(
          // 내용 길어져도 스크롤 가능하게
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Column이 화면 전체 세로를 억지로 안 늘리게
              children: [
                // ── 카드 1: 종합 점수 ──
                _buildCard(
                  title: '종합 창업 점수',
                  child: const ScoreGauge(score: 75),
                ),
                const SizedBox(height: 20),

                // ── 카드 2: 항목별 상세 분석 ──
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
              ],
            ),
          ),
        ),
      ),
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
