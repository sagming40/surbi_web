// lib/models/building.dart

class Building {
  final String buildingId; // 건물 고유 ID (라우팅에 사용 /step4/:buildingID)
  final String buildingName; // 건물명
  final String address; // 도로명 주소
  final double lat; // 위도 (지도 마커 위치)
  final double lng; // 경도 (지도 마커 위치)
  final double previewScore; // 미리보기 창업 점수 (BottomSheet 표시용)

  const Building({
    required this.buildingId,
    required this.buildingName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.previewScore,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      buildingId: json['building_id'] as String,
      buildingName: json['building_name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      previewScore: (json['preview_score'] as num).toDouble(),
    );
  }
}
