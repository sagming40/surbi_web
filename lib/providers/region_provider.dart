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
// TODO: GET /regions API 연동 후 FutureProvider로 교체 예정 (Task 4-3)
// 행정동 코드·좌표는 실제 DB 값이 아닌 임시 더미값
// ─────────────────────────────────────────────
final regionListProvider = Provider<List<Region>>((ref) {
  return const [
    Region(
      regionCode: '1111051500',
      regionName: '종로1.2.3.4가동',
      guName: '종로구',
      lat: 37.5730,
      lng: 126.9794,
    ),
    Region(
      regionCode: '1111063000',
      regionName: '혜화동',
      guName: '종로구',
      lat: 37.5820,
      lng: 127.0016,
    ),

    Region(
      regionCode: '1114055000',
      regionName: '명동',
      guName: '중구',
      lat: 37.5636,
      lng: 126.9834,
    ),
    Region(
      regionCode: '1114058000',
      regionName: '신당동',
      guName: '중구',
      lat: 37.5657,
      lng: 127.0177,
    ),

    Region(
      regionCode: '1117061000',
      regionName: '이태원동',
      guName: '용산구',
      lat: 37.5347,
      lng: 126.9946,
    ),
    Region(
      regionCode: '1117068000',
      regionName: '한남동',
      guName: '용산구',
      lat: 37.5344,
      lng: 127.0009,
    ),

    Region(
      regionCode: '1120069000',
      regionName: '성수동1가',
      guName: '성동구',
      lat: 37.5445,
      lng: 127.0559,
    ),
    Region(
      regionCode: '1120074000',
      regionName: '왕십리도선동',
      guName: '성동구',
      lat: 37.5613,
      lng: 127.0299,
    ),

    Region(
      regionCode: '1121510700',
      regionName: '화양동',
      guName: '광진구',
      lat: 37.5459,
      lng: 127.0700,
    ),
    Region(
      regionCode: '1121513500',
      regionName: '건대입구',
      guName: '광진구',
      lat: 37.5407,
      lng: 127.0700,
    ),

    Region(
      regionCode: '1123061000',
      regionName: '회기동',
      guName: '동대문구',
      lat: 37.5894,
      lng: 127.0567,
    ),
    Region(
      regionCode: '1123069500',
      regionName: '장안동',
      guName: '동대문구',
      lat: 37.5688,
      lng: 127.0713,
    ),

    Region(
      regionCode: '1126051000',
      regionName: '면목동',
      guName: '중랑구',
      lat: 37.5883,
      lng: 127.0857,
    ),
    Region(
      regionCode: '1126058000',
      regionName: '상봉동',
      guName: '중랑구',
      lat: 37.5967,
      lng: 127.0854,
    ),

    Region(
      regionCode: '1129051000',
      regionName: '성북동',
      guName: '성북구',
      lat: 37.5936,
      lng: 126.9997,
    ),
    Region(
      regionCode: '1129068500',
      regionName: '길음동',
      guName: '성북구',
      lat: 37.6034,
      lng: 127.0246,
    ),

    Region(
      regionCode: '1130551000',
      regionName: '수유동',
      guName: '강북구',
      lat: 37.6376,
      lng: 127.0257,
    ),
    Region(
      regionCode: '1130555000',
      regionName: '미아동',
      guName: '강북구',
      lat: 37.6262,
      lng: 127.0257,
    ),

    Region(
      regionCode: '1132051500',
      regionName: '도봉동',
      guName: '도봉구',
      lat: 37.6688,
      lng: 127.0471,
    ),
    Region(
      regionCode: '1132056000',
      regionName: '창동',
      guName: '도봉구',
      lat: 37.6532,
      lng: 127.0473,
    ),

    Region(
      regionCode: '1135059000',
      regionName: '상계동',
      guName: '노원구',
      lat: 37.6600,
      lng: 127.0700,
    ),
    Region(
      regionCode: '1135065000',
      regionName: '중계동',
      guName: '노원구',
      lat: 37.6494,
      lng: 127.0736,
    ),

    Region(
      regionCode: '1138555000',
      regionName: '연신내',
      guName: '은평구',
      lat: 37.6191,
      lng: 126.9210,
    ),
    Region(
      regionCode: '1138560000',
      regionName: '불광동',
      guName: '은평구',
      lat: 37.6103,
      lng: 126.9297,
    ),

    Region(
      regionCode: '1141061500',
      regionName: '신촌동',
      guName: '서대문구',
      lat: 37.5590,
      lng: 126.9425,
    ),
    Region(
      regionCode: '1141068000',
      regionName: '홍제동',
      guName: '서대문구',
      lat: 37.5891,
      lng: 126.9436,
    ),

    Region(
      regionCode: '1144013600',
      regionName: '망원동',
      guName: '마포구',
      lat: 37.5558,
      lng: 126.9062,
    ),
    Region(
      regionCode: '1144012200',
      regionName: '합정동',
      guName: '마포구',
      lat: 37.5497,
      lng: 126.9137,
    ),
    Region(
      regionCode: '1144010300',
      regionName: '상수동',
      guName: '마포구',
      lat: 37.5478,
      lng: 126.9227,
    ),

    Region(
      regionCode: '1147051000',
      regionName: '목동',
      guName: '양천구',
      lat: 37.5265,
      lng: 126.8747,
    ),
    Region(
      regionCode: '1147056500',
      regionName: '신정동',
      guName: '양천구',
      lat: 37.5205,
      lng: 126.8564,
    ),

    Region(
      regionCode: '1150010600',
      regionName: '화곡동',
      guName: '강서구',
      lat: 37.5412,
      lng: 126.8497,
    ),
    Region(
      regionCode: '1150062000',
      regionName: '마곡동',
      guName: '강서구',
      lat: 37.5586,
      lng: 126.8250,
    ),

    Region(
      regionCode: '1153051000',
      regionName: '구로동',
      guName: '구로구',
      lat: 37.4954,
      lng: 126.8874,
    ),
    Region(
      regionCode: '1153055500',
      regionName: '신도림동',
      guName: '구로구',
      lat: 37.5089,
      lng: 126.8912,
    ),

    Region(
      regionCode: '1154551000',
      regionName: '가산동',
      guName: '금천구',
      lat: 37.4816,
      lng: 126.8825,
    ),
    Region(
      regionCode: '1154555000',
      regionName: '독산동',
      guName: '금천구',
      lat: 37.4674,
      lng: 126.8969,
    ),

    Region(
      regionCode: '1156010100',
      regionName: '여의도동',
      guName: '영등포구',
      lat: 37.5219,
      lng: 126.9245,
    ),
    Region(
      regionCode: '1156057000',
      regionName: '당산동',
      guName: '영등포구',
      lat: 37.5344,
      lng: 126.9027,
    ),

    Region(
      regionCode: '1159051500',
      regionName: '노량진동',
      guName: '동작구',
      lat: 37.5130,
      lng: 126.9427,
    ),
    Region(
      regionCode: '1159057000',
      regionName: '사당동',
      guName: '동작구',
      lat: 37.4766,
      lng: 126.9816,
    ),

    Region(
      regionCode: '1162055000',
      regionName: '신림동',
      guName: '관악구',
      lat: 37.4842,
      lng: 126.9294,
    ),
    Region(
      regionCode: '1162066000',
      regionName: '봉천동',
      guName: '관악구',
      lat: 37.4823,
      lng: 126.9415,
    ),

    Region(
      regionCode: '1165059000',
      regionName: '서초동',
      guName: '서초구',
      lat: 37.4837,
      lng: 127.0324,
    ),
    Region(
      regionCode: '1165063500',
      regionName: '반포동',
      guName: '서초구',
      lat: 37.5048,
      lng: 127.0125,
    ),

    Region(
      regionCode: '1168010100',
      regionName: '역삼동',
      guName: '강남구',
      lat: 37.5006,
      lng: 127.0364,
    ),
    Region(
      regionCode: '1168010500',
      regionName: '삼성동',
      guName: '강남구',
      lat: 37.5145,
      lng: 127.0570,
    ),
    Region(
      regionCode: '1168011000',
      regionName: '청담동',
      guName: '강남구',
      lat: 37.5196,
      lng: 127.0473,
    ),

    Region(
      regionCode: '1171061500',
      regionName: '잠실동',
      guName: '송파구',
      lat: 37.5133,
      lng: 127.1000,
    ),
    Region(
      regionCode: '1171065000',
      regionName: '문정동',
      guName: '송파구',
      lat: 37.4855,
      lng: 127.1219,
    ),

    Region(
      regionCode: '1174066000',
      regionName: '천호동',
      guName: '강동구',
      lat: 37.5384,
      lng: 127.1237,
    ),
    Region(
      regionCode: '1174070500',
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
/// TODO: 실제 업종 코드 체계 확정 후 categoryCode 값 교체 예정 (Task 4-2 연동)
final categoryListProvider = Provider<List<Map<String, String>>>((ref) {
  return const [
    {'code': 'CS100001', 'name': '카페'},
    {'code': 'CS200001', 'name': '치킨'},
    {'code': 'CS300001', 'name': '한식'},
    {'code': 'CS400001', 'name': '분식'},
  ];
});
