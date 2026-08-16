// lib/views/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/providers/business_provider.dart';
import 'package:surbi_web/services/kakao_map_view_registry.dart';

class MapPage extends ConsumerStatefulWidget {
  final String regionCode;
  final String categoryCode; // ⭐ Phase 1 — /score 이동 시 필요

  const MapPage({
    super.key,
    required this.regionCode,
    required this.categoryCode,
  });

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  void initState() {
    super.initState();

    onBusinessMarkerTap = (business) {
      ref.read(selectedBusinessProvider.notifier).state = business;
      showBusinessOverlay(business); // ⭐ BottomSheet 대신 오버레이 카드
    };

    onBusinessDetailTap = (business) {
      closeBusinessOverlay();
      // 새 플로우: 지도 다음은 점수가 아니라 상권 분석
      context.push('/analysis/${widget.regionCode}/${widget.categoryCode}');
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businesses = ref.read(businessesProvider);
      addBusinessMarkers(businesses);
    });
  }

  @override
  void dispose() {
    onBusinessMarkerTap = null;
    onBusinessDetailTap = null; // ⭐ 추가
    super.dispose();
  }

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
            // 새 플로우: 지도 이전 화면은 분석이 아니라 선택 화면
            context.go('/select');
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF1E3A5F),
            size: 32,
          ),
        ),
      ),
    );
  }
}
