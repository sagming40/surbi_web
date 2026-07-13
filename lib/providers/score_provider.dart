// lib/providers/score_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/models/score_result.dart';
import 'package:surbi_web/models/government_policy.dart';
import 'package:surbi_web/models/report.dart';

/// AI 창업 점수 + SHAP 결과 — 임시 데이터 직접 반환 (B안 원칙)
/// TODO: GET /areas/{id}/score API 연동 후 FutureProvider로 교체 예정 (Task 4-6)
final scoreResultProvider = Provider<ScoreResult>((ref) {
  return const ScoreResult(
    totalScore: 78.5,
    predictedSales: 8500000,
    closureRiskPct: 12.0,
    shapFactors: [
      ShapFactor(name: '유동인구', value: 16, maxScore: 20),
      ShapFactor(name: '경쟁 강도', value: -10, maxScore: 15),
      ShapFactor(name: '정책 지원 적합도', value: 18, maxScore: 20),
    ],
  );
});

/// 정부 지원사업 목록 — 임시 데이터 직접 반환 (B안 원칙)
/// TODO: GET /policies API 연동 후 FutureProvider로 교체 예정 (Task 4-6)
final policiesProvider = Provider<List<GovernmentPolicy>>((ref) {
  return const [
    GovernmentPolicy(
      id: 'temp_policy_001',
      title: '소상공인 창업 지원 사업',
      agency: '서울신용보증재단',
      jrsdInsttNm: '중소벤처기업부',
      category: '외식업',
      summary: '초기 창업자를 위한 저금리 정책자금 및 컨설팅을 지원합니다.',
      startDate: '2026-07-03',
      endDate: '2026-08-17',
      url: 'https://www.bizinfo.go.kr',
    ),
  ];
});

/// LLM 보고서 — 임시 데이터 직접 반환 (B안 원칙)
/// TODO: POST /reports/generate, GET /reports/{id} API 연동 후 교체 예정 (Task 4-6)
final reportProvider = Provider<Report>((ref) {
  return const Report(
    reportId: 'temp_report_001',
    regionName: '망원동',
    category: '카페',
    summary: '해당 지역은 유동인구가 풍부하고 카페 업종 소비력이 높은 편입니다.',
    riskFactors: '동일 업종 경쟁이 다소 치열한 편으로, 차별화 전략이 필요합니다.',
    policyAdvice: '소상공인 창업 지원 사업 등 관련 정책자금 활용을 검토해보세요.',
    createdAt: '2026-07-10',
  );
});
