// lib/views/explore_page.dart

import 'package:flutter/gestures.dart'; // PointerDeviceKind — 시트 마우스 드래그 허용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/providers/region_provider.dart';
import 'package:surbi_web/services/kakao_map_view_registry.dart';
import 'package:surbi_web/widgets/explore/explore_top_bar.dart';
import 'package:surbi_web/widgets/explore/map_controls.dart';

/// 통합 지도 화면 — 기존 Step 1(지역 선택) · 2(업소 지도) · 3(상권 분석)을 하나로
///
/// 8/21 회의 결정에 따른 Phase 1 결과물이다. **지도 하나만 두고** 축척에 따라
/// 보여주는 단위를 바꾼다 — 서울이면 자치구, 구를 고르면 행정동, 동을 고르면
/// 그 동의 업소. 화면을 넘길 때마다 지도를 새로 만들던 비용이 사라진다.
///
/// ⚠️ Phase 1 동안에는 기존 `/select`·`/map` 화면을 **그대로 둔다.**
/// 새 화면을 만들면서 기존 화면 둘을 같이 고치면, 문제가 생겼을 때 원인이
/// 셋 중 어디인지 가려낼 수 없다. 라우팅을 옮기고 기존 화면을 지우는 것은 Phase 2.
///
/// ⚠️ 지도 인스턴스는 아직 `kakaoMapInstanceStep1` 하나를 빌려 쓴다.
/// 기존 화면을 지우는 순간 자연히 이 하나만 남는다.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  /// 좁은 화면에서 패널을 하단 시트로 바꾸는 기준 폭 (기획서 §7.3)
  static const double _wideBreakpoint = 600;

  // 하단 시트가 멈춰 서는 세 자리 (화면 높이 대비 비율).
  // 상수로 빼둔 이유: 초기 높이·스냅 위치·탭 동작이 **같은 값을 공유**해야
  // "끌었을 때 서는 자리"와 "탭했을 때 가는 자리"가 어긋나지 않는다.
  static const double _sheetMin = 0.15; // 손잡이만 보이는 상태
  static const double _sheetMid = 0.28; // 기본 — 요약 몇 줄이 보이는 정도
  static const double _sheetMax = 0.85; // 펼침 — 지도는 위쪽만 남음

  /// 시트를 코드로 움직이기 위한 손잡이 (탭 → 펼치기/접기)
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    // 지도는 위젯이 화면에 붙고 크기가 잡힌 뒤에야 그릴 수 있다.
    // registry는 "언제 준비됐는지"만 알리고, 무엇을 그릴지는 이 화면이 정한다.
    onStep1MapReady = _syncMapToSelection;
  }

  @override
  void dispose() {
    // 화면을 떠나면 반드시 해제 — 안 그러면 다음 화면이 이 콜백을 물려받는다
    onStep1MapReady = null;
    _sheetController.dispose();
    super.dispose();
  }

  /// 손잡이를 탭하면 펼치거나 접는다.
  ///
  /// Flutter는 이 동작을 기본 제공하지 않는다 — `DraggableScrollableSheet`는
  /// 이름 그대로 '끄는 것'만 한다. 지도 앱들이 탭으로 펼쳐지는 건 각자 구현한 것이다.
  ///
  /// 어디로 갈지는 **지금 위치가 위쪽인지 아래쪽인지**로 정한다. 고정된 두 자리를
  /// 번갈아 가게 하면, 사용자가 손으로 중간까지 끌어둔 상태에서 탭했을 때
  /// 엉뚱한 방향으로 움직인다.
  void _toggleSheet() {
    // 시트가 화면에 없을 때(넓은 화면) 호출되면 size 접근이 예외를 던진다
    if (!_sheetController.isAttached) return;

    final isMostlyOpen = _sheetController.size > (_sheetMid + _sheetMax) / 2;
    _sheetController.animateTo(
      isMostlyOpen ? _sheetMid : _sheetMax,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  /// 지금 선택 상태를 지도에 그대로 반영한다 (지도 준비 시 1회).
  ///
  /// 뒤로 왔다가 다시 들어오면 선택값은 남아 있는데 지도는 새로 만들어진다.
  /// 그때 이 함수가 없으면 지도만 서울 전역으로 리셋돼 선택과 어긋난다.
  Future<void> _syncMapToSelection() async {
    final selection = ref.read(regionNotifierProvider);

    if (selection.selectedGu == null) {
      await drawSeoulOverviewStep1(); // 아무것도 안 고른 상태 → 서울 25개 구
      return;
    }

    final regionsInGu = ref.read(regionsByGuProvider(selection.selectedGu));
    await showGuOnStep1(regionsInGu);
    if (!mounted) return; // 그리는 사이 화면을 떠났으면 중단

    final region = _findSelectedRegion(regionsInGu, selection.regionCode);
    if (region != null) await focusRegionStep1(region);
  }

  /// 드롭다운 메뉴가 열려 있는 동안 지도의 드래그·휠을 잠근다.
  ///
  /// 메뉴는 Flutter 오버레이, 지도는 Platform View(브라우저 DOM)라
  /// 휠·드래그 이벤트가 양쪽에 이중 전달돼 목록을 스크롤하면 지도가 같이 움직인다.
  void _lockMapWhileMenuOpen(bool isMenuOpen) {
    setMapInteractiveStep1(!isMenuOpen);
  }

  Region? _findSelectedRegion(List<Region> regions, String? code) {
    if (code == null) return null;
    for (final region in regions) {
      if (region.regionCode == code) return region;
    }
    return null;
  }

  /// `‹` 동작 — 선택을 한 단계 되돌린다. 되돌릴 게 없으면 null(비활성).
  VoidCallback? _stepBackAction(RegionSelection selection) {
    final notifier = ref.read(regionNotifierProvider.notifier);
    if (selection.regionCode != null) return notifier.clearRegion; // 동 → 구
    if (selection.selectedGu != null) return notifier.clearGu; // 구 → 서울
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final guNameList = ref.watch(guNameListProvider);
    final selection = ref.watch(regionNotifierProvider);
    final regionsInGu = ref.watch(regionsByGuProvider(selection.selectedGu));
    final selectedRegion = _findSelectedRegion(
      regionsInGu,
      selection.regionCode,
    );

    // 선택이 바뀔 때마다 지도를 따라가게 한다.
    // 해제(null)도 하나의 상태이므로 반드시 분기해야 한다 —
    // 구를 해제했는데 빈 목록으로 다시 그리면 지도가 텅 비어버린다.
    ref.listen<RegionSelection>(regionNotifierProvider, (previous, next) {
      if (previous?.selectedGu != next.selectedGu) {
        if (next.selectedGu == null) {
          drawSeoulOverviewStep1(); // 구 해제 → 서울 전체로 넓힘
        } else {
          showGuOnStep1(ref.read(regionsByGuProvider(next.selectedGu)));
        }
      }

      if (previous?.regionCode != next.regionCode) {
        if (next.regionCode == null) {
          // 동만 해제 — 카메라는 구 전체 시야 그대로 두고 강조만 지운다
          clearRegionBoundaryStep1();
        } else {
          final region = _findSelectedRegion(
            ref.read(regionsByGuProvider(next.selectedGu)),
            next.regionCode,
          );
          if (region != null) focusRegionStep1(region);
        }
      }
    });

    return Scaffold(
      backgroundColor: SurbiColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            ExploreTopBar(
              guNameList: guNameList,
              regionsInGu: regionsInGu,
              selectedGu: selection.selectedGu,
              selectedRegion: selectedRegion,
              onStepBack: _stepBackAction(selection),
              onMenuVisibilityChanged: _lockMapWhileMenuOpen,
              onGuChanged: (guName) {
                ref.read(regionNotifierProvider.notifier).selectGu(guName);
              },
              onRegionChanged: (region) {
                ref
                    .read(regionNotifierProvider.notifier)
                    .selectRegion(region.regionCode);
              },
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= _wideBreakpoint;
                  return isWide ? _buildWideLayout() : _buildNarrowLayout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 넓은 화면 — 좌측 고정 패널 + 지도
  ///
  /// `stretch`를 주는 이유: 기본값(center)이면 자식이 세로로 "필요한 만큼"만
  /// 차지하려 해서, 높이가 정해지지 않은 목록형 위젯이 들어갔을 때 계산이 꼬인다.
  /// score_shell의 2컬럼 레이아웃도 같은 이유로 stretch를 쓴다.
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 넓은 화면의 좌측 패널은 시트가 아니라 고정 영역이라
        // 스크롤 컨트롤러도 손잡이도 필요 없다
        SizedBox(width: 360, child: _buildPanelPlaceholder(null)),
        const VerticalDivider(width: 1),
        Expanded(child: _buildMapArea()),
      ],
    );
  }

  /// 좁은 화면 — 지도가 전체를 차지하고 패널은 하단 시트로 올라온다
  Widget _buildNarrowLayout() {
    return Stack(
      children: [
        Positioned.fill(child: _buildMapArea()),
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _sheetMid,
          minChildSize: _sheetMin,
          maxChildSize: _sheetMax,
          // 손을 떼면 가장 가까운 자리로 착 붙는다. 없으면 어중간한 높이에
          // 멈춰 서서 지도도 패널도 제대로 안 보이는 상태가 남는다.
          snap: true,
          snapSizes: const [_sheetMin, _sheetMid, _sheetMax],
          builder: (context, scrollController) {
            return _MapLockZone(
              child: Material(
                color: SurbiColors.primary,
                elevation: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SurbiRadius.card),
                ),
                // 시트는 '안에 있는 목록을 끄는 힘'으로 움직인다. 그런데 Flutter의
                // 기본 설정은 데스크톱에서 마우스 드래그를 스크롤로 인정하지 않아
                // (관습상 휠로만 스크롤) 마우스로는 시트를 아예 끌 수 없다.
                // 이 시트에 한해서만 마우스도 드래그 장치로 인정한다.
                // ⚠️ 앱 전체에 걸면 드롭다운 메뉴 등 다른 목록의 조작감까지 바뀐다.
                child: ScrollConfiguration(
                  behavior: const _SheetScrollBehavior(),
                  child: _buildPanelPlaceholder(
                    scrollController,
                    showHandle: true,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// ⚠️ `ClipRect`를 빼지 말 것.
  ///
  /// 지도는 Flutter가 그린 그림이 아니라 브라우저 DOM(Platform View)이라,
  /// 자기 영역 밖으로 넘치면 옆에 있는 Flutter UI 위를 그대로 덮는다.
  /// 기존 `/select` 화면이 멀쩡했던 건 둥근 모서리를 주려고 넣은
  /// `Container(clipBehavior: Clip.antiAlias)`가 우연히 울타리 역할을 했기 때문이다.
  /// 여기서는 둥근 모서리가 필요 없으므로 클립만 명시적으로 남긴다.
  /// (registry의 `overflow: hidden`과 함께 이중으로 막는다 — 2026-08-21)
  Widget _buildMapArea() {
    return ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(
            child: HtmlElementView(viewType: 'kakao-map-view-step1'),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: MapControls(
              onZoomIn: zoomInStep1,
              onZoomOut: zoomOutStep1,
              onSkyviewChanged: setMapSkyviewStep1,
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1-B에서 실제 내용(안내 / 동 목록 / 동 요약 + 업종 + 블러 카드)으로 교체된다.
  ///
  /// 하단 시트로 쓸 때는 시트가 준 [scrollController]를 넘겨야 내용을 끌어올릴 수 있다.
  /// [showHandle]은 시트일 때만 true — 손잡이를 **목록 안에** 두는 것이 중요하다.
  /// 시트는 목록의 드래그로 움직이므로, 목록 바깥에 둔 손잡이는 잡아도 반응이 없다.
  /// (가장 잡고 싶게 생긴 자리가 유일하게 안 되는 자리가 되어버린다)
  Widget _buildPanelPlaceholder(
    ScrollController? scrollController, {
    bool showHandle = false,
  }) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        if (showHandle) _SheetHandle(onTap: _toggleSheet),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: SurbiColors.accentTint,
                borderRadius: BorderRadius.circular(SurbiRadius.card),
              ),
              child: const Text(
                '패널 자리\n(Step 1-B에서 채웁니다)',
                textAlign: TextAlign.center,
                style: TextStyle(color: SurbiColors.accent, height: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 마우스 드래그로도 스크롤(=시트 끌기)이 되게 하는 스크롤 규칙.
///
/// Flutter의 기본값은 데스크톱에서 **마우스를 드래그 장치로 인정하지 않는다** —
/// 데스크톱에서는 목록을 잡아끄는 대신 휠로 스크롤하는 것이 관습이기 때문이다.
/// 하지만 하단 시트는 '잡아서 끌어올리는' 것이 유일한 조작법이라 예외가 필요하다.
///
/// 하단 시트 손잡이 — 끌 수도 있고 탭할 수도 있다.
///
/// 보이는 막대는 44×4로 얇지만, 실제로 누를 수 있는 영역은 위아래 여백까지
/// 포함해 24px 정도로 잡는다. **보이는 크기와 누를 수 있는 크기는 달라도 된다** —
/// 손가락이나 커서가 정확히 4px 막대를 맞히길 기대하면 안 된다.
class _SheetHandle extends StatelessWidget {
  final VoidCallback onTap;

  const _SheetHandle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // 누를 수 있다는 걸 커서로 알림
      child: GestureDetector(
        onTap: onTap,
        // 투명한 영역도 탭을 받도록 — 없으면 막대 픽셀만 반응한다
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 24,
          child: Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: SurbiColors.placeholderGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 이 규칙은 `ScrollConfiguration`으로 시트에만 씌운다. 앱 전체에 걸면
/// 드롭다운 메뉴처럼 휠로 쓰는 목록까지 조작감이 달라진다.
class _SheetScrollBehavior extends MaterialScrollBehavior {
  const _SheetScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

/// 이 위젯 위에 손이 올라와 있는 동안 지도의 드래그·휠을 잠근다.
///
/// **왜 필요한가** — 지도는 Flutter가 캔버스에 그린 그림이 아니라 진짜 브라우저
/// DOM(Platform View)이다. 그 위에 얹힌 Flutter 위젯을 **클릭**하는 건 되지만,
/// **드래그**는 `mousedown` 뒤에 이어지는 `mousemove`를 지도 DOM의 리스너가
/// 물고 늘어져 지도가 대신 움직여 버린다.
/// (2026-07-08 이슈 문서 "시도 3 — 패널을 드래그하면 지도가 터치를 가로챈다"와 동일)
///
/// 이벤트가 어디로 가는지 역추적하는 대신, 카카오맵이 제공하는 `setDraggable`/
/// `setZoomable`로 **지도 쪽을 잠가서** 경쟁 자체를 없앤다.
/// SurbiDropdown 메뉴가 열린 동안 지도를 잠그는 것(2026-07-20)과 같은 해법이다.
///
/// 마우스(hover)와 터치(pointer)를 둘 다 받는 이유: 터치 기기에는 hover가 없고,
/// 마우스는 누르기 전에 이미 위에 올라와 있어 hover가 더 빨리 잠근다.
class _MapLockZone extends StatelessWidget {
  final Widget child;

  const _MapLockZone({required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setMapInteractiveStep1(false),
      onExit: (_) => setMapInteractiveStep1(true),
      child: Listener(
        onPointerDown: (_) => setMapInteractiveStep1(false),
        onPointerUp: (_) => setMapInteractiveStep1(true),
        onPointerCancel: (_) => setMapInteractiveStep1(true),
        child: child,
      ),
    );
  }
}
