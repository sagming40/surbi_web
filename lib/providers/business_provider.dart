// lib/providers/business_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';

// 업소 목록 — 임시 데이터 직접 반환 (B안 원칙)
// TODO: GET /api/businesses API 연동 후 FutureProvider로 교체 예정 (Task 4-5)
// 2026-08-16 Phase 3 — Building(건물) → Business(업소) 재정의
// 근거: DB에 buildings 테이블 없음, businesses 테이블만 존재 (3.3 [BE] 8번)
final businessesProvider = Provider<List<Business>>((ref) {
  return const [
    Business(
      bizCode: 'MA010120220806400227',
      bizName: '카페차오',
      categoryName: '카페',
      lat: 37.5563,
      lng: 126.9013,
      openStatus: '영업중',
    ),
    Business(
      bizCode: 'MA010120220806400228',
      bizName: '카페마운틴',
      categoryName: '카페',
      lat: 37.5571,
      lng: 126.9024,
      openStatus: '영업중',
    ),
    Business(
      bizCode: 'MA010120220806400229',
      bizName: '바오밥커피로스터스',
      categoryName: '카페',
      lat: 37.5549,
      lng: 126.8999,
      openStatus: '영업중',
    ),
  ];
});

// 선택된 업소 상태 (지도에서 마커 탭하면 여기 저장)
final selectedBusinessProvider = StateProvider<Business?>((ref) => null);
