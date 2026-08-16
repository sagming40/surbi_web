// lib/models/business.dart

class Business {
  final String bizCode; // business_code — 상가업소 고유 코드
  final String bizName; // biz_name — 상호명 (카드 제목)
  final String categoryName; // category_name — 업종 소분류명 (카드 배지)
  final double lat; // 위도 (지도 마커 위치)
  final double lng; // 경도 (지도 마커 위치)
  final String openStatus; // open_status — 영업상태 ("영업중" 등)

  const Business({
    required this.bizCode,
    required this.bizName,
    required this.categoryName,
    required this.lat,
    required this.lng,
    required this.openStatus,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      bizCode: json['business_code'] as String,
      bizName: json['biz_name'] as String,
      categoryName: json['category_name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      openStatus: json['open_status'] as String,
    );
  }
}
