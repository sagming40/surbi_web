// lib/providers/area_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commercial_area.dart';
import '../services/mock_data.dart';

// 상권 목록 — 현재는 Mock 데이터 반환 (Task 4-4에서 API로 교체)
final areasProvider = Provider<List<CommercialArea>>((ref) {
  return MockData.areas();
});

// 선택된 상권 상태 (Step 2에서 카드 클릭하면 여기 저장)
final selectedAreaProvider = StateProvider<CommercialArea?>((ref) => null);
