// lib/models/score_result.dart

// SHAP 요인 하나 (점수에 기여한 항목 1개)
class ShapFactor {
  final String name; // 요인명 (예: '유동인구 지수')
  final double value; // 실제 기여 점수 (음수 가능 ㅡ 감점 요인)
  final double maxScore; // 해당 요인의 만점

  const ShapFactor({
    required this.name,
    required this.value,
    required this.maxScore,
  });

  factory ShapFactor.fromJson(Map<String, dynamic> json) {
    return ShapFactor(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      maxScore: (json['max_score'] as num).toDouble(),
    );
  }
}

// AI 창업 점수 전체 결과
class ScoreResult {
  final double totalScore; // 종합 창업 점수 (0~100)
  final int predictedSales; // 예상 월 매출 (단위: 원)
  final double closureRiskPct; // 폐업 위험도 (단위: %)
  final List<ShapFactor> shapFactors; // SHAP 요인 목록

  const ScoreResult({
    required this.totalScore,
    required this.predictedSales,
    required this.closureRiskPct,
    required this.shapFactors,
  });

  factory ScoreResult.fromJson(Map<String, dynamic> json) {
    return ScoreResult(
      totalScore: (json['total_score'] as num).toDouble(),
      predictedSales: json['predicted_sales'] as int,
      closureRiskPct: (json['closure_risk_pct'] as num).toDouble(),
      shapFactors: (json['shap_factors'] as List)
          .map((e) => ShapFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
