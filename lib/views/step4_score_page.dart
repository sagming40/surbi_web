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
          child: Column(
            mainAxisSize: MainAxisSize.min, // Column이 화면 전체 세로를 억지로 안 늘리게
            children: [
              const ScoreGauge(score: 75), // ← 테스트용 임시 고정값
              const SizedBox(height: 32), // 게이지랑 차트 사이 여백
              ShapBarChart(
                factors: [
                  ShapFactor(name: '유동인구', value: 16, maxScore: 20),
                  ShapFactor(name: '경쟁 강도', value: -10, maxScore: 15),
                  ShapFactor(name: '정책 지원 적합도', value: 18, maxScore: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
