// lib/services/kakao_map_view_registry.dart

import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'dart:js_interop'; // 추가!
import 'dart:convert'; // ⭐ 추가 — JSON 문자열 → Dart 객체 변환
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
Future<void> addRegionMarkers(List<Region> regions) async {
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

  map.setBounds(bounds);
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

/// 지금 지도에 그려져 있는 경계 폴리곤 (항상 1개만 유지)
KakaoPolygon? _regionPolygon;

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

/// 선택된 행정동의 경계를 그리고 화면을 그 영역에 맞춤
///
/// 반환값 true  = 폴리곤을 그렸음 (카메라도 setBounds로 맞춰짐)
/// 반환값 false = 경계 데이터가 없어 못 그림 → 호출한 쪽이 기존 방식으로 폴백해야 함
Future<bool> drawRegionBoundary(Region region) async {
  final map = kakaoMapInstance;
  if (map == null) return false;

  await _ensureBoundaryLoaded();

  // 이전 폴리곤 제거 (업소 마커·강조 핀은 건드리지 않음)
  _regionPolygon?.setMap(null);
  _regionPolygon = null;

  final path = _boundaryCache![region.regionCode];
  if (path == null) return false; // 경계 정보 없는 동 → 조용히 폴백

  // ⚠️ 임시 강조색 — 디자인 확정 시 theme.dart로 이관 예정
  final polygon = KakaoPolygon(
    KakaoPolygonOptions(
      path: path.toJS,
      strokeWeight: 3,
      strokeColor: '#F2994A',
      strokeOpacity: 0.9,
      fillColor: '#F2994A',
      fillOpacity: 0.15,
    ),
  );
  polygon.setMap(map);
  _regionPolygon = polygon;

  // 경계 좌표 전부를 담는 사각 영역을 만들어 화면을 딱 맞춤
  // (동마다 면적이 달라서 고정 줌 레벨보다 정확함)
  final bounds = KakaoLatLngBounds();
  for (final point in path) {
    bounds.extend(point);
  }
  map.setBounds(bounds);

  return true;
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
