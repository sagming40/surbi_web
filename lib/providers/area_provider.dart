// lib/providers/area_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commercial_area.dart';

/// Step 2 화면에서 보여줄 상권(행정동) 분석 결과 목록
/// TODO: GET /areas?region={code}&category={cat} API 연동 후
///   FutureProvider로 교체 예정 (Task 4-4)
final areasProvider = Provider<List<CommercialArea>>((ref) {
  return const [
    CommercialArea(
      regionCode: '1114013600',
      regionName: '마포구 망원동',
      score: 78.5,
      footTraffic: 15200,
      competitionRate: 0.42,
      closureRisk: 0.23,
      lat: 37.5558,
      lng: 126.9062,
    ),
    CommercialArea(
      regionCode: '1121510700',
      regionName: '광진구 화양동',
      score: 65.2,
      footTraffic: 11800,
      competitionRate: 0.58,
      closureRisk: 0.34,
      lat: 37.5459,
      lng: 127.0700,
    ),
    CommercialArea(
      regionCode: '1150010600',
      regionName: '강서구 화곡동',
      score: 52.7,
      footTraffic: 8600,
      competitionRate: 0.65,
      closureRisk: 0.47,
      lat: 37.5412,
      lng: 126.8497,
    ),
  ];
});

/// 선택된 상권 상태 (Step 2에서 카드 클릭하면 여기 저장 → Step 3으로 전달)
final selectedAreaProvider = StateProvider<CommercialArea?>((ref) => null);
