import 'package:flutter/material.dart';
import '../widgets/step4/score_gauge.dart';

class Step4ScorePage extends StatelessWidget {
  final String buildingId;

  const Step4ScorePage({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA), // 은백색 배경
      appBar: AppBar(title: const Text('AI 창업 점수')),
      body: Center(
        child: ScoreGauge(score: 75), // ← 테스트용 임시 고정값
      ),
    );
  }
}
