// lib/services/kakao_map_view_registry.dart

import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'dart:js_interop'; // 추가!
import 'kakao_map_interop.dart'; // 추가!
import '../models/building.dart';

// ⬇️ 추가 — 지도 객체 전역 변수
KakaoMap? kakaoMapInstance;

// ⬇️ 추가 — 마커 Tap시 바깥에서 실행할 함수
void Function(Building building)? onBuildingMarkerTap;

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

// ⬇️ 새로 추가 — 건물 목록을 받아서 마커로 찍어주는 함수
Future<void> addBuildingMarkers(List<Building> buildings) async {
  final map = kakaoMapInstance;
  if (map == null) return; // 지도가 아직 안 만들어졌으면 그냥 종료 (방어 코드)
  if (buildings.isEmpty) return; // 건물이 하나도 없으면 그냥 종료 (방어 코드)

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

  for (final building in buildings) {
    final position = KakaoLatLng(building.lat, building.lng);

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
        onBuildingMarkerTap?.call(building);
      }).toJS,
    );

    bounds.extend(position);
  }

  map.setBounds(bounds);
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
