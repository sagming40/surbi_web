// lib/widgets/step4/score_hub_panel.dart

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/score_provider.dart';
import 'package:surbi_web/widgets/common/surbi_card.dart';
import 'package:surbi_web/widgets/step4/score_gauge.dart';
import 'package:surbi_web/widgets/step4/shap_bar_chart.dart';

// Step4-1 허브 패널 — 게이지 + 예상성과 + SHAP 카드 3종
// step4_score_page.dart(구버전)에서 추출. ScoreShell의 좌측(넓은 화면) 고정
// 영역으로 재사용됨. 좁은 화면(<900px)은 2026-08-27부터 아코디언으로 갈아탐
// (score_shell.dart의 _NarrowAccordionBody 참고) — 이 파일은 그쪽에 안 쓰임.
//
// 2026-08-27 — 게이지+예상성과 부분을 ScoreOverviewHeader로 분리했다.
// 좁은 화면 아코디언(8/24 회의 지시 ④)에서 이 두 카드는 "항상 펼쳐진 요약"으로
// 재사용되고 SHAP만 접었다 펴는 섹션으로 들어가기 때문에, 이 파일(넓은 화면)의
// 3장 구성과 아코디언의 구성이 서로 달라져야 했다. 넓은 화면은 그대로 3장 다 보여준다.
class ScoreHubPanel extends ConsumerWidget {
  const ScoreHubPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreResult = ref.watch(scoreResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const ScoreOverviewHeader(),
          _buildScoreCard(
            title: '점수 상세 분석',
            subtitle: '막대그래프를 길게 누르면 이 점수가 무엇을 뜻하는 지 볼 수 있어요',
            child: ShapBarChart(factors: scoreResult.shapFactors),
          ),
        ],
      ),
    );
  }
}

/// 게이지 + 예상 성과 카드 2장 — "항상 펼쳐진 요약" 취급.
/// 넓은 화면(ScoreHubPanel)과 좁은 화면 아코디언 헤더(_NarrowAccordionBody)가
/// 이 위젯 하나를 공유한다 — 같은 이유로 같은 게 필요할 때만 공용화한다는 원칙
/// 그대로, 두 군데서 "지금 이 동네 몇 점인지"를 항상 보여줘야 해서 공유한다.
class ScoreOverviewHeader extends ConsumerWidget {
  const ScoreOverviewHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreResult = ref.watch(scoreResultProvider);

    return Column(
      children: [
        _buildScoreCard(
          title: '종합 창업 점수',
          child: ScoreGauge(score: scoreResult.totalScore),
        ),
        _buildScoreCard(
          title: '예상 성과',
          child: _PerformanceRow(
            predictedSales: scoreResult.predictedSales,
            closureRiskPct: scoreResult.closureRiskPct,
          ),
        ),
      ],
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final int predictedSales;
  final double closureRiskPct;

  const _PerformanceRow({
    required this.predictedSales,
    required this.closureRiskPct,
  });

  @override
  Widget build(BuildContext context) {
    final formattedSales = NumberFormat('#,###').format(predictedSales);
    final riskColor = closureRiskPct >= 30
        ? SurbiColors.bad
        : (closureRiskPct >= 15 ? SurbiColors.warn : SurbiColors.good);

    return Row(
      children: [
        Expanded(
          child: _StatItem(
            label: '예상 월 매출',
            value: '$formattedSales원',
            color: SurbiColors.accent,
          ),
        ),
        Container(width: 1, height: 40, color: SurbiColors.placeholderGray),
        Expanded(
          child: _StatItem(
            label: '폐업 위험도',
            value: '${closureRiskPct.toInt()}%',
            color: riskColor,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: SurbiText.label,
            color: SurbiColors.textGray,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: SurbiText.title,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// 카드 하나(제목 + 부제 + 내용) — 이 파일 전용 헬퍼.
// 위젯 클래스로 안 만든 이유 — 상태도 없고 이 파일 밖에서 재사용할 계획이 없어서다
// (아코디언 안 SHAP 섹션은 SurbiAccordionSection이 이미 제목+카드를 그려주므로
// 이 헬퍼를 또 씌우면 카드 안에 카드가 중첩된다 — score_shell.dart 쪽 참고).
Widget _buildScoreCard({
  required String title,
  String? subtitle,
  required Widget child,
}) {
  return SurbiCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: SurbiText.subtitle,
            fontWeight: FontWeight.bold,
            color: SurbiColors.accent,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: SurbiText.label,
              color: SurbiColors.textGray,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Center(child: child),
      ],
    ),
  );
}
