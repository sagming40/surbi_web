// lib/providers/building_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/building.dart';
import '../services/mock_data.dart';

// 건물 목록 — 현재는 Mock 데이터 반환 (Task 4-5에서 API로 교체)
final buildingsProvider = Provider<List<Building>>((ref) {
  return MockData.buildings();
});

// 선택된 건물 상태 (Step 3에서 마커 탭하면 여기 저장)
final selectedBuildingProvider = StateProvider<Building?>((ref) => null);
