// lib/services/kakao_map_interop.dart

import 'dart:js_interop';

/// kakao.maps.LatLng — 위도/경도 좌표 하나를 표현하는 JS 객체
///
/// [getLat]·[getLng]는 2026-08-23 추가.
/// 지금까지는 좌표를 **만들어 넘기기만** 해서 읽을 일이 없었는데, 업소 점을
/// "동 경계 안쪽에만" 뿌리려면 캐시에 든 경계 좌표를 다시 **읽어야** 한다.
/// (JS 객체라 Dart에서 그냥은 못 읽는다 — 통로를 뚫어줘야 한다)
@JS('kakao.maps.LatLng')
extension type KakaoLatLng._(JSObject _) implements JSObject {
  external factory KakaoLatLng(num lat, num lng);
  external num getLat();
  external num getLng();
}

/// kakao.maps.Map 생성 시 넘겨줄 옵션 (중심 좌표, 확대 레벨)
extension type KakaoMapOptions._(JSObject _) implements JSObject {
  external factory KakaoMapOptions({
    required KakaoLatLng center,
    required int level,
  });
}

/// kakao.maps.Map — 실제 지도 객체
@JS('kakao.maps.Map')
extension type KakaoMap._(JSObject _) implements JSObject {
  external factory KakaoMap(JSAny container, KakaoMapOptions options);
  external void relayout(); // ⬅️ 추가
  external void setBounds(KakaoLatLngBounds bounds); // ⬅️ 추가 ㅡ 마커 위치로 자동 이동

  /// 여백을 준 화면 맞추기 (2026-08-26 추가)
  ///
  /// 카카오맵의 setBounds는 원래 `setBounds(bounds, top, right, bottom, left)`로
  /// 여백을 받는다. 우리가 1인자짜리로만 선언해둬서 그 기능을 못 쓰고 있었다.
  ///
  /// 여백이 필요한 이유 — 지도 위에 하단 시트가 얹히면 지도 영역의 아래쪽이
  /// 가려진다. 여백 없이 맞추면 대상이 **가려진 부분의 한가운데**로 간다.
  ///
  /// 같은 이름의 JS 함수를 Dart에서 두 이름으로 부른다. Dart는 이름이 같은
  /// 메서드를 두 번 선언할 수 없지만, @JS로 실제 JS 이름을 지정하면 된다.
  @JS('setBounds')
  external void setBoundsWithPadding(
    KakaoLatLngBounds bounds,
    int paddingTop,
    int paddingRight,
    int paddingBottom,
    int paddingLeft,
  );
  external void panTo(KakaoLatLng latlng); // ⬅️ 추가 — 부드럽게 이동
  external void setCenter(KakaoLatLng latlng); // ⬅️ 추가 — 즉시 이동
  external void setLevel(int level); // ⬅️ 추가 — 줌 레벨 지정
  external int getLevel(); // ⬅️ 추가 — 현재 줌 레벨 읽기
  external void setMapTypeId(JSAny mapTypeId); // ⬅️ 추가 — 지도/스카이뷰 전환
  external void setDraggable(bool draggable); // ⬅️ 추가 — 드래그 이동 허용/차단
  external void setZoomable(bool zoomable); // ⬅️ 추가 — 휠 확대/축소 허용/차단
}

/// 마커가 찍힐 위치
extension type KakaoMarkerOptions._(JSObject _) implements JSObject {
  external factory KakaoMarkerOptions({
    required KakaoLatLng position,
    KakaoMarkerImage? image, // 커스텀 이미지 지정
  });
}

/// kakao.maps.Marker — 실제 마커 객체
@JS('kakao.maps.Marker')
extension type KakaoMarker._(JSObject _) implements JSObject {
  external factory KakaoMarker(KakaoMarkerOptions options);
  external void setMap(JSAny? map); // 이 지도에 마커를 붙이거나(map 넘김) 떼거나(null 넘김)
  external void setImage(KakaoMarkerImage image); // 커스텀 이미지로 바꾸기
}

/// kakao.maps.LatLngBounds — 여러 좌표를 다 포함하는 사각 영역
@JS('kakao.maps.LatLngBounds')
extension type KakaoLatLngBounds._(JSObject _) implements JSObject {
  external factory KakaoLatLngBounds();
  external void extend(KakaoLatLng latlng); // 이 영역에 좌표 하나 추가
}

/// kakao.maps.event — 이벤트 관련 기능들이 모여있는 창고
@JS('kakao.maps.event.addListener')
external void kakaoAddListener(
  JSAny target, // 이벤트를 감지할 대상 (마커)
  String type, // 이벤트 종류 (예: 'click')
  JSFunction handler, // 이벤트 발생 시 실행할 함수
);

/// kakao.maps.Size — 이미지 크기 표현
@JS('kakao.maps.Size')
extension type KakaoSize._(JSObject _) implements JSObject {
  external factory KakaoSize(num width, num height);
}

/// kakao.maps.MarkerImage — 마커에 쓸 커스텀 이미지
@JS('kakao.maps.MarkerImage')
extension type KakaoMarkerImage._(JSObject _) implements JSObject {
  external factory KakaoMarkerImage(String src, KakaoSize size);
}

/// kakao.maps.CustomOverlay 생성 시 넘겨줄 옵션
extension type KakaoCustomOverlayOptions._(JSObject _) implements JSObject {
  external factory KakaoCustomOverlayOptions({
    required KakaoLatLng position, // 카드가 뜰 좌표
    required JSAny content, // ⬅️ HTML 문자열 대신 진짜 DOM 요소를 넘길 예정
    double? yAnchor, // 카드가 좌표 기준 어느 지점에 붙을지 (1.0 = 좌표 바로 위)
  });
}

/// kakao.maps.CustomOverlay — 지도 위에 얹는 진짜 HTML 카드
@JS('kakao.maps.CustomOverlay')
extension type KakaoCustomOverlay._(JSObject _) implements JSObject {
  external factory KakaoCustomOverlay(KakaoCustomOverlayOptions options);
  external void setMap(JSAny? map); // 지도 넘기면 표시, null 넘기면 제거
}

/// kakao.maps.event.preventMap — 이 클릭/드래그는 지도 자체의 상호작용으로
/// 처리하지 말아달라고 카카오맵에 미리 알려주는 함수
/// (CustomOverlay 안의 버튼 등을 누를 때, 그게 "지도 클릭"으로 오인되는 걸 막음)
@JS('kakao.maps.event.preventMap')
external void kakaoPreventMap();

/// kakao.maps.MapTypeId — 일반 지도 / 스카이뷰 구분 상수
@JS('kakao.maps.MapTypeId.ROADMAP')
external JSAny get kakaoMapTypeRoadmap;

@JS('kakao.maps.MapTypeId.SKYVIEW')
external JSAny get kakaoMapTypeSkyview;

/// kakao.maps.Polygon 생성 시 넘겨줄 옵션
/// path = 경계를 이루는 좌표들을 순서대로 이어놓은 배열
extension type KakaoPolygonOptions._(JSObject _) implements JSObject {
  external factory KakaoPolygonOptions({
    required JSArray<KakaoLatLng> path, // 경계 좌표 배열
    required num strokeWeight, // 테두리 두께(px)
    required String strokeColor, // 테두리 색
    required num strokeOpacity, // 테두리 투명도 0~1
    required String fillColor, // 내부 채움 색
    required num fillOpacity, // 내부 투명도 0~1
  });
}

/// kakao.maps.Polygon — 지도 위에 그려지는 다각형 (행정동 경계용)
@JS('kakao.maps.Polygon')
extension type KakaoPolygon._(JSObject _) implements JSObject {
  external factory KakaoPolygon(KakaoPolygonOptions options);
  external void setMap(JSAny? map); // 지도 넘기면 표시, null 넘기면 제거
}
