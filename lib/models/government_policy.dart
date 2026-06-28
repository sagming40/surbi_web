// lib/models/government_policy.dart

class GovernmentPolicy {
  final String id; // 지원사업 고유 ID
  final String title; // 사업명
  final String organization; // 지원 기관명 (예: '중소벤처기업부')
  final String category; // 업종 카테고리 (예: '외식업', '카페')
  final String startDate; // 신청 시작일 (예: '2026-07-01')
  final String endDate; // 신청 마감일 (예: '2026-08-31')
  final String url; // 신청 페이지 외부 링크

  const GovernmentPolicy({
    required this.id,
    required this.title,
    required this.organization,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.url,
  });

  factory GovernmentPolicy.fromJson(Map<String, dynamic> json) {
    return GovernmentPolicy(
      id: json['id'] as String,
      title: json['title'] as String,
      organization: json['organization'] as String,
      category: json['category'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      url: json['url'] as String,
    );
  }
}
