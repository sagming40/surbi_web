// lib/views/step3_map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/providers/building_provider.dart';
import 'package:surbi_web/services/kakao_map_view_registry.dart';

class Step3MapPage extends ConsumerStatefulWidget {
  final String regionCode;

  const Step3MapPage({super.key, required this.regionCode});

  @override
  ConsumerState<Step3MapPage> createState() => _Step3MapPageState();
}

class _Step3MapPageState extends ConsumerState<Step3MapPage> {
  @override
  void initState() {
    super.initState();

    onBuildingMarkerTap = (building) {
      ref.read(selectedBuildingProvider.notifier).state = building;
      showBuildingOverlay(building); // ⭐ BottomSheet 대신 오버레이 카드
    };

    onBuildingDetailTap = (building) {
      closeBuildingOverlay(); // ⭐ Step4로 넘어가기 전에 카드부터 닫음
      context.push('/step4/${building.buildingId}');
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final buildings = ref.read(buildingsProvider);
      addBuildingMarkers(buildings);
    });
  }

  @override
  void dispose() {
    onBuildingMarkerTap = null;
    onBuildingDetailTap = null; // ⭐ 추가
    super.dispose();
  }

  // ⬇️⬇️⬇️ 여기서부터 바뀐 부분 ⬇️⬇️⬇️

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1층 — 지도, 화면 전체를 그대로 채움
          const HtmlElementView(viewType: 'kakao-map-view'),

          // 2층 — 지도 위에 동동 뜨는 원형 뒤로가기 버튼
          Positioned(top: 16, left: 16, child: _buildBackButton(context)),
        ],
      ),
    );
  }

  // ⭐ 새로 추가된 메서드
  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/step2/${widget.regionCode}');
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.chevron_left_rounded, // ⭐ rounded 버전으로 교체
            color: Color(0xFF1E3A5F),
            size: 32,
          ),
        ),
      ),
    );
  }
}
