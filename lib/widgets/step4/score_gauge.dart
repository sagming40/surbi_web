import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

class ScoreGauge extends StatelessWidget {
  final double score; // 0 ~ 100 사이 점수
  final double size; // 게이지 전체 지름 크기 (지름)

  const ScoreGauge({super.key, required this.score, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(score: score),
        child: Center(
          child: Text(
            score.toInt().toString(),
            style: const TextStyle(
              fontSize: SurbiText.display,
              fontWeight: FontWeight.bold,
              color: SurbiColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;

  _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;

    // 1. 배경 트랙 (회색 도넛)
    final backgroundPaint = Paint()
      ..color = SurbiColors.placeholderGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 2. 점수만큼 채워지는 진행 바
    final progressPaint = Paint()
      ..color = _colorForScore(score)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 시작 각도: 12시 방향
      sweepAngle, // 그릴 각도(점수만큼)
      false,
      progressPaint,
    );
  }

  Color _colorForScore(double score) {
    if (score >= 70) return SurbiColors.good;
    if (score >= 50) return SurbiColors.warn;
    return SurbiColors.bad;
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
