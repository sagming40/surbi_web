// lib/views/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/providers/business_provider.dart';
import 'package:surbi_web/providers/region_provider.dart';
import 'package:surbi_web/services/kakao_map_view_registry.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';

class MapPage extends ConsumerStatefulWidget {
  final String regionCode;
  final String categoryCode;

  const MapPage({
    super.key,
    required this.regionCode,
    required this.categoryCode,
  });

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  // 하단 바에서 사용자가 고른 값 (URL 파라미터와 별개로 화면 안에서만 관리)
  String? _selectedGu;
  Region? _selectedRegion;
  bool _isSkyview = false;

  /// 화면 이동 시 쓸 행정동 코드 — 드롭다운으로 바꿨으면 그 값 우선
  String get _currentRegionCode =>
      _selectedRegion?.regionCode ?? widget.regionCode;

  @override
  void initState() {
    super.initState();

    onBusinessMarkerTap = (business) {
      ref.read(selectedBusinessProvider.notifier).state = business;
      showBusinessOverlay(business);
    };

    onBusinessDetailTap = (business) {
      closeBusinessOverlay();
      context.push('/analysis/$_currentRegionCode/${widget.categoryCode}');
    };

    // URL의 :districtCode를 하단 바 초기 선택값으로 복원
    for (final region in ref.read(regionListProvider)) {
      if (region.regionCode == widget.regionCode) {
        _selectedRegion = region;
        _selectedGu = region.guName;
        break;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await addBusinessMarkers(ref.read(businessesProvider));
      if (_selectedRegion != null) {
        await _focusRegion(_selectedRegion!);
      }
    });
  }

  @override
  void dispose() {
    onBusinessMarkerTap = null;
    onBusinessDetailTap = null;
    super.dispose();
  }

  /// 선택된 행정동으로 화면을 맞춤 (2026-08-20 경계 폴리곤 추가)
  ///
  /// ① 경계 폴리곤을 먼저 그려본다 → 성공하면 setBounds가 카메라까지 맞춰줌
  /// ② 실패(경계 데이터 없음)하면 기존 방식(setLevel + panTo)으로 폴백
  /// 두 방식이 동시에 카메라를 건드리면 화면이 두 번 덜컹거리므로 moveCamera로 분리
  Future<void> _focusRegion(Region region) async {
    final drawn = await drawRegionBoundary(region);
    await moveToRegion(region, moveCamera: !drawn);
  }

  /// 드롭다운 메뉴가 열려 있는 동안 지도의 드래그·휠을 잠금 (2026-08-20 추가)
  ///
  /// 메뉴는 Flutter 오버레이라 지도 위에 그려지지만, 휠·드래그 이벤트는
  /// 아래쪽 지도 DOM에도 함께 전달돼 목록을 스크롤하면 지도가 같이 움직였다.
  /// 메뉴가 닫히는 순간 바로 원상복구되므로 평소 지도 조작에는 영향이 없다.
  void _lockMapWhileMenuOpen(bool isMenuOpen) {
    setMapInteractive(!isMenuOpen);
  }

  String _findCategoryName(List<Map<String, String>> categories, String code) {
    for (final category in categories) {
      if (category['code'] == code) return category['name'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final guNameList = ref.watch(guNameListProvider);
    final regionsInGu = ref.watch(regionsByGuProvider(_selectedGu));
    final categoryName = _findCategoryName(
      ref.watch(categoryListProvider),
      widget.categoryCode,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1층 — 지도
          const HtmlElementView(viewType: 'kakao-map-view'),

          // 2층 — 좌상단 컨텍스트 바 (뒤로가기 + 현재 위치)
          Positioned(
            top: 16,
            left: 16,
            child: _buildTopBar(context, categoryName),
          ),

          // 3층 — 우상단 지도 컨트롤
          Positioned(top: 16, right: 16, child: _buildMapControls()),

          // 4층 — 하단 행정동 드롭다운 바
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildBottomBar(context, guNameList, regionsInGu),
          ),
        ],
      ),
    );
  }

  // ── 좌상단 컨텍스트 바 ──────────────────────────
  Widget _buildTopBar(BuildContext context, String categoryName) {
    final regionName = _selectedRegion?.regionName ?? '';
    final guName = _selectedGu ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(SurbiRadius.pill),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/select');
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: SurbiColors.accent,
                  size: 28,
                ),
              ),
            ),
            Text(
              '서울특별시 › $guName › $regionName',
              style: const TextStyle(
                color: SurbiColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SurbiColors.accent,
                borderRadius: BorderRadius.circular(SurbiRadius.pill),
              ),
              child: Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 우상단 지도 컨트롤 ──────────────────────────
  Widget _buildMapControls() {
    return Column(
      children: [
        _buildControlButton(Icons.add, zoomIn),
        const SizedBox(height: 6),
        _buildControlButton(Icons.remove, zoomOut),
        const SizedBox(height: 12),
        _buildControlButton(
          _isSkyview ? Icons.map_outlined : Icons.satellite_alt_outlined,
          () {
            setState(() => _isSkyview = !_isSkyview);
            setMapSkyview(_isSkyview);
          },
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: SurbiColors.accent),
        ),
      ),
    );
  }

  // ── 하단 행정동 드롭다운 바 ──────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    List<String> guNameList,
    List<Region> regionsInGu,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SurbiColors.primary,
            borderRadius: BorderRadius.circular(SurbiRadius.card),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: SurbiDropdown<String>(
                  value: _selectedGu,
                  hintText: '구 선택',
                  items: guNameList,
                  labelBuilder: (gu) => gu,
                  openUpward: true,
                  onMenuVisibilityChanged: _lockMapWhileMenuOpen, // ⬅️ 추가
                  onChanged: (guName) {
                    setState(() {
                      _selectedGu = guName;
                      _selectedRegion = null; // 구가 바뀌면 동 선택 초기화
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SurbiDropdown<Region>(
                  value: _selectedRegion,
                  hintText: '동 선택',
                  items: regionsInGu,
                  labelBuilder: (region) => region.regionName,
                  openUpward: true,
                  onMenuVisibilityChanged: _lockMapWhileMenuOpen, // ⬅️ 추가
                  onChanged: _selectedGu == null
                      ? null
                      : (region) {
                          setState(() => _selectedRegion = region);
                          closeBusinessOverlay();
                          _focusRegion(region); // 경계 폴리곤 + 지도 이동 + 강조 마커
                        },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectedRegion == null
                    ? null
                    : () => context.push(
                        '/analysis/$_currentRegionCode/${widget.categoryCode}',
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SurbiColors.accent,
                  disabledBackgroundColor: SurbiColors.placeholderGray,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SurbiRadius.pill),
                  ),
                ),
                child: const Text(
                  '상권 분석 →',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
