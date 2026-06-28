// lib/providers/region_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/region.dart';
import '../services/mock_data.dart';

// 선택된 지역 코드 상태 (Step 1에서 선택하면 여기 저장)
final selectedRegionProvider = StateProvider<Region?>((ref) => null);

// 지역 목록 — 현재는 Mock 데이터 반환 (Task 4-3에서 API로 교체)
final regionsProvider = Provider<List<Region>>((ref) {
  return MockData.regions();
});
