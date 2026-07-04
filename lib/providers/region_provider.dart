// lib/providers/region_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Step 1 ㅡ 화면에서 사용자가 선택한 지역/카테고리 상태
class RegionSelection {
  final String? regionCode; // 선택된 지역 코드(선택 하지 않으면 null)
  final String? categoryCode; // 선택된 업종 코드(선택 하지 않으면 null)

  const RegionSelection({this.regionCode, this.categoryCode});

  RegionSelection copyWith({String? regionCode, String? categoryCode}) {
    return RegionSelection(
      regionCode: regionCode ?? this.regionCode,
      categoryCode: categoryCode ?? this.categoryCode,
    );
  }
}

/// 지역/카테고리 선택 상태를 관리하는 Notifier
class RegionNotifier extends StateNotifier<RegionSelection> {
  RegionNotifier() : super(const RegionSelection()); // 처음엔 아무것도 선택되지 않은 빈 화면

  void selectRegion(String regionCode) {
    state = state.copyWith(regionCode: regionCode);
  }

  void selectCategory(String categoryCode) {
    state = state.copyWith(categoryCode: categoryCode);
  }
}

final regionNotifierProvider =
    StateNotifierProvider<RegionNotifier, RegionSelection>((ref) {
      return RegionNotifier();
    });

/// 행정동 후보 목록 (Step 1 검색창 자동완성용)
/// TODO: GET /regions API 연동 후 FutureProvider로 교체 (Task 4-3 예정)
final districtListProvider = Provider<List<Map<String, String>>>((ref) {
  return const [
    {'code': '1114013600', 'name': '마포구 망원동'},
    {'code': '1121510700', 'name': '광진구 화양동'},
    {'code': '1150010600', 'name': '강서구 화곡동'},
    {'code': '1156010100', 'name': '영등포구 여의도동'},
  ];
});

/// 창업 카테고리 후보 목록 (Step 1 카테고리 버튼용)
/// TODO: 실제 업종 코드 체계 확정 후 categoryCode 값 교체 예정 (Task 4-2 연동)
final categoryListProvider = Provider<List<Map<String, String>>>((ref) {
  return const [
    {'code': 'CS100001', 'name': '카페'},
    {'code': 'CS200001', 'name': '치킨'},
    {'code': 'CS300001', 'name': '한식'},
    {'code': 'CS400001', 'name': '분식'},
  ];
});
