// lib/providers/region_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/data/seoul_districts.dart'; // ⬅️ 추가

// ─────────────────────────────────────────────
// Step 1 화면에서 사용자가 선택한 지역/카테고리 상태
// ─────────────────────────────────────────────
class RegionSelection {
  final String? selectedGu; // ⭐ 새로 추가 — 지금 선택된 구 (동 드롭다운의 필터 기준)
  final String? regionCode; // 선택된 지역 코드(선택 하지 않으면 null)
  final String? categoryCode; // 선택된 업종 코드(선택 하지 않으면 null)

  const RegionSelection({this.selectedGu, this.regionCode, this.categoryCode});

  RegionSelection copyWith({
    String? selectedGu,
    String? regionCode,
    String? categoryCode,
  }) {
    return RegionSelection(
      selectedGu: selectedGu ?? this.selectedGu,
      regionCode: regionCode ?? this.regionCode,
      categoryCode: categoryCode ?? this.categoryCode,
    );
  }
}

/// 지역/카테고리 선택 상태를 관리하는 Notifier
class RegionNotifier extends StateNotifier<RegionSelection> {
  RegionNotifier() : super(const RegionSelection()); // 처음엔 아무것도 선택되지 않은 빈 화면

  /// 구를 선택하면 이전에 골랐던 동은 무효화
  /// copyWith 대신 직접 새로 생성하는 이유: regionCode를 의도적으로 null로 지워야 하기 때문
  void selectGu(String guName) {
    state = RegionSelection(
      selectedGu: guName,
      categoryCode: state.categoryCode, // 카테고리는 구 선택과 무관하니 유지
    );
  }

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

final regionListProvider = Provider<List<Region>>((ref) {
  return kSeoulDistricts;
});

/// 구 이름 목록만 뽑아주는 파생 Provider (중복 제거, 리스트 등장 순서 유지)
final guNameListProvider = Provider<List<String>>((ref) {
  final regions = ref.watch(regionListProvider);
  return regions.map((r) => r.guName).toSet().toList();
});

/// 선택된 구에 속한 동(Region)만 필터링해서 반환
/// guName이 null이면(구를 아직 안 골랐으면) 빈 리스트 반환
final regionsByGuProvider = Provider.family<List<Region>, String?>((
  ref,
  guName,
) {
  if (guName == null) return [];
  final regions = ref.watch(regionListProvider);
  return regions.where((r) => r.guName == guName).toList();
});

/// 창업 카테고리 후보 목록 (Step 1 카테고리 버튼용)
/// 2026-08-16 Phase 1.5 — CS코드 외식업 10종 실제값으로 교체
/// (기존 4개는 코드-이름 매칭이 전부 틀려있었음. 출처: 3.2 DB 조회 결과 정리)
/// 라벨은 DB category 컬럼명 그대로 사용 (7/7 원칙: 임의 명명 금지)
final categoryListProvider = Provider<List<Map<String, String>>>((ref) {
  return const [
    {'code': 'CS100001', 'name': '한식음식점'},
    {'code': 'CS100002', 'name': '중식음식점'},
    {'code': 'CS100003', 'name': '일식음식점'},
    {'code': 'CS100004', 'name': '양식음식점'},
    {'code': 'CS100005', 'name': '제과점'},
    {'code': 'CS100006', 'name': '패스트푸드점'},
    {'code': 'CS100007', 'name': '치킨전문점'},
    {'code': 'CS100008', 'name': '분식전문점'},
    {'code': 'CS100009', 'name': '호프-간이주점'},
    {'code': 'CS100010', 'name': '커피-음료'},
  ];
});
