// lib/models/commercial_area.dart

class CommercialArea {
  final String regionCode; // 행정동 코드 — Region.regionCode와 매핑
  final String regionName; // 행정동명
  final double score; // 창업 점수 (0~100)
  final int footTraffic; // 유동인구 수 (단위: 명)
  final double competitionRate; // 경쟁도 (0.0~1.0, 높을수록 경쟁 심함)
  final double closureRisk; // 폐업 위험도 (0.0~1.0, 높을수록 위험)
  final double lat; // 위도
  final double lng; // 경도

  const CommercialArea({
    required this.regionCode,
    required this.regionName,
    required this.score,
    required this.footTraffic,
    required this.competitionRate,
    required this.closureRisk,
    required this.lat,
    required this.lng,
  });

  factory CommercialArea.fromJson(Map<String, dynamic> json) {
    return CommercialArea(
      regionCode: json['region_code'] as String,
      regionName: json['region_name'] as String,
      score: (json['score'] as num).toDouble(),
      footTraffic: json['foot_traffic'] as int,
      competitionRate: (json['competition_rate'] as num).toDouble(),
      closureRisk: (json['closure_risk'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
