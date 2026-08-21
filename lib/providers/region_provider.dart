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

  // ── 선택 해제 (2026-08-21 추가) ──────────────────
  //
  // 통합 화면 상단 바의 '‹'는 화면을 나가는 버튼이 아니라 **선택을 한 단계
  // 되돌려 시야를 넓히는** 버튼이다. 동이 있으면 동만, 구만 있으면 구까지 푼다.
  //
  // 업종은 두 경우 모두 유지한다 — 지역을 바꿔가며 같은 업종을 비교하는 것이
  // 이 화면의 주 사용 패턴이고, 지역을 바꿀 때마다 업종이 풀리면 히트맵을
  // 켠 채로 돌아다닐 수가 없다.
  //
  // copyWith를 쓰지 않는 이유는 selectGu와 같다 — 값을 의도적으로 null로
  // 지워야 하는데 copyWith는 null을 "안 바꿈"으로 해석한다.

  /// 동 선택만 해제 (구·업종은 유지)
  void clearRegion() {
    state = RegionSelection(
      selectedGu: state.selectedGu,
      categoryCode: state.categoryCode,
    );
  }

  /// 구·동을 모두 해제 (업종은 유지) — 서울 전체 시야로 돌아감
  void clearGu() {
    state = RegionSelection(categoryCode: state.categoryCode);
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
