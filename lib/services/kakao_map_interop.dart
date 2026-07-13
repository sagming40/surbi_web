// lib/services/kakao_map_interop.dart

import 'dart:js_interop';

/// kakao.maps.LatLng — 위도/경도 좌표 하나를 표현하는 JS 객체
@JS('kakao.maps.LatLng')
extension type KakaoLatLng._(JSObject _) implements JSObject {
  external factory KakaoLatLng(num lat, num lng);
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
