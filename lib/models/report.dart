// lib/models/report.dart

class Report {
  final String reportId; // 보고서 고유 ID
  final String regionName; // 분석 대상 행정동명
  final String category; // 창업 업종 (예: '카페', '한식')
  final String summary; // 상권 요약 텍스트 (LLM 생성)
  final String riskFactors; // 리스크 요인 텍스트 (LLM 생성)
  final String policyAdvice; // 정책 추천 텍스트 (LLM 생성)
  final String createdAt; // 보고서 생성 시각

  const Report({
    required this.reportId,
    required this.regionName,
    required this.category,
    required this.summary,
    required this.riskFactors,
    required this.policyAdvice,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['report_id'] as String,
      regionName: json['region_name'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      riskFactors: json['risk_factors'] as String,
      policyAdvice: json['policy_advice'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
