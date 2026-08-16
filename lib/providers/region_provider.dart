// lib/providers/region_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/models/region.dart';

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

// ─────────────────────────────────────────────
// 서울 25개 구 + 구별 대표 동 목록 (임시 데이터)
// TODO: GET /api/districts API 연동 후 FutureProvider로 교체 예정 (Task 4-3)
//
// ⚠️ 2026-08-16 Phase 1.5 — regionCode 자릿수 오류 수정
//   기존: 10자리 법정동코드(legal_dong_code)를 8자리 행정동코드 자리에 사용
//   수정: districts.district_code(8자리) 형식으로 통일
//
//   검증 수준이 항목마다 다름:
//   ✅ 성동구 2건 — 3.2 DB 조회 결과 정리 기준 실제 코드
//   ⚠️ 나머지 23개 구 — 자치구 코드(5자리)는 3.2 문서 기준 실제값,
//      동 코드 뒷자리 3자리는 자릿수만 맞춘 임시값(실제 동 코드 아님)
//   → 어차피 Task 4-3에서 API 연동 시 이 목록 자체가 전량 교체됨
// ─────────────────────────────────────────────
final regionListProvider = Provider<List<Region>>((ref) {
  return const [
    Region(
      regionCode: '11110501', // ⚠️ 임시(자치구코드만 실제)
      regionName: '종로1.2.3.4가동',
      guName: '종로구',
      lat: 37.5730,
      lng: 126.9794,
    ),
    Region(
      regionCode: '11110630',
      regionName: '혜화동',
      guName: '종로구',
      lat: 37.5820,
      lng: 127.0016,
    ),

    Region(
      regionCode: '11140550',
      regionName: '명동',
      guName: '중구',
      lat: 37.5636,
      lng: 126.9834,
    ),
    Region(
      regionCode: '11140580',
      regionName: '신당동',
      guName: '중구',
      lat: 37.5657,
      lng: 127.0177,
    ),

    Region(
      regionCode: '11170610',
      regionName: '이태원동',
      guName: '용산구',
      lat: 37.5347,
      lng: 126.9946,
    ),
    Region(
      regionCode: '11170680',
      regionName: '한남동',
      guName: '용산구',
      lat: 37.5344,
      lng: 127.0009,
    ),

    // ✅ 성동구 — 3.2 DB 조회 결과 정리 기준 실제 행정동코드
    Region(
      regionCode: '11200535',
      regionName: '왕십리도선동',
      guName: '성동구',
      lat: 37.5613,
      lng: 127.0299,
    ),
    Region(
      regionCode: '11200650',
      regionName: '성수1가1동',
      guName: '성동구',
      lat: 37.5445,
      lng: 127.0559,
    ),

    Region(
      regionCode: '11215100',
      regionName: '화양동',
      guName: '광진구',
      lat: 37.5459,
      lng: 127.0700,
    ),
    Region(
      regionCode: '11215130',
      regionName: '건대입구',
      guName: '광진구',
      lat: 37.5407,
      lng: 127.0700,
    ),

    Region(
      regionCode: '11230610',
      regionName: '회기동',
      guName: '동대문구',
      lat: 37.5894,
      lng: 127.0567,
    ),
    Region(
      regionCode: '11230690',
      regionName: '장안동',
      guName: '동대문구',
      lat: 37.5688,
      lng: 127.0713,
    ),

    Region(
      regionCode: '11260510',
      regionName: '면목동',
      guName: '중랑구',
      lat: 37.5883,
      lng: 127.0857,
    ),
    Region(
      regionCode: '11260580',
      regionName: '상봉동',
      guName: '중랑구',
      lat: 37.5967,
      lng: 127.0854,
    ),

    Region(
      regionCode: '11290510',
      regionName: '성북동',
      guName: '성북구',
      lat: 37.5936,
      lng: 126.9997,
    ),
    Region(
      regionCode: '11290680',
      regionName: '길음동',
      guName: '성북구',
      lat: 37.6034,
      lng: 127.0246,
    ),

    Region(
      regionCode: '11305510',
      regionName: '수유동',
      guName: '강북구',
      lat: 37.6376,
      lng: 127.0257,
    ),
    Region(
      regionCode: '11305550',
      regionName: '미아동',
      guName: '강북구',
      lat: 37.6262,
      lng: 127.0257,
    ),

    Region(
      regionCode: '11320510',
      regionName: '도봉동',
      guName: '도봉구',
      lat: 37.6688,
      lng: 127.0471,
    ),
    Region(
      regionCode: '11320560',
      regionName: '창동',
      guName: '도봉구',
      lat: 37.6532,
      lng: 127.0473,
    ),

    Region(
      regionCode: '11350590',
      regionName: '상계동',
      guName: '노원구',
      lat: 37.6600,
      lng: 127.0700,
    ),
    Region(
      regionCode: '11350650',
      regionName: '중계동',
      guName: '노원구',
      lat: 37.6494,
      lng: 127.0736,
    ),

    Region(
      regionCode: '11380550',
      regionName: '연신내',
      guName: '은평구',
      lat: 37.6191,
      lng: 126.9210,
    ),
    Region(
      regionCode: '11380600',
      regionName: '불광동',
      guName: '은평구',
      lat: 37.6103,
      lng: 126.9297,
    ),

    Region(
      regionCode: '11410610',
      regionName: '신촌동',
      guName: '서대문구',
      lat: 37.5590,
      lng: 126.9425,
    ),
    Region(
      regionCode: '11410680',
      regionName: '홍제동',
      guName: '서대문구',
      lat: 37.5891,
      lng: 126.9436,
    ),

    Region(
      regionCode: '11440130',
      regionName: '망원동',
      guName: '마포구',
      lat: 37.5558,
      lng: 126.9062,
    ),
    Region(
      regionCode: '11440120',
      regionName: '합정동',
      guName: '마포구',
      lat: 37.5497,
      lng: 126.9137,
    ),
    Region(
      regionCode: '11440103',
      regionName: '상수동',
      guName: '마포구',
      lat: 37.5478,
      lng: 126.9227,
    ),

    Region(
      regionCode: '11470510',
      regionName: '목동',
      guName: '양천구',
      lat: 37.5265,
      lng: 126.8747,
    ),
    Region(
      regionCode: '11470565',
      regionName: '신정동',
      guName: '양천구',
      lat: 37.5205,
      lng: 126.8564,
    ),

    Region(
      regionCode: '11500106',
      regionName: '화곡동',
      guName: '강서구',
      lat: 37.5412,
      lng: 126.8497,
    ),
    Region(
      regionCode: '11500620',
      regionName: '마곡동',
      guName: '강서구',
      lat: 37.5586,
      lng: 126.8250,
    ),

    Region(
      regionCode: '11530510',
      regionName: '구로동',
      guName: '구로구',
      lat: 37.4954,
      lng: 126.8874,
    ),
    Region(
      regionCode: '11530555',
      regionName: '신도림동',
      guName: '구로구',
      lat: 37.5089,
      lng: 126.8912,
    ),

    Region(
      regionCode: '11545510',
      regionName: '가산동',
      guName: '금천구',
      lat: 37.4816,
      lng: 126.8825,
    ),
    Region(
      regionCode: '11545550',
      regionName: '독산동',
      guName: '금천구',
      lat: 37.4674,
      lng: 126.8969,
    ),

    Region(
      regionCode: '11560101',
      regionName: '여의도동',
      guName: '영등포구',
      lat: 37.5219,
      lng: 126.9245,
    ),
    Region(
      regionCode: '11560570',
      regionName: '당산동',
      guName: '영등포구',
      lat: 37.5344,
      lng: 126.9027,
    ),

    Region(
      regionCode: '11590515',
      regionName: '노량진동',
      guName: '동작구',
      lat: 37.5130,
      lng: 126.9427,
    ),
    Region(
      regionCode: '11590570',
      regionName: '사당동',
      guName: '동작구',
      lat: 37.4766,
      lng: 126.9816,
    ),

    Region(
      regionCode: '11620550',
      regionName: '신림동',
      guName: '관악구',
      lat: 37.4842,
      lng: 126.9294,
    ),
    Region(
      regionCode: '11620660',
      regionName: '봉천동',
      guName: '관악구',
      lat: 37.4823,
      lng: 126.9415,
    ),

    Region(
      regionCode: '11650590',
      regionName: '서초동',
      guName: '서초구',
      lat: 37.4837,
      lng: 127.0324,
    ),
    Region(
      regionCode: '11650635',
      regionName: '반포동',
      guName: '서초구',
      lat: 37.5048,
      lng: 127.0125,
    ),

    Region(
      regionCode: '11680101',
      regionName: '역삼동',
      guName: '강남구',
      lat: 37.5006,
      lng: 127.0364,
    ),
    Region(
      regionCode: '11680105',
      regionName: '삼성동',
      guName: '강남구',
      lat: 37.5145,
      lng: 127.0570,
    ),
    Region(
      regionCode: '11680110',
      regionName: '청담동',
      guName: '강남구',
      lat: 37.5196,
      lng: 127.0473,
    ),

    Region(
      regionCode: '11710615',
      regionName: '잠실동',
      guName: '송파구',
      lat: 37.5133,
      lng: 127.1000,
    ),
    Region(
      regionCode: '11710650',
      regionName: '문정동',
      guName: '송파구',
      lat: 37.4855,
      lng: 127.1219,
    ),

    Region(
      regionCode: '11740660',
      regionName: '천호동',
      guName: '강동구',
      lat: 37.5384,
      lng: 127.1237,
    ),
    Region(
      regionCode: '11740705',
      regionName: '길동',
      guName: '강동구',
      lat: 37.5350,
      lng: 127.1397,
    ),
  ];
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
