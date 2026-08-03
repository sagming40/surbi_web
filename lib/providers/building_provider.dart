// lib/providers/building_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/building.dart';

// 건물 목록 — 임시 데이터 직접 반환 (B안 원칙)
// TODO: GET /buildings API 연동 후 FutureProvider로 교체 예정 (Task 4-5)
final buildingsProvider = Provider<List<Building>>((ref) {
  return const [
    Building(
      buildingId: 'B001',
      buildingName: '망원동 상가빌딩 1',
      address: '서울 마포구 망원로1길 10',
      lat: 37.5563,
      lng: 126.9013,
      previewScore: 78.5,
    ),
    Building(
      buildingId: 'B002',
      buildingName: '망원동 상가빌딩 2',
      address: '서울 마포구 월드컵로 20',
      lat: 37.5571,
      lng: 126.9024,
      previewScore: 65.2,
    ),
    Building(
      buildingId: 'B003',
      buildingName: '망원동 상가빌딩 3',
      address: '서울 마포구 포은로 5',
      lat: 37.5549,
      lng: 126.8999,
      previewScore: 82.0,
    ),
  ];
});

// 선택된 건물 상태 (Step 3에서 마커 탭하면 여기 저장)
final selectedBuildingProvider = StateProvider<Building?>((ref) => null);
