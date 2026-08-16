// lib/models/area_analysis.dart

/// 업종별 매출 (TOP5 차트 항목)
/// 출처: sales_stats — 행정동 × 업종 × 분기 단위
class CategorySales {
  final String categoryCode; // CS100001
  final String categoryName; // 한식음식점
  final int monthlySales; // 당월 추정매출액 (원)

  const CategorySales({
    required this.categoryCode,
    required this.categoryName,
    required this.monthlySales,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      categoryCode: json['category_code'] as String,
      categoryName: json['category'] as String,
      monthlySales: json['monthly_sales'] as int,
    );
  }
}

/// 선택한 행정동 1곳의 상권 분석 결과
/// 2026-08-16 Phase 4 — CommercialArea(여러 동네 비교용)를 대체
///   근거: 새 플로우에서 사용자가 Step 1에서 행정동을 이미 확정하므로
///         비교 대상이 존재하지 않음 (8/3 대조표 추가제안)
/// 구조는 DB팀 3.4 `GET /api/analysis` 응답 설계 기준
class AreaAnalysis {
  final String districtName; // 왕십리도선동
  final String categoryName; // 한식음식점 (선택 업종)
  final String categoryCode; // CS100001
  final String periodCode; // 20261
  final int dailyPopulation; // populations 일 합계
  final int competitorCount; // businesses COUNT (절대 개수)
  final String trendGrade; // HH/HL/LH/LL
  final String trendGradeName; // 다이나믹
  final double rentPerSqm; // 만원/㎡
  final String rentAreaName; // 왕십리 (부동산원 상권명)
  final String rentGuName; // 성동구 (자치구 단위임을 명시하기 위함)
  final List<CategorySales> topSales; // 업종별 매출 TOP5

  const AreaAnalysis({
    required this.districtName,
    required this.categoryName,
    required this.categoryCode,
    required this.periodCode,
    required this.dailyPopulation,
    required this.competitorCount,
    required this.trendGrade,
    required this.trendGradeName,
    required this.rentPerSqm,
    required this.rentAreaName,
    required this.rentGuName,
    required this.topSales,
  });
}
