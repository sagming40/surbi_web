// lib/services/kakao_map_view_registry.dart

import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'dart:js_interop'; // 추가!
import 'dart:convert'; // ⭐ 추가 — JSON 문자열 → Dart 객체 변환
import 'dart:math' as math; // ⭐ 2026-08-23 추가 — 샘플 업소 점 좌표 생성
import 'package:flutter/foundation.dart'; // ⭐ 추가 — debugPrint (성능 계측 로그)
import 'package:flutter/services.dart'; // ⭐ 추가 — rootBundle (assets 읽기)
import 'kakao_map_interop.dart'; // 추가!
import 'package:surbi_web/models/business.dart';
import 'package:surbi_web/models/region.dart'; // ⭐ 추가

// ═══════════════════════════════════════════════════════════
// 2026-08-23 · Phase 2-B — 지도 인스턴스 일원화
//
// 이 파일에는 2026-08-23까지 지도가 **두 개** 있었다.
//   · 업소 지도  — `/map` 화면용
//   · Step 1 지도 — `/explore`(통합 화면)용
//
// 그래서 같은 일을 하는 함수가 늘 쌍으로 존재했다.
// 이름 뒤에 `Step1`을 붙여 구분했는데, `zoomIn`과 `zoomInStep1`처럼
// **어느 쪽을 불러야 하는지 호출부가 알아야 하는** 구조였다.
//
// 화면을 하나로 합치면서 옛 지도와 그 짝을 전부 걷어냈다.
// (지운 것: 옛 register·moveToRegion·zoom 3종·setMapInteractive·
//  drawRegionBoundary·선택 동 강조 마커)
//
// 업소 마커·카드 기능은 **살렸다.** 보는 지도만 남은 쪽으로 바꿔 끼웠고,
// Phase 2-D에서 통합 화면이 그대로 호출한다.
//
// 이어서 `Step1` 꼬리표도 전부 뗐다(2-B-3). 붙인 이유였던 "둘 중 어느 쪽"이
// 사라졌으니, 남겨두면 있지도 않은 구분을 가리키는 이름이 된다.
// ═══════════════════════════════════════════════════════════

// ⬇️ 추가 — 마커 Tap시 바깥에서 실행할 함수
void Function(Business business)? onBusinessMarkerTap;

// ⬇️ 추가 — 오버레이 카드의 버튼 눌렀을 때 바깥에서 실행할 함수
void Function(Business business)? onBusinessDetailTap;

// ⬇️ 추가 — 현재 지도 위에 떠있는 카드 (없으면 null, 최대 1개만 유지)
KakaoCustomOverlay? _activeOverlay;

// ⬇️ 추가 — 그 카드가 "어떤 업소"의 카드인지 같이 기억
Business? _activeOverlayBusiness;

// ⬇️ 업소 목록을 받아서 마커로 찍어주는 함수
// 2026-08-16 Phase 3 — Building(건물) → Business(업소) 재정의
//
// ⚠️ 2026-08-23 Phase 2-B — 지금은 **아무도 부르지 않는다.**
//    쓰던 화면(`/map`)이 사라졌고, 통합 화면에서 다시 쓰는 것은 Phase 2-D다.
//    지우지 않는 이유: 마커 hover 확대·클릭·카드 띄우기가 이미 다 되어 있어
//    Phase 2-D는 "이 함수를 부르는 것"만 하면 된다.
//    그때 손볼 것 → 화면 맞추기(setBounds)는 이미 동 경계에 맞춰둔 카메라와
//    충돌하므로 옵션으로 빼야 하고, 300ms 대기도 불필요해진다.
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

  _fitBounds(map, bounds);
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

/// 앱 전체에서 단 하나뿐인 지도 객체 (2026-08-23 일원화 — 파일 상단 주석 참고)
KakaoMap? kakaoMapInstance;

/// 지도가 실제 크기를 잡은 뒤 초기 화면(서울 전역 경계)을 한 번 그렸는지 여부.
/// 지도를 새로 만들 때마다(화면 재진입) false로 되돌린다.
bool _mapReadyNotified = false;

/// 지도가 **실제로 그릴 수 있는 크기**가 된 첫 순간에 한 번 호출된다.
///
/// registry는 "언제 준비됐는지"만 알리고, **무엇을 그릴지는 화면이 결정한다.**
/// 여기서 직접 서울 전역을 그리면, 화면이 이미 고른 구·동을 그리려 할 때
/// 두 코드가 같은 지도를 두고 경쟁해 결과가 실행 순서에 따라 달라진다.
/// (SurbiDropdown.onMenuVisibilityChanged와 같은 패턴 — 2026-08-21 추가)
void Function()? onMapReady;

/// "지도를 그릴 빈 공간"을 Flutter에 등록
/// main() 앱 시작할 때 딱 한 번만 호출
void registerKakaoMapView() {
  ui_web.platformViewRegistry.registerViewFactory('kakao-map-view', (
    int viewId,
  ) {
    // 화면에 다시 들어오면 지도가 새로 만들어지므로 준비 알림도 다시 보내도록 되돌림
    _mapReadyNotified = false;

    final div = web.HTMLDivElement()
      ..id = 'kakao-map-$viewId'
      ..style.width = '100%'
      ..style.height = '100%'
      // ⚠️ 필수 — 카카오맵은 타일을 position:absolute로 깔아 컨테이너 밖으로 넘친다.
      // 지도는 Flutter가 그린 그림이 아니라 진짜 브라우저 DOM(Platform View)이라,
      // 넘친 부분이 옆에 있는 Flutter UI 위를 그대로 덮어버린다.
      // (2026-08-21 — 통합 화면에서 지도가 좌측 패널·상단 바를 가린 사고)
      ..style.overflow = 'hidden';

    // 생성 시점의 중심·레벨은 임시값이다. 이 시점엔 div가 아직 화면에 붙기 전이라
    // 크기가 0이고, 진짜 초기 화면은 아래 ResizeObserver에서 잡는다.
    final options = KakaoMapOptions(
      center: KakaoLatLng(37.5665, 126.9780), // 서울시청
      level: 8,
    );
    final map = KakaoMap(div, options);
    kakaoMapInstance = map;

    // 지도의 빈 곳을 클릭하면 떠 있는 업소 카드를 닫는다.
    // (삭제된 옛 지도 등록부에 있던 것을 옮겨왔다 — 2026-08-23)
    kakaoAddListener(
      map,
      'click',
      (() {
        closeBusinessOverlay();
      }).toJS,
    );

    final observer = web.ResizeObserver(
      ((JSArray<JSAny?> entries, web.ResizeObserver obs) {
        map.relayout();

        // 크기가 실제로 잡힌 첫 순간에 딱 한 번 초기 화면을 그린다.
        // 크기가 0인 상태에서 setBounds하면 엉뚱한 곳을 비추고,
        // 매번 다시 그리면 창 크기를 바꿀 때마다 보던 위치가 튕겨나간다.
        if (!_mapReadyNotified &&
            div.clientWidth > 0 &&
            div.clientHeight > 0) {
          _mapReadyNotified = true;
          // 비동기지만 기다리지 않는다 — 관찰자 콜백을 붙잡고 있을 이유가 없다
          final onReady = onMapReady;
          if (onReady != null) {
            onReady(); // 화면이 판단 (선택이 있으면 그 구·동, 없으면 서울 전역)
          } else {
            drawSeoulOverview(); // 훅을 등록하지 않은 경우의 기본 동작
          }
        }
      }).toJS,
    );
    observer.observe(div);

    return div;
  });
}

// 구를 선택했을 때 찍는 '동 중심' 마커들
//    (구를 새로 선택할 때, 이 리스트를 보고 이전 마커부터 지움)
List<KakaoMarker> _regionMarkers = [];

/// 동 중심 마커를 전부 지운다.
///
/// 지도에 얹히는 것이 폴리곤과 마커 두 종류라, 화면 상태를 바꿀 때 **둘 다**
/// 손봐야 한다. 서울 전체로 돌아갈 때 폴리곤만 갈아치우고 마커를 두면
/// 이전에 보던 구의 동 마커가 서울 지도 위에 그대로 남는다. (2026-08-21 사고)
void clearRegionMarkers() {
  for (final marker in _regionMarkers) {
    marker.setMap(null);
  }
  _regionMarkers = [];
}

/// 구를 선택하면 그 안의 동들을 중심 마커로 찍는다
///
/// [moveCamera] false면 마커만 찍고 카메라(중심·줌)는 건드리지 않는다.
/// 구 경계 폴리곤이 setBounds로 이미 화면을 맞춘 뒤에 호출되는 경우,
/// 카메라가 두 번 움직여 화면이 덜컹거리는 걸 막기 위함. (2026-08-20 추가)
Future<void> addRegionMarkers(
  List<Region> regions, {
  bool moveCamera = true,
}) async {
  final map = kakaoMapInstance;
  if (map == null) return;

  clearRegionMarkers();

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

    _regionMarkers.add(marker); // ⬅️ 추가 — 새로 만든 마커를 리스트에 저장해둠
    bounds.extend(position);
  }

  // ⭐ 폴리곤이 이미 화면을 맞췄으면(moveCamera=false) 카메라는 손대지 않음
  if (moveCamera) _fitBounds(map, bounds);
}

// ─────────────────────────────────────────────
// ② 업소 지도 — 행정동 이동 / 지도 컨트롤 (2026-08-19 회의 반영)
// ─────────────────────────────────────────────

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

/// 지금 지도에 그려져 있는 선택 동 경계 폴리곤 (항상 1개만 유지)
KakaoPolygon? _regionPolygon;

/// 자치구명 → 경계 좌표 배열 (초기 화면용). 동 경계와 같은 방식으로 캐시한다.
Map<String, List<KakaoLatLng>>? _guBoundaryCache;

/// GeoJSON 한 건을 읽어 "속성키 → 좌표 배열" 형태로 바꿔준다.
///
/// 동 경계·구 경계 두 파일이 구조가 같아 한 함수로 처리한다.
/// 반환값은 **파일을 실제로 읽는 데 걸린 ms** — 두 번째 호출부터는 0이다.
/// (성능 로그에서 "한 번 내는 비용"과 "매번 내는 비용"을 갈라 보기 위함)
Future<int> _loadBoundaryFile(
  String assetPath,
  String keyProperty,
  Map<String, List<KakaoLatLng>>? Function() read,
  void Function(Map<String, List<KakaoLatLng>>) write,
) async {
  if (read() != null) return 0; // ⬅️ 두 번째 호출부터는 파일을 다시 읽지 않음

  final watch = Stopwatch()..start();

  final raw = await rootBundle.loadString(assetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final features = json['features'] as List<dynamic>;

  final cache = <String, List<KakaoLatLng>>{};
  for (final f in features) {
    final feature = f as Map<String, dynamic>;
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;

    final key = properties[keyProperty] as String;
    // 두 파일 모두 단일 파트·구멍 없음이 확인됨 → 외곽 링 하나만 읽으면 됨
    // (구 경계는 동 경계를 합쳐 만들었고, 25개 전부 단일 폴리곤으로 나왔다)
    final ring = (geometry['coordinates'] as List<dynamic>)[0] as List<dynamic>;

    // ⚠️ GeoJSON은 [경도, 위도] 순서 / 카카오는 (위도, 경도) 순서 → 반드시 뒤집을 것
    cache[key] = ring.map((c) {
      final point = c as List<dynamic>;
      return KakaoLatLng(
        (point[1] as num).toDouble(), // 위도
        (point[0] as num).toDouble(), // 경도
      );
    }).toList();
  }

  write(cache);
  watch.stop();
  return watch.elapsedMilliseconds;
}

/// 행정동 경계(425개)를 캐시에 올린다. 이미 올라와 있으면 즉시 0 반환
Future<int> _ensureBoundaryLoaded() => _loadBoundaryFile(
  'assets/geo/seoul_dong.json',
  'code',
  () => _boundaryCache,
  (c) => _boundaryCache = c,
);

/// 자치구 경계(25개)를 캐시에 올린다. 이미 올라와 있으면 즉시 0 반환
Future<int> _ensureGuBoundaryLoaded() => _loadBoundaryFile(
  'assets/geo/seoul_gu.json',
  'name',
  () => _guBoundaryCache,
  (c) => _guBoundaryCache = c,
);

/// 경계 폴리곤을 실제로 그리는 핵심 로직
///
/// 지도 인스턴스를 인자로 받아, 성공하면 만들어진 폴리곤을 반환한다.
/// 실패(지도 미생성·경계 데이터 없음) 시 null → 호출한 쪽이 폴백을 결정한다.
///
/// [fillOpacity]·[strokeWeight]를 **부르는 쪽이 정한다.** 같은 폴리곤이라도
/// 아래 깔린 배경에 따라 필요한 진하기가 다르기 때문이다 — 구 전체 동 경계가
/// 네이비로 깔린 위에 그리는 선택 동은 진해야 이기고, 밑칠이 없는 곳에서
/// 같은 값을 쓰면 과하게 진해진다.
///
/// 2026-08-20에 이 값을 한 벌로 통일했다가, "이 변경이 필요한 곳"과 "이 변경을
/// 받는 곳"이 다르다는 걸 놓쳐 다른 화면의 채움까지 함께 사라진 적이 있다.
/// 공용화는 같은 이유로 같은 것이 필요할 때 가치가 있지, 코드가 우연히 같아서가 아니다.
///
/// [fitBounds] false면 폴리곤만 그리고 카메라는 건드리지 않는다.
Future<KakaoPolygon?> _renderBoundary(
  KakaoMap? map,
  Region region, {
  double fillOpacity = 0.15,
  num strokeWeight = 3,
  bool fitBounds = true,
}) async {
  if (map == null) return null;

  await _ensureBoundaryLoaded();

  final path = _boundaryCache![region.regionCode];
  if (path == null) return null; // 경계 정보 없는 동

  // 반투명은 위에서부터 덮어쓰므로, 아래 색이 남는 양 = (1 - 위쪽 불투명도) × 아래 불투명도.
  // 주황 0.15 / 네이비 0.16이었을 때 네이비가 (1-0.15)×0.16 = 13.6% 남아
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
  if (fitBounds) {
    final bounds = KakaoLatLngBounds();
    for (final point in path) {
      bounds.extend(point);
    }
    _fitBounds(map, bounds);
  }

  return polygon;
}

/// 주황 경계도 대기표가 필요하다 — 자세한 이유는 [_paintGeneration] 주석 참고
int _regionPolygonGeneration = 0;

/// 선택된 행정동의 경계를 강조하고 **그 동에 카메라를 맞춘다**
///
/// 2026-08-20에는 `fitBounds: false`(구 전체 시야 유지)였다. 근거는
/// "Step 1은 좋은 동을 **발견**하는 화면이라 동 하나만 확대하면 비교 대상이
/// 화면 밖으로 나간다"였고, **화면이 분리돼 있던 그때는 맞는 판단이었다.**
///
/// 2026-08-23에 뒤집었다. 통합 화면에서는 동을 고르는 순간 패널이 상세 모드로
/// 바뀐다 — 패널은 파고드는데 지도만 멀리서 보면 앞뒤가 안 맞는다.
/// 비교 맥락은 `‹`(→ [restoreBaseView])로 한 번에 되찾을 수 있으므로
/// 8/20의 반대 근거 자체가 사라졌다.
///
/// ⚠️ 확대와 복귀는 **한 쌍**이다. 이 함수만 켜고 복귀를 안 만들면,
///    동을 해제해도 지도가 확대된 채 남아 목록과 지도가 어긋난다.
Future<bool> drawRegionBoundary(Region region) async {
  final generation = ++_regionPolygonGeneration;

  // ⚠️ **먼저 그리고 나중에 바꿔 끼운다.** 예전처럼 지우기를 await 앞에 두면,
  //    두 호출이 겹칠 때 서로 빈 자리를 지우고 각자 폴리곤을 남겨
  //    주황 경계가 지도에 영구히 붙어버린다. (_paintBoundaries와 같은 사고)
  final polygon = await _renderBoundary(
    kakaoMapInstance,
    region,
    // 이 화면에는 구 전체 동 경계가 네이비로 깔려 있다 → 그 위를 이기도록 진하게
    fillOpacity: 0.35,
    strokeWeight: 4,
    fitBounds: true, // ⭐ 2026-08-23 — 선택한 동에 맞춰 확대
  );

  if (generation != _regionPolygonGeneration) {
    polygon?.setMap(null); // 늦게 도착 — 내가 만든 것만 치우고 물러난다
    return false;
  }

  _regionPolygon?.setMap(null);
  _regionPolygon = polygon;
  return _regionPolygon != null;
}

/// 동 선택을 풀었을 때 돌아갈 시야 — 마지막으로 그린 경계 전체의 범위.
///
/// 서울 전체를 그렸으면 서울 25개 구, 구를 그렸으면 그 구의 동 전체가 담긴다.
/// **폴리곤을 다시 그리지 않고 카메라만 되돌리기 위해** 따로 들고 있는다.
/// (다시 그리면 425개 좌표를 또 계산하게 되고, 화면도 한 번 깜빡인다)
KakaoLatLngBounds? _baseBounds;

/// 동 선택 해제 → 방금 전 단위(구 전체 또는 서울 전체) 시야로 복귀
///
/// [drawRegionBoundary]의 확대와 짝을 이루는 함수다.
/// 지도 위를 **덮고 있는 UI의 높이(px)** — 좁은 화면의 하단 시트가 여기 해당한다.
/// (2026-08-26 추가)
///
/// 지도는 자기 위에 무엇이 얹혀 있는지 모른다. **화면이 알려줘야 한다.**
/// (onMapReady · SurbiDropdown.onMenuVisibilityChanged와 같은 원칙)
///
/// 0보다 크면 아래 [_fitBounds]가 그만큼을 빼고 화면을 맞춰, 대상이 시트에
/// 가려지지 않는 자리에 놓인다. 넓은 화면에서는 0이다.
double mapBottomInset = 0;

/// 화면 맞추기는 **전부 이 함수를 거친다.** setBounds를 직접 부르지 말 것 —
/// 하단 시트를 빼먹는 실수가 한 곳에서만 가능해진다.
void _fitBounds(KakaoMap map, KakaoLatLngBounds bounds) {
  if (mapBottomInset <= 0) {
    map.setBounds(bounds);
    return;
  }
  map.setBoundsWithPadding(bounds, 0, 0, mapBottomInset.round(), 0);
}

void restoreBaseView() {
  final map = kakaoMapInstance;
  final bounds = _baseBounds;
  if (map == null || bounds == null) return;
  _fitBounds(map, bounds);
}

// ═══════════════════════════════════════════════════════════
// 업소 점 (샘플) — 2026-08-23
//
// ⚠️⚠️ **좌표는 합성이다. 실제 업소 위치가 아니다.** ⚠️⚠️
//
// 왜 가짜를 그리나 — 우리 DB에는 업소 537,488건이 적재·검증까지 끝나 있는데
// `GET /api/businesses`가 없어서 꺼낼 수가 없다. 그래서 렌더링 파이프라인이
// 완성됐다는 것을 **눈으로** 보여주고, 팀에는 "데이터만 넣으면 된다"는
// 그림으로 API를 요청하기 위한 자리 표시다.
// 화면 좌하단 배지(`_SampleDataBadge`)가 항상 이 사실을 알린다.
//
// ⚠️ 이 실측은 **낙관적 하한선**이다. 균등 난수는 실제보다 착하다 —
//    진짜 상권은 역세권·도로변에 몰리므로 같은 개수라도 더 무거울 수 있다.
//    클러스터링 도입 여부는 실제 데이터를 받은 뒤 다시 재야 한다.
//
// Task 4-5에서 `GET /api/businesses`가 붙으면 이 블록 전체를 지우고
// `addBusinessMarkers`(업소 지도용, 실제 데이터)로 갈아탄다.
// ═══════════════════════════════════════════════════════════

/// 동 하나에 뿌릴 샘플 점 개수 — **실제 DB 총건수에서 뽑은 값이다.**
/// 537,488건 ÷ 425개 동 ≈ 1,265건.
/// 좌표는 가짜여도 **밀도는 진짜**여야 "실제로 얼마나 빽빽해지는지"를 볼 수 있다.
const int kSampleBusinessesPerDong = 1265;

List<KakaoMarker> _businessDots = [];

/// 점 마커 이미지 — **한 번 만들어 전부가 공유한다.**
/// 1,265개마다 새로 만들면 같은 그림을 1,265번 디코딩하게 된다.
KakaoMarkerImage? _dotMarkerImage;

KakaoMarkerImage _ensureDotMarkerImage() {
  // SVG를 base64로 감싸는 이유: data URI에 `<`, `#`, 공백을 그대로 넣으면
  // 브라우저마다 해석이 갈린다. base64는 그런 escape 문제가 아예 없다.
  const svg =
      "<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10'>"
      "<circle cx='5' cy='5' r='3.5' fill='rgb(242,153,74)' fill-opacity='0.9' "
      "stroke='rgb(255,255,255)' stroke-width='1'/></svg>";
  final src = 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
  // ⚠️ 마커는 이미지 '아래 가운데'가 좌표에 붙는다 → 점이 5px 위로 뜬다.
  //    10px짜리 점에서는 눈에 띄지 않아 지금은 둔다. 실제 데이터가 붙어
  //    정확한 위치가 중요해지면 `MarkerImage`의 offset 옵션을 뚫을 것.
  return _dotMarkerImage ??= KakaoMarkerImage(src, KakaoSize(10, 10));
}

/// 뿌려둔 점을 전부 지운다 — 안 지우면 동을 바꿀수록 점이 쌓인다
///
/// **지우기도 대기표를 갱신한다.** 그리는 도중에 동을 해제하면, 지운 뒤에
/// 뒤늦게 끝난 그리기가 점을 다시 얹어버린다. 번호를 올려두면 그 요청이
/// 스스로 물러난다.
void clearBusinessDots() {
  _dotGeneration++;
  for (final marker in _businessDots) {
    marker.setMap(null);
  }
  _businessDots = [];
}

/// 이 함수도 [_paintBoundaries]와 같은 이유로 대기표가 필요하다 —
/// `_ensureBoundaryLoaded()`를 기다리는 사이 다른 동이 선택될 수 있다.
int _dotGeneration = 0;

/// 선택한 동의 경계 **안쪽에만** 샘플 점을 뿌린다. 반환값 = 실제로 찍은 개수.
Future<int> drawSampleBusinessDots(
  Region region, {
  int count = kSampleBusinessesPerDong,
}) async {
  final map = kakaoMapInstance;
  if (map == null) return 0;

  final generation = ++_dotGeneration;

  await _ensureBoundaryLoaded();
  if (generation != _dotGeneration) return 0; // 더 새로운 요청이 왔다

  // 지우기는 대기 뒤에 — 대기 전에 지우면 상대가 그린 점을 못 지운다
  clearBusinessDots();

  final path = _boundaryCache?[region.regionCode];
  if (path == null) return 0; // 경계 없는 동 — 뿌릴 범위를 모른다

  final watch = Stopwatch()..start();
  // 시드를 동 코드로 고정 — 같은 동은 언제 다시 눌러도 같은 그림이 나온다.
  // 매번 달라지면 "점이 움직인다"는 인상을 줘서 진짜 데이터로 오해받는다.
  final points = _randomPointsInPolygon(path, count, region.regionCode.hashCode);
  final generateMs = watch.elapsedMilliseconds;

  final image = _ensureDotMarkerImage();
  for (final point in points) {
    final marker = KakaoMarker(
      KakaoMarkerOptions(position: point, image: image),
    );
    marker.setMap(map);
    _businessDots.add(marker);
  }
  watch.stop();

  debugPrint(
    '[업소 점·샘플] ${region.regionName} · '
    '요청 $count개 → 실제 ${points.length}개 · '
    '좌표생성 ${generateMs}ms · 총 ${watch.elapsedMilliseconds}ms',
  );
  return points.length;
}

/// 다각형 안에 무작위 점 [count]개를 만든다.
///
/// **방식: 버리기(rejection) 샘플링.**
/// 다각형을 감싸는 사각형 안에 점을 던지고, 다각형 밖이면 버리고 다시 던진다.
/// 다각형 내부를 직접 계산하는 것보다 훨씬 간단하고, 동 모양이 대체로
/// 뭉툭해서 채택률이 높다.
///
/// > 비유 — 지도 위에 쌀알을 뿌리고 **동 경계 밖에 떨어진 것만 골라내는** 것.
///
/// [maxAttempts]로 상한을 두는 이유: 아주 길쭉하거나 구멍 난 모양이면
/// 채택률이 뚝 떨어져 영원히 못 채울 수 있다. 무한 루프는 브라우저를 멈춘다.
List<KakaoLatLng> _randomPointsInPolygon(
  List<KakaoLatLng> path,
  int count,
  int seed,
) {
  if (path.isEmpty) return [];

  // JS 객체를 매번 건너다니면 느리다 → Dart 숫자로 한 번에 옮겨놓고 계산한다
  final lats = <double>[];
  final lngs = <double>[];
  for (final point in path) {
    lats.add(point.getLat().toDouble());
    lngs.add(point.getLng().toDouble());
  }

  var minLat = lats.first, maxLat = lats.first;
  var minLng = lngs.first, maxLng = lngs.first;
  for (var i = 1; i < lats.length; i++) {
    if (lats[i] < minLat) minLat = lats[i];
    if (lats[i] > maxLat) maxLat = lats[i];
    if (lngs[i] < minLng) minLng = lngs[i];
    if (lngs[i] > maxLng) maxLng = lngs[i];
  }

  final random = math.Random(seed);
  final points = <KakaoLatLng>[];
  final maxAttempts = count * 60;
  var attempts = 0;

  while (points.length < count && attempts < maxAttempts) {
    attempts++;
    final lat = minLat + random.nextDouble() * (maxLat - minLat);
    final lng = minLng + random.nextDouble() * (maxLng - minLng);
    if (_isInsidePolygon(lats, lngs, lat, lng)) {
      points.add(KakaoLatLng(lat, lng));
    }
  }
  return points;
}

/// 점이 다각형 **안**에 있는지 판정 — 레이 캐스팅(ray casting) 알고리즘
///
/// 점에서 한쪽 방향으로 반직선을 쏴서 다각형의 변과 **몇 번 만나는지** 센다.
/// 홀수면 안, 짝수면 밖이다.
///
/// > 비유 — 미로 벽을 몇 번 통과했는지 세는 것과 같다.
/// > 벽을 홀수 번 넘었으면 아직 안쪽, 짝수 번이면 다시 밖으로 나온 것.
///
/// 위경도를 평면 좌표처럼 쓰지만, 동 하나는 몇 km라 지구 곡률의 영향이
/// 무시할 수준이다. (서울 전체를 한 다각형으로 판정하는 용도가 아니다)
bool _isInsidePolygon(
  List<double> lats,
  List<double> lngs,
  double lat,
  double lng,
) {
  var inside = false;
  final n = lats.length;
  // j는 i의 바로 앞 꼭짓점 — 마지막↔처음도 이어야 하므로 n-1에서 시작한다
  for (var i = 0, j = n - 1; i < n; j = i++) {
    final crossesLatitude = (lats[i] > lat) != (lats[j] > lat);
    if (!crossesLatitude) continue;
    // 그 변이 점의 위도선과 만나는 경도를 구해, 점보다 오른쪽이면 1회 통과
    final crossLng =
        (lngs[j] - lngs[i]) * (lat - lats[i]) / (lats[j] - lats[i]) + lngs[i];
    if (lng < crossLng) inside = !inside;
  }
  return inside;
}

/// 경계 폴리곤 제거 — 구를 바꾸면 이전 동 선택이 무효가 되므로 함께 지움
void clearRegionBoundary() {
  _regionPolygon?.setMap(null);
  _regionPolygon = null;
}

/// 동을 선택하면 경계를 강조하고 그 동에 카메라를 맞춘다.
///
/// 경계 데이터가 없을 때만 중심 좌표로 이동하는 기존 방식으로 폴백한다.
/// (폴백은 방어 코드다 — `kSeoulDistricts`가 이 GeoJSON에서 생성됐으므로
///  모든 동에 경계가 있고, 실제로 이 분기를 타는 경우는 없어야 정상이다.)
Future<void> focusRegion(Region region) async {
  final drawn = await drawRegionBoundary(region);
  if (drawn) return;

  final map = kakaoMapInstance;
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

// ── 여러 곳이 동시에 지도를 잠글 때 (2026-08-21 추가) ──────────
//
// 잠그는 주체가 하나면 위 함수로 충분하지만, 통합 화면에서는 둘 이상이 겹친다.
// 예: 하단 시트를 만져서 잠근 상태에서 그 안의 드롭다운을 열면 메뉴도 잠근다.
//
// 이때 boolean 하나로 관리하면 **먼저 푼 쪽이 다른 쪽의 잠금까지 풀어버린다.**
// (실제 사고: 패널 잠금이 300ms 뒤 자동 해제되면서, 아직 열려 있는 드롭다운의
//  잠금까지 풀려 메뉴를 스크롤하면 지도가 따라 움직였다)
//
// 그래서 '누가 왜 잠갔는지'를 모아두고, **아무 이유도 남지 않았을 때만** 푼다.
// 방 하나에 여러 사람이 들어와 불을 켰다면, 마지막 사람이 나갈 때 꺼야 하는 것과 같다.
final Set<String> _mapLockReasons = {};

/// [reason] 이름으로 지도를 잠근다. 같은 이유로 여러 번 불러도 안전하다.
void lockMap(String reason) {
  _mapLockReasons.add(reason);
  setMapInteractive(false);
}

/// [reason] 하나를 거둔다. 남은 이유가 없을 때만 실제로 풀린다.
void unlockMap(String reason) {
  _mapLockReasons.remove(reason);
  if (_mapLockReasons.isEmpty) setMapInteractive(true);
}

/// 화면을 떠날 때 잠금 이유를 전부 비운다 — 다음 화면이 잠긴 지도를 물려받지 않도록
void clearMapLocks() {
  _mapLockReasons.clear();
  setMapInteractive(true);
}

// ── 지도 컨트롤 ──────────────────────────────────────
//
// 2026-08-21에는 이것과 똑같은 함수가 옛 지도용으로 하나씩 더 있었다
// (zoomIn / zoomOut / setMapSkyview). 2026-08-23 일원화로 그쪽을 걷어내
// 지금은 이 셋만 남았다 — 예고했던 정리를 실제로 한 것이다.

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
// ④ 행정동 경계 밑그림 = 히트맵의 골격 (2026-08-20 추가)
//
// ③이 "동 하나"를 주황으로 강조하는 것이라면, ④는 "여러 동을 한꺼번에" 깔아
// 히트맵의 밑바탕을 만든다. 무엇을 깔지는 두 가지다.
//   · 초기 화면 — 서울 전역 425개 (drawSeoulOverview)
//   · 구 선택 후 — 그 구의 동만 (drawGuBoundaries)
// 그리는 방식은 완전히 같고 대상만 다르므로 _paintBoundaries 하나로 합쳐 두었다.
//
// 지금은 전부 같은 네이비지만, 이 자리에 점수별 색을 넣으면 그대로 히트맵이 된다.
// (Task 4-3 — scores 연동 시 fillColor만 점수 기반 함수로 교체 예정)
//
// ⚠️ scores 커버리지는 업종마다 다르다 — 한식 392개 / 양식 182개(전체 425 대비 43%).
//    "점수 없는 동 30개"가 아니라 최대 243개다. 색칠 못 하는 동의 표시 규칙
//    (네이비 유지 / 빗금 / 제외)을 색칠 단계 전에 정해야 함. (2026-08-20 CSV 실측)
// ─────────────────────────────────────────────

/// 지금 지도에 깔려 있는 경계 폴리곤들 (서울 전역 또는 선택 구).
/// 동 하나짜리 주황 폴리곤(_regionPolygon)과는 별개로 관리한다 —
/// 구를 바꿀 때 통째로 지워야 하고, 동을 바꿀 때는 남아 있어야 하기 때문.
List<KakaoPolygon> _guPolygons = [];

/// 구에 속한 모든 행정동 경계를 렌더 (히트맵 밑그림)
///
/// 폴리곤 개수·좌표 개수·소요 시간을 debugPrint로 출력한다.
/// 서울 전역(425개·약 4,400좌표)을 상시 렌더할 수 있는지 판단하기 위한 계측이며,
/// 판단이 끝나면 로그는 제거 예정.
Future<void> drawGuBoundaries(List<Region> regions) async {
  if (regions.isEmpty) {
    _clearGuPolygons(); // 구 선택 해제 등
    return;
  }
  final loadMs = await _ensureBoundaryLoaded();

  final paths = <List<KakaoLatLng>>[];
  var missing = 0; // 경계 데이터가 없는 동 (GeoJSON 425 vs Region 목록 불일치 감지용)
  for (final region in regions) {
    final path = _boundaryCache![region.regionCode];
    if (path == null) {
      missing++;
      continue;
    }
    paths.add(path);
  }

  await _paintBoundaries(
    paths,
    label: regions.first.guName,
    missingCount: missing,
    loadMs: loadMs,
  );
}

/// 서울 자치구 25개 경계를 깔아 초기 화면을 만든다 (2026-08-20 추가)
///
/// 구를 고르기 전에는 폴리곤이 하나도 없어 화면이 맨 카카오맵이었다.
/// "여기가 무엇을 하는 화면인지" 신호가 없어 지도가 장식처럼 보였다.
///
/// ⚠️ 처음에는 행정동 425개를 그대로 깔았으나 서울 전체 축척에서 너무 촘촘했고,
///    드래그·줌이 무거워졌다. 생성은 19~21ms로 빨랐지만 폴리곤은 만들고 끝이 아니라
///    **매 프레임 다시 그려지므로**, 생성 비용이 싸다고 유지 비용까지 싼 건 아니다.
///    → 자치구 25개(1,022좌표)로 교체. 좌표 4.3배·폴리곤 17배 가벼워졌다.
///
/// 축척에 따라 집계 단위를 바꾸는 건 통계 지도의 정석이다 —
/// 서울 전체를 볼 땐 구 단위, 구를 고르면 동 단위로 내려간다.
///
/// 점수 색칠(Task 4-3) 시에도 같은 원칙을 이어간다:
/// 초기 화면은 구 평균 점수, 구를 고르면 동별 점수.
Future<void> drawSeoulOverview() async {
  // 서울 전체 시야에는 특정 구의 동 마커가 남아 있으면 안 된다.
  // 폴리곤과 마커는 서로 다른 목록이라 한쪽만 갈아치우면 다른 쪽이 남는다.
  clearRegionMarkers();
  clearRegionBoundary();

  final loadMs = await _ensureGuBoundaryLoaded();
  await _paintBoundaries(
    _guBoundaryCache!.values.toList(),
    label: '서울 25개 구',
    loadMs: loadMs,
  );
}

/// 깔려 있던 경계 폴리곤을 전부 제거 — 안 지우면 선택을 바꿀수록 경계가 쌓인다
void _clearGuPolygons() {
  for (final polygon in _guPolygons) {
    polygon.setMap(null);
  }
  _guPolygons = [];
}

// ── 겹쳐 그리기 사고 방지 (2026-08-23) ──────────────────────────
//
// 이 함수는 안에서 `await` 하기 때문에 **끝나기 전에 또 불릴 수 있다.**
// 실제로 2-A에서 URL 동기화가 들어오면서 두 경로가 동시에 지도를 그리게 됐다:
//   ① URL 변경 → 상태 변경 → ref.listen → showGu
//   ② 지도 준비 완료 → onMapReady → _syncMapToSelection → showGu
//
// 예전 코드는 "지우기 → 300ms 대기 → 그리기" 순서였는데, 둘 다 **지우기를
// 대기 전에** 끝내버려서 서로의 폴리곤을 못 지웠다.
// (증상: 강남구 22개가 로그에 44개로 찍힘 — 눈에는 안 보이고 수치만 왜곡)
//
// 해법은 **대기표**다. 들어올 때 번호를 뽑고, 기다렸다 깨어났을 때
// 내 번호가 아직 최신인지 확인한다. 아니면 그냥 물러난다 — 늦게 온 요청이 이긴다.
//
// > 은행 대기표와 같다. 306번을 뽑고 자리를 비웠는데 전광판이 312번이면
// > 내 차례는 지나간 것이다.
//
// ⚠️ 일반 규칙: **`await` 앞뒤로 공유 상태를 건드리는 비동기 함수는
//    반드시 이 가드가 필요하다.** 앞으로도 계속 만날 패턴이다.
int _paintGeneration = 0;

/// 경계 좌표 목록을 받아 폴리곤을 한꺼번에 그린다 (자치구·행정동 공용)
///
/// 좌표 배열만 받고 **어느 캐시에서 왔는지는 모른다.** 그리는 방식이 두 경우
/// 완전히 같고 "무엇을 그리느냐"만 다르기 때문이다. 캐시를 직접 참조하게 두면
/// 새 단위(예: 시·도)가 생길 때마다 이 함수를 고쳐야 한다.
///
/// [label]·[missingCount]·[loadMs]는 성능 로그 전용이다.
Future<void> _paintBoundaries(
  List<List<KakaoLatLng>> paths, {
  required String label,
  int missingCount = 0,
  int loadMs = 0,
}) async {
  final map = kakaoMapInstance;
  if (map == null) return;

  // 대기표를 뽑는다 (2026-08-23 — 아래 '겹쳐 그리기 사고' 주석 참고)
  final generation = ++_paintGeneration;

  // 지도 컨테이너가 실제 크기를 잡을 시간을 벌어줌.
  // 이걸 빼면 첫 진입 때 setBounds가 0×0 크기 기준으로 계산돼 화면이 엉뚱한 데를 비춘다.
  // (계측을 오염시키지 않도록 Stopwatch 시작 전에 처리)
  await Future.delayed(const Duration(milliseconds: 300));

  // 기다리는 사이 더 새로운 요청이 왔다면 조용히 물러난다
  if (generation != _paintGeneration) return;

  // ⚠️ 지우기는 반드시 **기다린 뒤**에 한다. 대기 전에 지우면 아직 아무도
  //    안 그린 빈 리스트를 지우게 되고, 정작 상대가 그린 폴리곤은 남는다.
  _clearGuPolygons();
  map.relayout();

  // ⏱️ 파일 읽기·파싱은 파일당 1회뿐이라 호출부에서 따로 재 [loadMs]로 넘겨받는다.
  //    여기서부터가 "선택을 바꿀 때마다 매번 치르는 비용"
  final renderWatch = Stopwatch()..start();

  final bounds = KakaoLatLngBounds();
  var pointCount = 0; // 실제로 그린 좌표 총개수 — 성능의 진짜 원인은 폴리곤 수가 아니라 좌표 수

  // 동 선택을 풀었을 때 돌아올 자리로 기억해둔다.
  // 여기서 잡는 이유: "방금 그린 단위 전체"가 곧 복귀 지점이고,
  // 그 값을 계산하는 곳이 정확히 여기라서다. (restoreBaseView)
  _baseBounds = bounds;

  for (final path in paths) {
    // 코로플레스(통계 지도) 방식 — 면이 데이터를 담고, 선은 칸만 나눈다.
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
        // 구분선 색 변천 (2026-08-20):
        //   ① #8A94A6 1px  — 카카오맵 자체 경계선과 계열이 같아 묻힘
        //   ② #FFFFFF 1.5px — 타일 사이의 '틈'으로 잘 읽혔으나 지도 위 흰 도로와 헷갈림
        //   ③ #9AA5B4 1.5px — 지금. 네이비 채움을 밝게 푼 계열이라 면과 톤이 맞고,
        //      ①보다 밝아 카카오맵 경계선과도 구분된다.
        // 면(네이비 0.16)이 칸을 채우고 있으므로 선은 나누는 역할만 하면 된다.
        strokeColor: '#9AA5B4',
        strokeOpacity: 0.9,
        fillColor: '#1E3A5F',
        fillOpacity: 0.16,
      ),
    );
    polygon.setMap(map);
    _guPolygons.add(polygon);

    for (final point in path) {
      bounds.extend(point);
      pointCount++;
    }
  }

  // 그린 영역 전체가 화면에 들어오도록 맞춤 (면적이 제각각이라 고정 줌보다 정확)
  if (_guPolygons.isNotEmpty) _fitBounds(map, bounds);

  renderWatch.stop();

  debugPrint(
    '[히트맵 성능] $label · '
    '폴리곤 ${_guPolygons.length}개 · '
    '좌표 $pointCount개 · '
    '렌더 ${renderWatch.elapsedMilliseconds}ms '
    '(GeoJSON 로드 ${loadMs}ms)'
    '${missingCount > 0 ? " · ⚠️ 경계없음 $missingCount개" : ""}',
  );
}

/// 구를 선택했을 때 지도가 해야 할 일을 한 곳에 모은 함수
///
/// 순서에 의미가 있다:
///   ① 이전 동의 주황 경계 제거 — 구가 바뀌면 이전 동 선택은 무효
///   ② 구 전체 동 경계를 회색으로 렌더 + 카메라를 구 전체에 맞춤
///   ③ 동 중심 마커를 찍되 카메라는 건드리지 않음(moveCamera: false)
///      — ②가 이미 맞춰놨는데 또 움직이면 화면이 두 번 덜컹거림
Future<void> showGu(List<Region> regions) async {
  clearRegionBoundary();
  await drawGuBoundaries(regions);
  await addRegionMarkers(regions, moveCamera: false);
}
