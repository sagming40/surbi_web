// lib/providers/area_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/area_analysis.dart';

/// 선택한 행정동 1곳의 상권 분석 결과 — 임시 데이터 직접 반환 (B안 원칙)
/// TODO: GET /api/analysis?district_name=&category_code=&period_code= 연동 후
///   FutureProvider.family로 교체 예정 (Task 4-4)
///
/// 2026-08-16 Phase 4 — 여러 동네 비교 → 한 동네 상세로 재설계
/// 임시 데이터는 DB팀 3.2 조회 결과(왕십리도선동 20261) 실측값 기준
final areaAnalysisProvider = Provider<AreaAnalysis>((ref) {
  return const AreaAnalysis(
    districtName: '왕십리도선동',
    categoryName: '한식음식점',
    categoryCode: 'CS100001',
    periodCode: '20261',
    dailyPopulation: 497272, // 3.2 실측: 497272.3690
    competitorCount: 464, // 3.4 응답 예시 기준
    trendGrade: 'LL',
    trendGradeName: '다이나믹',
    rentPerSqm: 43.90, // 3.2 실측: 왕십리 43.90
    rentAreaName: '왕십리',
    rentGuName: '성동구',
    topSales: [
      // 3.2 실측 — 왕십리도선동 20261 매출 상위 (외식업만 추출)
      CategorySales(
        categoryCode: 'CS100001',
        categoryName: '한식음식점',
        monthlySales: 12169413866,
      ),
      CategorySales(
        categoryCode: 'CS100009',
        categoryName: '호프-간이주점',
        monthlySales: 2049903929,
      ),
      CategorySales(
        categoryCode: 'CS100010',
        categoryName: '커피-음료',
        monthlySales: 560390009,
      ),
      CategorySales(
        categoryCode: 'CS100003',
        categoryName: '일식음식점',
        monthlySales: 305903632,
      ),
      CategorySales(
        categoryCode: 'CS100002',
        categoryName: '중식음식점',
        monthlySales: 212624551,
      ),
    ],
  );
});
