// lib/models/region.dart

class Region {
  final String regionCode; // 행정동 코드 8자리 (DB: district_code)
  final String regionName; // 행정동명 (예: '망원동')
  final String guName; // 구명 (예: '마포구')
  final double lat; // 위도 — 지도 마커 위치
  final double lng; // 경도 — 지도 마커 위치

  const Region({
    required this.regionCode,
    required this.regionName,
    required this.guName,
    required this.lat,
    required this.lng,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      regionCode: json['district_code'] as String,
      regionName: json['name'] as String,
      guName: json['gu'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
