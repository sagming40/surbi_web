import 'package:intl/intl.dart'; // 콤마 포맷용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ⭐ 추가
import 'package:surbi_web/providers/score_provider.dart'; // ⭐ 추가
import 'package:surbi_web/widgets/step4/score_gauge.dart';
import 'package:surbi_web/widgets/step4/shap_bar_chart.dart';

// ⭐ StatelessWidget → ConsumerWidget
class Step4ScorePage extends ConsumerWidget {
  final String buildingId;

  const Step4ScorePage({super.key, required this.buildingId});

  @override
  // ⭐ build 메서드에 WidgetRef ref 파라미터 추가
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ Provider에서 실제 데이터 가져오기
    final scoreResult = ref.watch(scoreResultProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA), // 은백색 배경
      appBar: AppBar(
        title: const Text(
          'AI 창업 점수',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A5F),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        // 내용 길어져도 스크롤 가능하게
        // Center 제거 SingleChildScrollView만
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── 카드 1: 종합 점수 ──
              _buildCard(
                title: '종합 창업 점수',
                // ⭐ 하드코딩 75 → scoreResult.totalScore
                child: ScoreGauge(score: scoreResult.totalScore),
              ),
              const SizedBox(height: 20),

              // ── 카드 2: 예상 성과 (신규 추가) ──
              _buildCard(
                title: '예상 성과',
                child: _buildPerformanceRow(
                  // ⭐ 하드코딩 값 → scoreResult 필드
                  predictedSales: scoreResult.predictedSales,
                  closureRiskPct: scoreResult.closureRiskPct,
                ),
              ),
              const SizedBox(height: 20),

              // ── 카드 3: 점수 상세 분석 (SHAP) ──
              _buildCard(
                title: '점수 상세 분석',
                subtitle: '막대그래프를 길게 누르면 이 점수가 무엇을 뜻하는지 볼 수 있어요',
                // ⭐ 하드코딩 리스트 → scoreResult.shapFactors
                child: ShapBarChart(factors: scoreResult.shapFactors),
              ),
              const SizedBox(height: 20),

              // AI 보고서 생성하기 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // ⚠️ Task 3-5(LLM 보고서 출력 화면) 완성 전까지 임시 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('보고서 생성 기능은 준비 중이에요 (Task 3-5)'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F), // 네이비
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'AI 보고서 생성하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
