// lib/services/kakao_map_view_registry.dart

import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'dart:js_interop'; // 추가!
import 'dart:convert'; // ⭐ 추가 — JSON 문자열 → Dart 객체 변환
import 'package:flutter/foundation.dart'; // ⭐ 추가 — debugPrint (성능 계측 로그)
import 'package:flutter/services.dart'; // ⭐ 추가 — rootBundle (assets 읽기)
import 'kakao_map_interop.dart'; // 추가!
import 'package:surbi_web/models/business.dart';
import 'package:surbi_web/models/region.dart'; // ⭐ 추가

// ⬇️ 추가 — 지도 객체 전역 변수
KakaoMap? kakaoMapInstance;

// ⬇️ 추가 — 마커 Tap시 바깥에서 실행할 함수
void Function(Business business)? onBusinessMarkerTap;

// ⬇️ 추가 — 오버레이 카드의 버튼 눌렀을 때 바깥에서 실행할 함수
void Function(Business business)? onBusinessDetailTap;

// ⬇️ 추가 — 현재 지도 위에 떠있는 카드 (없으면 null, 최대 1개만 유지)
KakaoCustomOverlay? _activeOverlay;

// ⬇️ 추가 — 그 카드가 "어떤 업소"의 카드인지 같이 기억
Business? _activeOverlayBusiness;

/// Step 3 지도 화면에서 쓸 "지도를 그릴 빈 공간"을 Flutter에 등록
/// main() 앱 시작할 때 딱 한 번만 호출하면 됨
void registerKakaoMapView() {
  ui_web.platformViewRegistry.registerViewFactory('kakao-map-view', (
    int viewId,
  ) {
    final div = web.HTMLDivElement()
      ..id = 'kakao-map-$viewId'
      ..style.width = '100%'
      ..style.height = '100%';

    // 망원동 근처 좌표를 임시 중심점으로 지도 생성
    final options = KakaoMapOptions(
      center: KakaoLatLng(37.5563, 126.9013),
      level: 4,
    );
    final map = KakaoMap(div, options); // ⬅️ 변수 선언
    kakaoMapInstance = map; // ⬅️ 전역 변수에 지도 저장

    // ⭐ 추가 — 지도의 빈 곳을 클릭하면 떠있는 카드를 닫음
    kakaoAddListener(
      map,
      'click',
      (() {
        closeBusinessOverlay();
      }).toJS,
    );

    // ⬇️ div 크기가 바뀔 때마다 map.relayout() 자동 호출
    final observer = web.ResizeObserver(
      ((JSArray<JSAny?> entries, web.ResizeObserver obs) {
        map.relayout();
      }).toJS,
    );
    observer.observe(div);

    return div;
  });
}

// ⬇️ 업소 목록을 받아서 마커로 찍어주는 함수
// 2026-08-16 Phase 3 — Building(건물) → Business(업소) 재정의
Future<void> addBusinessMarkers(List<Business> businesses) async {
  final map = kakaoMapInstance;
  if (map == null) return; // 지도가 아직 안 만들어졌으면 그냥 종료 (방어 코드)
  if (businesses.isEmpty) return; // 업소가 하나도 없으면 그냥 종료 (방어 코드)

  // ⬇️ 추가 ㅡ 지도 컨테이너가 실제로 자리 잡을 시간을 살짝 벌어줌
  await Future.delayed(const Duration(milliseconds: 300));
  map.relayout(); // ⬅️ 추가 ㅡ bounds 계산 전에 지도 크기 먼저 재확인

  final bounds = KakaoLatLngBounds();

  // ⬇️ 원본 크기 / 확대된 크기(hover) 마커 이미지
  final normalImage = KakaoMarkerImage(
    _pinDataUri(size: 32, color: '#1E3A5F'),
    KakaoSize(32, 40),
  );
  final hoverImage = KakaoMarkerImage(
    _pinDataUri(size: 44, color: '#1E3A5F'),
    KakaoSize(44, 55),
  );

  for (final business in businesses) {
    final position = KakaoLatLng(business.lat, business.lng);

    final marker = KakaoMarker(
      KakaoMarkerOptions(
        position: position,
        image: normalImage,
      ), // ⬅️ position 변수 재사용 (중복 생성 정리)
    );
    marker.setMap(map);

    // ⬇️ 커서가 마커에 닿으면 확대
    kakaoAddListener(
      marker,
      'mouseover',
      (() {
        marker.setImage(hoverImage);
      }).toJS,
    );

    // ⬇️ 커서가 마커에서 벗어나면 원래대로
    kakaoAddListener(
      marker,
      'mouseout',
      (() {
        marker.setImage(normalImage);
      }).toJS,
    );

    // ⬇️ 추가 ㅡ 마커 클릭 이벤트
    kakaoAddListener(
      marker,
      'click',
      (() {
        onBusinessMarkerTap?.call(business);
      }).toJS,
    );

    bounds.extend(position);
  }

  map.setBounds(bounds);
}

// ⬇️ 마커 탭하면 이 함수가 호출되어 지도 위에 카드를 얹음
void showBusinessOverlay(Business business) {
  final map = kakaoMapInstance;
  if (map == null) return; // 방어 코드

  // ⭐ 이미 열려있는 카드가 "지금 누른 그 업소"면, 새로 열지 말고 그냥 닫기
  if (_activeOverlayBusiness?.bizCode == business.bizCode) {
    closeBusinessOverlay();
    return;
  }

  _activeOverlay?.setMap(null); // ⭐ 이전 카드 있으면 먼저 지움 (카드 중복 방지)

  final cardElement = _buildOverlayCardElement(business);

  final overlay = KakaoCustomOverlay(
    KakaoCustomOverlayOptions(
      position: KakaoLatLng(business.lat, business.lng),
      content: cardElement,
      yAnchor: 1.3, // ⭐ 카드 하단이 핀 위쪽에 오도록 살짝 띄움
    ),
  );
  overlay.setMap(map);
  _activeOverlay = overlay; // ⭐ "현재 떠있는 카드"로 기억해둠
  _activeOverlayBusiness = business; // ⭐ "지금 이 업소 카드가 열려있다" 기록
}

// ⬇️ 카드 닫기 (버튼 눌러서 상권 분석으로 이동할 때 등)
void closeBusinessOverlay() {
  _activeOverlay?.setMap(null);
  _activeOverlay = null;
  _activeOverlayBusiness = null;
}

// ⬇️ 업소 정보 카드를 실제 DOM 요소로 조립
// 2026-08-16 Phase 3 — 미리보기 점수 제거
//   근거: 점수는 행정동+업종 단위로만 산출 가능 (8/3 대조표 안건 1 확정),
//         업소 단위 점수는 DB·ML 어디에도 존재하지 않음
web.HTMLDivElement _buildOverlayCardElement(Business business) {
  final isOpen = business.openStatus == '영업중';

  final card = web.HTMLDivElement()
    ..style.background = 'white'
    ..style.borderRadius = '16px'
    ..style.padding = '14px'
    ..style.width = '220px'
    ..style.boxShadow = '0 4px 12px rgba(0,0,0,0.2)'
    ..style.fontFamily = 'sans-serif';

  // ⭐ 카드 위에서 일어나는 마우스/터치 상호작용을
  //    "지도 클릭"으로 오인하지 않도록 카카오맵에 미리 알려줌
  card.addEventListener('mousedown', ((web.Event e) => kakaoPreventMap()).toJS);
  card.addEventListener(
    'touchstart',
    ((web.Event e) => kakaoPreventMap()).toJS,
  );

  final title = web.HTMLDivElement()
    ..textContent = business.bizName
    ..style.fontWeight = 'bold'
    ..style.fontSize = '15px'
    ..style.color = '#1E3A5F'
    ..style.marginBottom = '6px';

  final statusRow = web.HTMLDivElement()
    ..textContent = '${business.categoryName} · ${business.openStatus}'
    ..style.fontSize = '13px'
    ..style.color = isOpen
        ? '#2E7D32'
        : '#757575' // 영업중=초록 / 그 외=회색
    ..style.marginBottom = '10px';

  final button = web.HTMLButtonElement()
    ..textContent = '이 동네 상권 분석 보기'
    ..style.width = '100%'
    ..style.padding = '8px'
    ..style.border = 'none'
    ..style.borderRadius = '8px'
    ..style.background = '#1E3A5F'
    ..style.color = 'white'
    ..style.fontWeight = 'bold'
    ..style.cursor = 'pointer';

  // ⭐ 버튼 클릭 이벤트 — 마커 클릭 때와 똑같은 "0개 인자 클로저" 패턴 재사용
  button.addEventListener(
    'click',
    (() {
      onBusinessDetailTap?.call(business);
    }).toJS,
  );

  card.append(title);
  card.append(statusRow);
  card.append(button);

  return card;
}

/// 네이비 색 핀 모양을 SVG로 직접 그려서 "이미지 파일"처럼 넘겨주는 함수
String _pinDataUri({required double size, required String color}) {
  final svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="${size * 1.25}" viewBox="0 0 24 30">'
      '<path d="M12 0C5.4 0 0 5.4 0 12c0 9 12 18 12 18s12-9 12-18C24 5.4 18.6 0 12 0z" fill="$color"/>'
      '<circle cx="12" cy="12" r="5" fill="white"/>'
      '</svg>';
  return 'data:image/svg+xml,${Uri.encodeComponent(svg)}';
}

// ⬇️ 추가 — Step1 지도 인스턴스 (Step3의 kakaoMapInstance와 별개로 관리)
KakaoMap? kakaoMapInstanceStep1;

/// Step 1 히트맵 자리에 쓸 "지도를 그릴 빈 공간"을 Flutter에 등록
/// main() 앱 시작할 때 registerKakaoMapView()와 함께 딱 한 번만 호출
void registerKakaoMapViewStep1() {
  ui_web.platformViewRegistry.registerViewFactory('kakao-map-view-step1', (
    int viewId,
  ) {
    final div = web.HTMLDivElement()
      ..id = 'kakao-map-step1-$viewId'
      ..style.width = '100%'
      ..style.height = '100%';

    // 서울시청 좌표를 기본 중심점으로 (아직 구를 선택하기 전 초기 화면)
    final options = KakaoMapOptions(
      center: KakaoLatLng(37.5665, 126.9780),
      level: 8, // 서울 전체가 보이도록 레벨을 좀 더 낯춤 (숫자가 클수록 축소)
    );
    final map = KakaoMap(div, options);
    kakaoMapInstanceStep1 = map;

    final observer = web.ResizeObserver(
      ((JSArray<JSAny?> entries, web.ResizeObserver obs) {
        map.relayout();
      }).toJS,
    );
    observer.observe(div);

    return div;
  });
}

// ⬇️ 추가 — Step1에서 구 선택 시, 해당 구의 동들을 마커로 찍는 함수
//    (구를 새로 선택할 때, 이 리스트를 보고 이전 마커부터 지움)
List<KakaoMarker> _step1RegionMarkers = [];

/// Step1에서 구 선택 시, 해당 구의 동들을 마커로 찍는 함수
///
/// [moveCamera] false면 마커만 찍고 카메라(중심·줌)는 건드리지 않는다.
/// 구 경계 폴리곤이 setBounds로 이미 화면을 맞춘 뒤에 호출되는 경우,
/// 카메라가 두 번 움직여 화면이 덜컹거리는 걸 막기 위함. (2026-08-20 추가)
Future<void> addRegionMarkers(
  List<Region> regions, {
  bool moveCamera = true,
}) async {
  final map = kakaoMapInstanceStep1;
  if (map == null) return;

  for (final marker in _step1RegionMarkers) {
    marker.setMap(null);
  }
  _step1RegionMarkers = [];

  if (regions.isEmpty) return; // 동 목록이 비었으면(구 선택 해제 등) 종료

  await Future.delayed(const Duration(milliseconds: 300));
  map.relayout();

  final bounds = KakaoLatLngBounds();

  final normalImage = KakaoMarkerImage(
    _pinDataUri(size: 28, color: '#1E3A5F'),
    KakaoSize(28, 35),
  );
  final hoverImage = KakaoMarkerImage(
    _pinDataUri(size: 38, color: '#1E3A5F'),
    KakaoSize(38, 48),
  );

  for (final region in regions) {
    final position = KakaoLatLng(region.lat, region.lng);

    final marker = KakaoMarker(
      KakaoMarkerOptions(position: position, image: normalImage),
    );
    marker.setMap(map);

    kakaoAddListener(
      marker,
      'mouseover',
      (() {
        marker.setImage(hoverImage);
      }).toJS,
    );

    kakaoAddListener(
      marker,
      'mouseout',
      (() {
        marker.setImage(normalImage);
      }).toJS,
    );

    _step1RegionMarkers.add(marker); // ⬅️ 추가 — 새로 만든 마커를 리스트에 저장해둠
    bounds.extend(position);
  }

  // ⭐ 폴리곤이 이미 화면을 맞췄으면(moveCamera=false) 카메라는 손대지 않음
  if (moveCamera) map.setBounds(bounds);
}

// ─────────────────────────────────────────────
// ② 업소 지도 — 행정동 이동 / 지도 컨트롤 (2026-08-19 회의 반영)
// ─────────────────────────────────────────────

// 지금 선택된 행정동을 표시하는 강조 마커 (항상 1개만 유지)
KakaoMarker? _selectedRegionMarker;

/// 드롭다운에서 동을 고르면 지도 중심을 그쪽으로 옮기고 강조 마커를 찍음
///
/// [moveCamera] false면 마커만 찍고 카메라(중심·줌)는 건드리지 않는다.
/// 경계 폴리곤이 setBounds로 이미 화면을 맞춘 경우 카메라가 두 번 움직이는 걸 막기 위함.
Future<void> moveToRegion(
  Region region, {
  int level = 4,
  bool moveCamera = true, // ⭐ 2026-08-20 추가
}) async {
  final map = kakaoMapInstance;
  if (map == null) return;

  final position = KakaoLatLng(region.lat, region.lng);

  // 이전 강조 마커 제거 (업소 마커는 건드리지 않음)
  _selectedRegionMarker?.setMap(null);

  // ⚠️ 임시 강조색 — 디자인 확정 시 theme.dart로 이관 예정
  final marker = KakaoMarker(
    KakaoMarkerOptions(
      position: position,
      image: KakaoMarkerImage(
        _pinDataUri(size: 42, color: '#F2994A'),
        KakaoSize(42, 53),
      ),
    ),
  );
  marker.setMap(map);
  _selectedRegionMarker = marker;

  // ⭐ 폴리곤이 이미 화면을 맞췄으면(moveCamera=false) 카메라는 손대지 않음
  if (moveCamera) {
    map.setLevel(level);
    map.panTo(position);
  }
}

/// 줌 인 — 카카오맵은 레벨 숫자가 작을수록 확대
void zoomIn() {
  final map = kakaoMapInstance;
  if (map == null) return;
  final next = map.getLevel() - 1;
  if (next < 1) return;
  map.setLevel(next);
}

/// 줌 아웃
void zoomOut() {
  final map = kakaoMapInstance;
  if (map == null) return;
  final next = map.getLevel() + 1;
  if (next > 14) return;
  map.setLevel(next);
}

/// 일반 지도 ↔ 스카이뷰 전환
void setMapSkyview(bool isSkyview) {
  final map = kakaoMapInstance;
  if (map == null) return;
  map.setMapTypeId(isSkyview ? kakaoMapTypeSkyview : kakaoMapTypeRoadmap);
}

// ─────────────────────────────────────────────
// ③ 행정동 경계 폴리곤 (2026-08-20 추가)
//
// 데이터: assets/geo/seoul_dong.json — 행정안전부 고시 행정동 경계(서울 425개)
//        properties.code = 행정동코드 8자리 (팀 DB districts.district_code와 동일 체계)
// ⚠️ districts.geom은 2026-08-17 적재 완료 확인됨.
//    경계를 제공하는 엔드포인트(/api/map/heatmap 등) 완성 시 이 asset 대신 API 응답으로 교체 예정
// ─────────────────────────────────────────────

/// 행정동코드 → 경계 좌표 배열.
/// 앱 실행 중 딱 한 번만 파일을 읽어 캐시에 올리고 계속 재사용(메모이제이션)
Map<String, List<KakaoLatLng>>? _boundaryCache;

/// 지금 지도에 그려져 있는 경계 폴리곤 (지도별로 항상 1개만 유지)
KakaoPolygon? _regionPolygon; // 업소 지도(kakaoMapInstance)용
KakaoPolygon? _regionPolygonStep1; // Step 1 지도(kakaoMapInstanceStep1)용

/// assets의 GeoJSON을 읽어 캐시에 올림. 이미 올라와 있으면 즉시 반환
Future<void> _ensureBoundaryLoaded() async {
  if (_boundaryCache != null) return; // ⬅️ 두 번째 호출부터는 파일을 다시 읽지 않음

  final raw = await rootBundle.loadString('assets/geo/seoul_dong.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final features = json['features'] as List<dynamic>;

  final cache = <String, List<KakaoLatLng>>{};
  for (final f in features) {
    final feature = f as Map<String, dynamic>;
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;

    final code = properties['code'] as String;
    // 서울 425개 행정동은 전부 단일 파트·구멍 없음이 확인됨 → 외곽 링 하나만 읽으면 됨
    final ring = (geometry['coordinates'] as List<dynamic>)[0] as List<dynamic>;

    // ⚠️ GeoJSON은 [경도, 위도] 순서 / 카카오는 (위도, 경도) 순서 → 반드시 뒤집을 것
    cache[code] = ring.map((c) {
      final point = c as List<dynamic>;
      return KakaoLatLng(
        (point[1] as num).toDouble(), // 위도
        (point[0] as num).toDouble(), // 경도
      );
    }).toList();
  }

  _boundaryCache = cache;
}

/// 경계 폴리곤을 실제로 그리는 핵심 로직 (Step1·업소 지도 공용)
///
/// 지도 인스턴스를 인자로 받아, 성공하면 만들어진 폴리곤을 반환한다.
/// 실패(지도 미생성·경계 데이터 없음) 시 null → 호출한 쪽이 폴백을 결정한다.
///
/// [fillOpacity]·[strokeWeight]를 부르는 쪽이 정하는 이유 (2026-08-20 추가):
/// 두 화면은 아래 깔린 배경이 다르다. Step 1에는 구 전체 동 경계가 네이비로
/// 깔려 있어 그 위를 이기려면 채움을 진하게 해야 하고, 업소 지도에는 밑칠이
/// 없어 같은 값을 쓰면 과하게 진해진다.
///
/// 공용 함수를 한 값으로 통일했다가, "이 변경이 필요한 화면"과 "이 변경을 받는
/// 화면"이 다르다는 걸 놓쳐 업소 지도의 채움까지 함께 사라진 적이 있다.
/// 공용화는 같은 이유로 같은 것이 필요할 때 가치가 있지, 코드가 우연히 같아서가 아니다.
Future<KakaoPolygon?> _renderBoundary(
  KakaoMap? map,
  Region region, {
  double fillOpacity = 0.15,
  num strokeWeight = 3,
}) async {
  if (map == null) return null;

  await _ensureBoundaryLoaded();

  final path = _boundaryCache![region.regionCode];
  if (path == null) return null; // 경계 정보 없는 동

  // 반투명은 위에서부터 덮어쓰므로, 아래 색이 남는 양 = (1 - 위쪽 불투명도) × 아래 불투명도.
  // Step 1에서 주황 0.15 / 네이비 0.16이었을 때 네이비가 (1-0.15)×0.16 = 13.6% 남아
  // 주황 15%와 거의 1대1로 비겨 갈색으로 보였다. 주황을 0.35로 올리면 네이비는
  // 10.4%만 남아 3대1 이상으로 벌어진다. (2026-08-20 — 값 근거)
  //
  // ⚠️ Task 4-3 재검토 필요: 점수 색이 면에 들어오면 선택 동의 주황 채움이
  //    그 동의 점수를 덮는다. 정작 궁금한 동의 점수가 안 보이게 되므로,
  //    그때는 선택 표시를 선으로 옮기거나 테두리만 강조하는 방식으로 바꿀 것.
  //    지금은 면에 담긴 정보가 없어 덮어도 잃을 것이 없다.
  // ⚠️ 색값은 임시 — 디자인 확정 시 theme.dart로 이관 예정
  final polygon = KakaoPolygon(
    KakaoPolygonOptions(
      path: path.toJS,
      strokeWeight: strokeWeight,
      strokeColor: '#F2994A',
      strokeOpacity: 1.0,
      fillColor: '#F2994A',
      fillOpacity: fillOpacity,
    ),
  );
  polygon.setMap(map);

  // 경계 좌표 전부를 담는 사각 영역을 만들어 화면을 딱 맞춤
  // (동마다 면적이 달라서 고정 줌 레벨보다 정확함)
  final bounds = KakaoLatLngBounds();
  for (final point in path) {
    bounds.extend(point);
  }
  map.setBounds(bounds);

  return polygon;
}

/// [업소 지도] 선택된 행정동의 경계를 그리고 화면을 그 영역에 맞춤
///
/// 반환값 true  = 폴리곤을 그렸음 (카메라도 setBounds로 맞춰짐)
/// 반환값 false = 경계 데이터가 없어 못 그림 → 호출한 쪽이 기존 방식으로 폴백해야 함
Future<bool> drawRegionBoundary(Region region) async {
  // 이전 폴리곤 제거 (업소 마커·강조 핀은 건드리지 않음)
  _regionPolygon?.setMap(null);
  // 이 화면에는 밑칠이 없다 → 기본값(0.15 / 3px) 그대로
  _regionPolygon = await _renderBoundary(kakaoMapInstance, region);
  return _regionPolygon != null;
}

/// [Step 1] 선택된 행정동의 경계를 그리고 화면을 맞춤 (2026-08-20 추가)
Future<bool> drawRegionBoundaryStep1(Region region) async {
  _regionPolygonStep1?.setMap(null);
  // 이 화면에는 구 전체 동 경계가 네이비로 깔려 있다 → 그 위를 이기도록 진하게
  _regionPolygonStep1 = await _renderBoundary(
    kakaoMapInstanceStep1,
    region,
    fillOpacity: 0.35,
    strokeWeight: 4,
  );
  return _regionPolygonStep1 != null;
}

/// [Step 1] 경계 폴리곤 제거 — 구를 바꾸면 이전 동 선택이 무효가 되므로 함께 지움
void clearRegionBoundaryStep1() {
  _regionPolygonStep1?.setMap(null);
  _regionPolygonStep1 = null;
}

/// [Step 1] 동을 선택하면 경계를 칠하고 화면을 맞춤.
/// 경계 데이터가 없으면 중심 좌표로 이동하는 기존 방식으로 폴백한다.
Future<void> focusRegionStep1(Region region) async {
  final drawn = await drawRegionBoundaryStep1(region);
  if (drawn) return;

  final map = kakaoMapInstanceStep1;
  if (map == null) return;
  map.setLevel(4);
  map.panTo(KakaoLatLng(region.lat, region.lng));
}

/// 지도의 드래그·휠 확대축소를 한꺼번에 켜고 끔 (2026-08-20 추가)
///
/// 배경: 드롭다운 메뉴(Flutter 오버레이)는 지도(Platform View) 위에 그려지지만,
/// 휠·드래그 이벤트는 아래쪽 지도 DOM에도 함께 전달돼 지도가 같이 움직였다.
/// Task 3-3·7/20에서 겪은 "두 렌더링 세계가 서로를 모른다" 문제의 이벤트 버전.
/// 이벤트 흐름을 역추적하는 대신 카카오맵이 제공하는 전용 함수로 정면 차단한다.
void setMapInteractive(bool enabled) {
  final map = kakaoMapInstance;
  if (map == null) return;
  map.setDraggable(enabled);
  map.setZoomable(enabled);
}

/// [Step 1] 지도의 드래그·휠 확대축소를 켜고 끔 — Step 1은 지도 인스턴스가 별개라 별도 함수
void setMapInteractiveStep1(bool enabled) {
  final map = kakaoMapInstanceStep1;
  if (map == null) return;
  map.setDraggable(enabled);
  map.setZoomable(enabled);
}

// ─────────────────────────────────────────────
// ④ 구 전체 경계 = 히트맵 밑그림 (2026-08-20 추가)
//
// ③이 "동 하나"를 주황으로 칠하는 것이라면, ④는 "구에 속한 동 전부"를
// 연회색으로 한꺼번에 깔아 히트맵의 밑바탕을 만든다.
// 지금은 전부 같은 회색이지만, 이 자리에 점수별 색을 넣으면 그대로 히트맵이 된다.
// (Task 4-3 — scores 연동 시 fillColor만 점수 기반 함수로 교체 예정)
//
// ⚠️ scores는 행정동 397개만 존재(전체 대비 약 30개 누락) → 색칠 못 하는 동의
//    표시 규칙(회색 유지 / 빗금 등)을 색칠 단계 전에 정해야 함
// ─────────────────────────────────────────────

/// 지금 Step 1 지도에 깔려 있는 "구 전체 동 경계" 폴리곤들.
/// 동 하나짜리 주황 폴리곤(_regionPolygonStep1)과는 별개로 관리한다 —
/// 구를 바꿀 때 통째로 지워야 하고, 동을 바꿀 때는 남아 있어야 하기 때문.
List<KakaoPolygon> _guPolygonsStep1 = [];

/// [Step 1] 구에 속한 모든 행정동 경계를 연회색으로 렌더 (히트맵 밑그림)
///
/// 폴리곤 개수·좌표 개수·소요 시간을 debugPrint로 출력한다.
/// 서울 전역(425개·약 4,400좌표)을 상시 렌더할 수 있는지 판단하기 위한 계측이며,
/// 판단이 끝나면 로그는 제거 예정.
Future<void> drawGuBoundaries(List<Region> regions) async {
  final map = kakaoMapInstanceStep1;
  if (map == null) return;

  // 이전 구의 폴리곤을 전부 제거 — 이걸 빼먹으면 구를 바꿀수록 경계가 쌓인다
  for (final polygon in _guPolygonsStep1) {
    polygon.setMap(null);
  }
  _guPolygonsStep1 = [];

  if (regions.isEmpty) return; // 구 선택 해제 등

  // 지도 컨테이너가 실제 크기를 잡을 시간을 벌어줌.
  // 이걸 빼면 첫 진입 때 setBounds가 0×0 크기 기준으로 계산돼 화면이 엉뚱한 데를 비춘다.
  // (계측을 오염시키지 않도록 Stopwatch 시작 전에 처리)
  await Future.delayed(const Duration(milliseconds: 300));
  map.relayout();

  // ⏱️ 파일 읽기·파싱(146KB)은 앱 전체에서 딱 1회뿐 → 매번 치르는 렌더 비용과 분리해 측정
  final loadWatch = Stopwatch()..start();
  await _ensureBoundaryLoaded();
  loadWatch.stop();

  // ⏱️ 여기서부터가 "구를 바꿀 때마다 매번 치르는 비용"
  final renderWatch = Stopwatch()..start();

  final bounds = KakaoLatLngBounds();
  var pointCount = 0; // 실제로 그린 좌표 총개수 — 성능의 진짜 원인은 폴리곤 수가 아니라 좌표 수
  var missingCount = 0; // 경계 데이터가 없는 동 (GeoJSON 425 vs Region 목록 불일치 감지용)

  for (final region in regions) {
    final path = _boundaryCache![region.regionCode];
    if (path == null) {
      missingCount++;
      continue;
    }

    // 코로플레스(통계 지도) 방식 — 면이 데이터를 담고, 흰 선은 칸만 나눈다.
    // Task 4-3에서 fillColor를 점수 기반으로 바꾸면 그대로 히트맵이 되고,
    // 점수가 없는 동(scores 397개 vs 경계 425개)은 이 네이비를 그대로 유지한다.
    //
    // 회색이 아니라 네이비를 쓴 이유: 카카오맵 밑그림이 회색·흰색 톤이라
    // 회색은 아무리 진하게 해도 "지도가 그린 선"으로 읽힌다. 대비가 아니라
    // 색 계열을 바꿔야 우리가 그린 것으로 구분된다.
    //
    // z순서: 주황 동 폴리곤(③)보다 먼저 그려지므로 아래에 깔린다.
    // 구 선택 → 동 선택 순서가 보장되고 구가 바뀌면 주황도 함께 지워지므로,
    // 별도 zIndex 없이 그리는 순서만으로 위아래가 맞는다. (2026-08-20 실측 확인)
    //
    // ⚠️ 색값은 임시 — 디자인 확정 시 theme.dart로 이관 예정
    //    (#1E3A5F = SurbiColors.accent와 동일 값)
    final polygon = KakaoPolygon(
      KakaoPolygonOptions(
        path: path.toJS,
        strokeWeight: 1.5,
        // 흰 선은 '선'이 아니라 타일 사이의 '틈'으로 기능한다 — 통계 지도의 표준 기법.
        // 따라서 나눌 면이 있어야 의미가 있고, 면이 옅으면 밝은 지도 위의 흰 줄로만
        // 남는다. 한때 면을 0.08까지 낮췄다가 이 조합이 성립하지 않아 되돌렸다.
        strokeColor: '#FFFFFF',
        strokeOpacity: 0.9,
        fillColor: '#1E3A5F',
        fillOpacity: 0.16,
      ),
    );
    polygon.setMap(map);
    _guPolygonsStep1.add(polygon);

    for (final point in path) {
      bounds.extend(point);
      pointCount++;
    }
  }

  // 구 전체가 화면에 들어오도록 맞춤 (구마다 면적이 달라 고정 줌보다 정확)
  if (_guPolygonsStep1.isNotEmpty) map.setBounds(bounds);

  renderWatch.stop();

  debugPrint(
    '[히트맵 성능] ${regions.first.guName} · '
    '폴리곤 ${_guPolygonsStep1.length}개 · '
    '좌표 $pointCount개 · '
    '렌더 ${renderWatch.elapsedMilliseconds}ms '
    '(GeoJSON 로드 ${loadWatch.elapsedMilliseconds}ms)'
    '${missingCount > 0 ? " · ⚠️ 경계없음 $missingCount개" : ""}',
  );
}

/// [Step 1] 구를 선택했을 때 지도가 해야 할 일을 한 곳에 모은 함수
///
/// 순서에 의미가 있다:
///   ① 이전 동의 주황 경계 제거 — 구가 바뀌면 이전 동 선택은 무효
///   ② 구 전체 동 경계를 회색으로 렌더 + 카메라를 구 전체에 맞춤
///   ③ 동 중심 마커를 찍되 카메라는 건드리지 않음(moveCamera: false)
///      — ②가 이미 맞춰놨는데 또 움직이면 화면이 두 번 덜컹거림
Future<void> showGuOnStep1(List<Region> regions) async {
  clearRegionBoundaryStep1();
  await drawGuBoundaries(regions);
  await addRegionMarkers(regions, moveCamera: false);
}
