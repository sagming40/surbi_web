// lib/views/explore_page.dart

import 'dart:async'; // Timer — 지도 잠금 자동 해제

import 'package:flutter/gestures.dart'; // PointerDeviceKind — 시트 마우스 드래그 허용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/providers/region_provider.dart';
import 'package:surbi_web/services/kakao_map_view_registry.dart';
import 'package:surbi_web/widgets/explore/explore_panel.dart';
import 'package:surbi_web/widgets/explore/explore_top_bar.dart';
import 'package:surbi_web/widgets/explore/map_controls.dart';

/// 통합 지도 화면 — 기존 Step 1(지역 선택) · 2(업소 지도) · 3(상권 분석)을 하나로
///
/// 8/21 회의 결정에 따른 결과물이다. **지도 하나만 두고** 축척에 따라
/// 보여주는 단위를 바꾼다 — 서울이면 자치구, 구를 고르면 행정동, 동을 고르면
/// 그 동의 업소. 화면을 넘길 때마다 지도를 새로 만들던 비용이 사라진다.
///
/// 만드는 동안에는 기존 `/select`·`/map`을 살려뒀다. 새 화면을 만들면서 기존
/// 화면 둘을 같이 고치면, 문제가 생겼을 때 원인이 셋 중 어디인지 가려낼 수 없다.
/// 새 화면이 두 화면의 기능을 다 갖춘 2026-08-23(Phase 2-B)에 둘을 삭제했고,
/// 지도 인스턴스도 그때 하나로 합쳐졌다.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  /// 좁은 화면에서 패널을 하단 시트로 바꾸는 기준 폭 (기획서 §7.3)
  static const double _wideBreakpoint = 600;

  // 8/24 회의 — 최대치는 상단 바 바로 밑까지 다 덮어도 된다.
  static const double _sheetMax = 1.0;

  // min·mid는 아직 손으로 정한 임시 비율이다.
  // Step 2에서 ExplorePanel이 콘텐츠 높이를 계산해주면 그 값으로 대체된다.
  double _sheetMinFraction = 0.12;
  double _sheetMidFraction = 0.32;

  /// 지금 시트가 셋 중 어디에 가장 가까운지 — ExplorePanel에게
  /// "얼마나 펼쳐졌으니 뭘 보여줄지" 알려주는 값이다.
  SheetLevel _sheetLevel = SheetLevel.mid;

  /// 시트를 코드로 움직이기 위한 손잡이 (탭 → 펼치기/접기)
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  /// 시트가 실제로 움직일 수 있는 세로 공간 (상단 바 높이를 뺀 값).
  /// 좁은 레이아웃이 그려질 때마다 _buildNarrowLayout에서 갱신된다.
  double _sheetAreaHeight = 0;

  /// 지금 지도에 뿌려둔 **샘플** 업소 점 개수 (0이면 배지를 안 띄운다)
  int _sampleDotCount = 0;

  @override
  void initState() {
    super.initState();
    // 지도는 위젯이 화면에 붙고 크기가 잡힌 뒤에야 그릴 수 있다.
    // registry는 "언제 준비됐는지"만 알리고, 무엇을 그릴지는 이 화면이 정한다.
    onMapReady = _syncMapToSelection;
    // 시트 크기가 바뀔 때마다 지금 셋 중 어디에 가장 가까운지 갱신한다.
    _sheetController.addListener(_onSheetSizeChanged);
  }

  @override
  void dispose() {
    // 화면을 떠나면 반드시 해제 — 안 그러면 다음 화면이 이 콜백을 물려받는다
    onMapReady = null;
    // 잠금 이유가 남아 있으면 다음 화면이 잠긴 지도를 물려받는다
    clearMapLocks();
    // 점도 지운다 — 다음 화면이 이 지도를 물려받으면 샘플 점이 따라간다
    clearBusinessDots();
    _sheetController.removeListener(_onSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  // mid·min이 이제 상수가 아니라 매번 값이 갱신되므로 static const로 못 둔다.
  List<double> get _sheetTapCycle => [
    _sheetMidFraction,
    _sheetMax,
    _sheetMinFraction,
  ];

  /// 손잡이를 탭하면 세 자리를 순서대로 순환한다.
  ///
  /// "가장 가까운 다음 자리"처럼 매번 계산하지 않는 이유 — `snap: true`가
  /// 걸려 있어 손을 떼면 시트는 항상 세 자리 중 하나에 정확히 서 있다.
  /// 즉 탭하는 시점엔 애매한 위치가 존재하지 않으므로, 고정 순서로 돌아도
  /// 계산해서 돌리는 것과 결과가 같다 — 그럴 거면 고정 순서가 더 단순하다.
  void _toggleSheet() {
    if (!_sheetController.isAttached) return;

    final current = _sheetController.size;
    final cycle = _sheetTapCycle;
    var closestIndex = 0;
    var closestDistance = double.infinity;
    for (var i = 0; i < cycle.length; i++) {
      final distance = (current - cycle[i]).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }
    final next = cycle[(closestIndex + 1) % cycle.length];

    _sheetController.animateTo(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  /// 손잡이를 손가락으로 직접 끌 때 — 시트 크기를 수동으로 바꾼다.
  ///
  /// `DraggableScrollableSheet`는 원래 "넘겨준 scrollController가 달린
  /// 스크롤 영역"을 당겨야만 크기가 바뀌는데, 손잡이는 이제 그 스크롤 영역
  /// 밖에 있어서 자동으로는 반응하지 않는다. 그래서 손가락이 움직인 만큼을
  /// 직접 계산해서 `jumpTo`로 밀어준다.
  ///
  /// 화면 전체 높이가 아니라 [_sheetAreaHeight](시트가 실제로 차지할 수 있는
  /// 세로 공간, 상단 바 제외)로 나누는 이유 — 상단 바 높이만큼 기준이
  /// 달라지면, 손가락 1px 이동과 시트가 움직이는 비율이 어긋난다.
  void _dragSheetByHandle(DragUpdateDetails details) {
    if (!_sheetController.isAttached || _sheetAreaHeight <= 0) return;

    final deltaFraction = details.delta.dy / _sheetAreaHeight;
    final next = (_sheetController.size - deltaFraction).clamp(
      _sheetMinFraction,
      _sheetMax,
    );
    _sheetController.jumpTo(next);
  }

  /// 손을 떼면 세 자리 중 가장 가까운 곳으로 착 붙인다.
  ///
  /// `jumpTo`는 즉시 이동이라 `snap: true`가 관여할 여지가 없다 —
  /// 그 자동 정렬은 시트 자신의 드래그 인식에만 걸리는 기능이라,
  /// 손잡이를 수동으로 끌 때는 이 정렬을 우리가 직접 해줘야 한다.
  void _snapSheetToNearest() {
    if (!_sheetController.isAttached) return;

    final stops = [_sheetMinFraction, _sheetMidFraction, _sheetMax];
    final current = _sheetController.size;
    final nearest = stops.reduce(
      (a, b) => (current - a).abs() < (current - b).abs() ? a : b,
    );
    _sheetController.animateTo(
      nearest,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  /// 시트 크기가 바뀔 때마다(끌기·탭·자동 스냅 전부 포함) 지금 셋 중
  /// 가장 가까운 자리가 뭔지 계산해서, 바뀌었으면 [_sheetLevel]을 갱신한다.
  /// 이 값이 바로 ExplorePanel에게 "지금 얼마나 펼쳐졌는지"를 알려주는 신호다.
  void _onSheetSizeChanged() {
    if (!_sheetController.isAttached) return;
    final level = _levelForSize(_sheetController.size);
    if (level != _sheetLevel) setState(() => _sheetLevel = level);
  }

  SheetLevel _levelForSize(double size) {
    final candidates = {
      SheetLevel.min: _sheetMinFraction,
      SheetLevel.mid: _sheetMidFraction,
      SheetLevel.max: _sheetMax,
    };
    var closest = SheetLevel.mid;
    var closestDistance = double.infinity;
    candidates.forEach((level, value) {
      final distance = (size - value).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = level;
      }
    });
    return closest;
  }

  /// 지금 선택 상태를 지도에 그대로 반영한다 (지도 준비 시 1회).
  ///
  /// 뒤로 왔다가 다시 들어오면 선택값은 남아 있는데 지도는 새로 만들어진다.
  /// 그때 이 함수가 없으면 지도만 서울 전역으로 리셋돼 선택과 어긋난다.
  Future<void> _syncMapToSelection() async {
    final selection = ref.read(regionNotifierProvider);

    if (selection.selectedGu == null) {
      await drawSeoulOverview(); // 아무것도 안 고른 상태 → 서울 25개 구
      return;
    }

    final regionsInGu = ref.read(regionsByGuProvider(selection.selectedGu));
    await showGu(regionsInGu);
    if (!mounted) return; // 그리는 사이 화면을 떠났으면 중단

    final region = _findSelectedRegion(regionsInGu, selection.regionCode);
    if (region != null) await _showRegionOnMap(region);
  }

  /// 동 하나를 지도에 펼친다 — 확대 → 샘플 업소 점 → 배지 갱신.
  ///
  /// 순서에 의미가 있다. 확대를 먼저 해야 점을 찍는 동안 화면이 이미 그 동을
  /// 비추고 있어 "점이 차오르는" 것으로 보인다. 반대로 하면 엉뚱한 자리에
  /// 점이 깔렸다가 화면이 따라가는 것처럼 보인다.
  Future<void> _showRegionOnMap(Region region) async {
    await focusRegion(region);
    if (!mounted) return;

    final drawn = await drawSampleBusinessDots(region);
    if (!mounted) return;

    setState(() => _sampleDotCount = drawn);
  }

  /// 동에서 빠져나올 때 — 점을 지우고 배지도 내린다
  void _hideRegionOnMap() {
    clearBusinessDots();
    if (_sampleDotCount != 0) setState(() => _sampleDotCount = 0);
  }

  /// 드롭다운 메뉴가 열려 있는 동안 지도의 드래그·휠을 잠근다.
  ///
  /// 메뉴는 Flutter 오버레이, 지도는 Platform View(브라우저 DOM)라
  /// 휠·드래그 이벤트가 양쪽에 이중 전달돼 목록을 스크롤하면 지도가 같이 움직인다.
  void _lockMapWhileMenuOpen(bool isMenuOpen) {
    // 'menu'라는 이유로 잠근다. 패널 터치('panel')와 별개로 관리되므로
    // 한쪽이 풀려도 메뉴가 열려 있는 한 지도는 잠긴 채로 남는다.
    if (isMenuOpen) {
      lockMap('menu');
    } else {
      unlockMap('menu');
    }
  }

  Region? _findSelectedRegion(List<Region> regions, String? code) {
    if (code == null) return null;
    for (final region in regions) {
      if (region.regionCode == code) return region;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 주소(URL) ↔ 선택 상태  — 2026-08-23 · Phase 2-A
  //
  // **주소가 진실이고, RegionSelection은 그 사본이다.**
  //
  // 전에는 선택을 `notifier`에만 담아서, 새로고침하면 날아가고 링크로
  // 공유할 수도 없었다. 브라우저 뒤로가기는 주소만 바꾸는데 상태는 그걸
  // 모르니 화면과 주소가 어긋나기도 했다.
  //
  // 그래서 흐름을 한 방향으로 못박는다:
  //   사용자 조작 → context.go(주소) → 주소가 바뀜 → [_syncSelectionFromUrl]
  //                                   → notifier 갱신 → 화면·지도
  //
  // F5·뒤로가기·붙여넣은 링크도 전부 "주소가 바뀜" 지점으로 들어오므로
  // 따로 처리할 것이 없다. 패널·상단 바는 여전히 notifier만 읽으면 된다.
  // ═══════════════════════════════════════════════════════════

  /// 주소에서 읽은 선택을 상태에 반영한다. `build`에서 매번 호출된다.
  void _syncSelectionFromUrl(RegionSelection current) {
    final params = GoRouterState.of(context).pathParameters;
    final districtCode = params['districtCode'];
    final categoryCode = params['categoryCode'];

    // 코드 길이가 곧 의미다 — 5자리는 구, 8자리는 동.
    // (행정안전부 행정구역 코드가 원래 계층 구조라 앞 5자리가 자치구다)
    String? guName;
    String? regionCode;
    if (districtCode != null && districtCode.length >= 5) {
      guName = ref.read(guCodeToNameProvider)[districtCode.substring(0, 5)];
      if (districtCode.length == 8) regionCode = districtCode;
    }

    if (current.selectedGu == guName &&
        current.regionCode == regionCode &&
        current.categoryCode == categoryCode) {
      return; // 이미 같다 — 건드리면 무한 루프가 된다
    }

    // ⚠️ `build` 도중에 상태를 바꾸면 Riverpod이 예외를 던진다
    //    ("Tried to modify a provider while the widget tree was building").
    //    이번 프레임을 다 그린 뒤로 미룬다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(regionNotifierProvider.notifier)
          .applySelection(
            guName: guName,
            regionCode: regionCode,
            categoryCode: categoryCode,
          );
    });
  }

  /// 선택 조합을 주소 문자열로 만든다. 이 화면의 모든 이동은 여기를 거친다.
  String _pathFor({String? guName, String? regionCode, String? categoryCode}) {
    if (guName == null) return '/explore'; // 서울 전체

    final guCode = ref.read(guNameToCodeProvider)[guName];
    if (guCode == null) return '/explore'; // 있을 수 없지만 방어

    // 동이 정해졌으면 8자리, 아니면 구 5자리
    final districtCode = regionCode ?? guCode;
    if (categoryCode == null) return '/explore/$districtCode';
    return '/explore/$districtCode/$categoryCode';
  }

  /// `‹` 동작 — 선택을 한 단계 되돌린다. 되돌릴 게 없으면 null(비활성).
  ///
  /// 업종은 두 경우 모두 유지한다 — 지역을 바꿔가며 같은 업종을 비교하는 것이
  /// 이 화면의 주 사용 패턴이다.
  VoidCallback? _stepBackAction(RegionSelection selection) {
    if (selection.regionCode != null) {
      // 동 → 구
      return () => context.go(
        _pathFor(
          guName: selection.selectedGu,
          categoryCode: selection.categoryCode,
        ),
      );
    }
    if (selection.selectedGu != null) {
      // 구 → 서울. 업종만 남기고 지역을 다 푸는 주소는 없으므로 루트로 간다.
      return () => context.go('/explore');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final guNameList = ref.watch(guNameListProvider);
    final selection = ref.watch(regionNotifierProvider);

    // 주소가 진실이다 — 화면을 그리기 전에 상태를 주소에 맞춘다.
    // (F5·뒤로가기·링크 진입도 전부 여기로 들어온다)
    _syncSelectionFromUrl(selection);

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
        // 구가 바뀌면 이전 동의 점은 무조건 무효다
        _hideRegionOnMap();
        if (next.selectedGu == null) {
          drawSeoulOverview(); // 구 해제 → 서울 전체로 넓힘
        } else {
          showGu(ref.read(regionsByGuProvider(next.selectedGu)));
        }
      }

      if (previous?.regionCode != next.regionCode) {
        if (next.regionCode == null) {
          // 동만 해제 — 강조를 지우고 **카메라도 방금 전 시야로 되돌린다.**
          // 되돌리지 않으면 목록은 구 전체인데 지도만 아까 그 동에 확대된 채
          // 남는다. 확대(focusRegion)와 복귀는 한 쌍이다.
          clearRegionBoundary();
          restoreBaseView();
          _hideRegionOnMap();
        } else {
          final region = _findSelectedRegion(
            ref.read(regionsByGuProvider(next.selectedGu)),
            next.regionCode,
          );
          if (region != null) _showRegionOnMap(region);
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
              // 상태를 직접 바꾸지 않고 **주소만 바꾼다.**
              // 상태는 주소를 보고 따라온다 (_syncSelectionFromUrl).
              onGuChanged: (guName) {
                // 구를 바꾸면 이전 동은 무효 — regionCode를 넘기지 않는다
                context.go(
                  _pathFor(
                    guName: guName,
                    categoryCode: selection.categoryCode,
                  ),
                );
              },
              onRegionChanged: (region) {
                context.go(
                  _pathFor(
                    guName: region.guName,
                    regionCode: region.regionCode,
                    categoryCode: selection.categoryCode,
                  ),
                );
              },
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= _wideBreakpoint;
                  return isWide
                      ? _buildWideLayout(
                          selection,
                          regionsInGu,
                          selectedRegion,
                          availableWidth: constraints.maxWidth,
                        )
                      : _buildNarrowLayout(
                          selection,
                          regionsInGu,
                          selectedRegion,
                          availableHeight: constraints.maxHeight,
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 넓은 화면 — 좌측 패널 + 지도
  ///
  /// `stretch`를 주는 이유: 기본값(center)이면 자식이 세로로 "필요한 만큼"만
  /// 차지하려 해서, 높이가 정해지지 않은 목록형 위젯이 들어갔을 때 계산이 꼬인다.
  /// score_shell의 2컬럼 레이아웃도 같은 이유로 stretch를 쓴다.
  Widget _buildWideLayout(
    RegionSelection selection,
    List<Region> regionsInGu,
    Region? selectedRegion, {
    required double availableWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 넓은 화면의 좌측 패널은 시트가 아니라 고정 영역이라
        // 스크롤 컨트롤러도 손잡이도 필요 없다
        SizedBox(
          width: _panelWidthFor(availableWidth),
          // 넓은 화면은 잘릴 걱정이 없으니 3단계 개념이 필요 없다 — 항상 max.
          child: _buildPanel(
            selection,
            regionsInGu,
            selectedRegion,
            level: SheetLevel.max,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildMapArea()),
      ],
    );
  }

  /// 넓은 화면에서 좌측 패널이 가져갈 폭.
  ///
  /// 기획서 §7.3의 `600~1200 → 지도 60% + 패널 40%`를 따른다.
  /// 전에는 360 고정이었는데, 그러면 폭 600에서 패널이 60%가 되어
  /// **비율이 정확히 뒤집혔다**(지도 240px). 최대 폭만 보고 정한 값이라
  /// 폭이 줄어드는 구간을 확인하지 않은 실수였다. (2026-08-23 수정)
  ///
  /// 비율만 쓰지 않고 [clamp]로 양 끝을 묶는 이유:
  ///   · 300 미만 → 동 목록·업종 드롭다운이 잘린다
  ///   · 420 초과 → 글줄이 너무 길어져 읽기 나빠지고 지도만 손해다
  double _panelWidthFor(double availableWidth) {
    return (availableWidth * 0.4).clamp(300.0, 420.0);
  }

  /// 좁은 화면 — 지도가 전체를 차지하고 패널은 하단 시트로 올라온다
  Widget _buildNarrowLayout(
    RegionSelection selection,
    List<Region> regionsInGu,
    Region? selectedRegion, {
    required double availableHeight,
  }) {
    _sheetAreaHeight = availableHeight; // 손잡이 드래그 계산에 쓴다

    return Stack(
      children: [
        Positioned.fill(child: _buildMapArea()),
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _sheetMidFraction,
          minChildSize: _sheetMinFraction,
          maxChildSize: _sheetMax,
          // 손을 떼면 가장 가까운 자리로 착 붙는다. 없으면 어중간한 높이에
          // 멈춰 서서 지도도 패널도 제대로 안 보이는 상태가 남는다.
          snap: true,
          snapSizes: [_sheetMinFraction, _sheetMidFraction, _sheetMax],
          builder: (context, scrollController) {
            return _MapLockZone(
              child: Material(
                color: SurbiColors.primary,
                elevation: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SurbiRadius.card),
                ),
                // 손잡이(고정) + 몸통(스크롤) — 형제로 분리해야
                // 목록을 내려도 손잡이가 안 딸려 올라간다.
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleSheet,
                      onVerticalDragUpdate: _dragSheetByHandle,
                      onVerticalDragEnd: (_) => _snapSheetToNearest(),
                      behavior: HitTestBehavior.opaque,
                      child: const SheetHandle(),
                    ),
                    Expanded(
                      // 시트는 '안에 있는 목록을 끄는 힘'으로 움직인다. 그런데 Flutter의
                      // 기본 설정은 데스크톱에서 마우스 드래그를 스크롤로 인정하지 않아
                      // (관습상 휠로만 스크롤) 마우스로는 시트를 아예 끌 수 없다.
                      // 이 시트에 한해서만 마우스도 드래그 장치로 인정한다.
                      // ⚠️ 앱 전체에 걸면 드롭다운 메뉴 등 다른 목록의 조작감까지 바뀐다.
                      child: ScrollConfiguration(
                        behavior: const _SheetScrollBehavior(),
                        child: _buildPanel(
                          selection,
                          regionsInGu,
                          selectedRegion,
                          scrollController: scrollController,
                          // 좁은 화면에서만 패널 안에도 `‹`를 둔다 —
                          // 상단 바까지 손을 올리지 않고 되돌릴 수 있게
                          // (넓은 화면은 넘기지 않으므로 패널에 안 그려진다)
                          onStepBack: _stepBackAction(selection),
                          level: _sheetLevel,
                        ),
                      ),
                    ),
                  ],
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
            child: HtmlElementView(viewType: 'kakao-map-view'),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: MapControls(
              onZoomIn: zoomIn,
              onZoomOut: zoomOut,
              onSkyviewChanged: setMapSkyview,
            ),
          ),
          // 점이 떠 있는 동안에는 **항상** 가짜라는 사실을 함께 띄운다.
          // 이 배지가 없으면 스크린샷 한 장이 "업소 표시 완료"로 읽힌다.
          if (_sampleDotCount > 0)
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: _SampleDataBadge(count: _sampleDotCount),
            ),
        ],
      ),
    );
  }

  /// 패널 하나를 만든다. 넓은 화면과 시트가 **같은 위젯**을 쓴다 —
  /// 담는 그릇만 다르고 내용은 같아야 하므로, 두 벌로 만들면 한쪽만 고치는 사고가 난다.
  Widget _buildPanel(
    RegionSelection selection,
    List<Region> regionsInGu,
    Region? selectedRegion, {
    ScrollController? scrollController,
    VoidCallback? onStepBack,
    required SheetLevel level,
  }) {
    final categories = ref.watch(categoryListProvider);

    return ExplorePanel(
      selectedGu: selection.selectedGu,
      regionsInGu: regionsInGu,
      selectedRegion: selectedRegion,
      categories: categories,
      selectedCategory: _findSelectedCategory(
        categories,
        selection.categoryCode,
      ),
      scrollController: scrollController,
      onStepBack: onStepBack,
      level: level,
      onMenuVisibilityChanged: _lockMapWhileMenuOpen,
      // 상단 바와 마찬가지로 **주소만 바꾼다** — 상태는 주소를 따라온다
      onRegionTap: (region) {
        context.go(
          _pathFor(
            guName: region.guName,
            regionCode: region.regionCode,
            categoryCode: selection.categoryCode,
          ),
        );
      },
      onCategoryChanged: (category) {
        context.go(
          _pathFor(
            guName: selection.selectedGu,
            regionCode: selection.regionCode,
            categoryCode: category['code'],
          ),
        );
      },
      // 동과 업종이 모두 정해져야 점수를 볼 수 있다
      onScoreTap:
          (selection.regionCode != null && selection.categoryCode != null)
          ? () => context.go(
              '/score/${selection.regionCode}/${selection.categoryCode}',
            )
          : null,
    );
  }

  /// 업종 목록에서 code와 일치하는 항목을 찾는다. 없으면 null
  ///
  /// ⚠️ `categoryListProvider`가 `List<Map<String, String>>`이라 이런 헬퍼가 필요하다.
  /// Task 4-3에서 `GET /api/categories`를 붙일 때 `models/category.dart`로 승격시키면
  /// `Region`과 같은 결이 되고 `category['name']!` 같은 느낌표도 사라진다.
  Map<String, String>? _findSelectedCategory(
    List<Map<String, String>> categories,
    String? code,
  ) {
    if (code == null) return null;
    for (final category in categories) {
      if (category['code'] == code) return category;
    }
    return null;
  }
}

/// 지도 위 점이 **샘플**임을 알리는 배지.
///
/// 화면에 이걸 띄우는 것 자체가 목적이다 — 이번 작업의 목표는
/// "업소를 표시했다"가 아니라 **"파이프는 다 깔았으니 데이터만 주세요"**를
/// 팀에 보여주는 것이다. 배지를 빼면 스크린샷이 정반대 메시지가 된다.
///
/// 개수도 같이 적는다. 그래야 BE가 "동 하나에 이 정도면 잘라서 줘야겠다"를
/// 판단할 수 있다.
class _SampleDataBadge extends StatelessWidget {
  final int count;

  const _SampleDataBadge({required this.count});

  /// 1265 → "1,265". 뒤에서 세 자리마다 쉼표를 넣는다.
  /// (intl의 NumberFormat을 쓸 수도 있지만, 배지 하나 때문에 로케일 초기화를
  ///  끌어오는 것보다 이 편이 가볍다)
  static String _withComma(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // 지도 위라 반투명은 금물 — 뒤에 점이 비치면 글자를 못 읽는다
          color: SurbiColors.accent,
          borderRadius: BorderRadius.circular(SurbiRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '샘플 좌표 ${_withComma(count)}개 · '
                '실제 업소 537,488건은 GET /api/businesses 연동 대기 중',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 마우스 드래그로도 스크롤(=시트 끌기)이 되게 하는 스크롤 규칙.
///
/// Flutter의 기본값은 데스크톱에서 **마우스를 드래그 장치로 인정하지 않는다** —
/// 데스크톱에서는 목록을 잡아끄는 대신 휠로 스크롤하는 것이 관습이기 때문이다.
/// 하지만 하단 시트는 '잡아서 끌어올리는' 것이 유일한 조작법이라 예외가 필요하다.
///
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

/// 이 위젯을 만지는 동안 지도의 드래그·휠을 잠근다.
///
/// **왜 필요한가** — 지도는 Flutter가 캔버스에 그린 그림이 아니라 진짜 브라우저
/// DOM(Platform View)이다. 그 위에 얹힌 Flutter 위젯을 클릭하는 건 되지만,
/// 드래그·휠은 지도 DOM의 리스너가 물고 늘어져 지도가 대신 움직인다.
/// (2026-07-08 이슈 문서 "시도 3 — 패널을 드래그하면 지도가 터치를 가로챈다"와 동일)
///
/// 이벤트를 역추적하는 대신 카카오맵의 `setDraggable`/`setZoomable`로
/// **지도 쪽을 잠가서** 경쟁 자체를 없앤다. (2026-07-20 드롭다운과 같은 해법)
///
/// ⚠️ **`MouseRegion`을 쓰지 말 것.** 지도(Platform View) 위에서는
/// `onEnter`/`onExit`가 불리지 않는다. 같은 이유로 커서 모양도 안 바뀐다.
/// 원시 포인터 이벤트를 받는 `Listener`는 정상 동작하므로 이쪽만 쓴다.
/// (2026-08-21 — 드래그는 되는데 휠 스크롤에서만 지도가 움직이던 원인)
///
/// 잠금을 **타이머로 푸는** 이유: 휠은 '끝'을 알리는 이벤트가 없다.
/// 만질 때마다 잠그고 해제 예약을 미루면, 손을 뗀 뒤에만 풀린다.
class _MapLockZone extends StatefulWidget {
  final Widget child;

  const _MapLockZone({required this.child});

  @override
  State<_MapLockZone> createState() => _MapLockZoneState();
}

class _MapLockZoneState extends State<_MapLockZone> {
  /// 이 잠금의 이름. 드롭다운 메뉴('menu')와 별개로 관리되어야 한다 —
  /// 하나의 스위치를 공유하면 먼저 푼 쪽이 다른 쪽의 잠금까지 풀어버린다.
  static const String _reason = 'panel';

  Timer? _unlockTimer;

  /// 만졌다 — 지도를 잠그고, 잠시 뒤 자동으로 풀도록 예약한다.
  /// 계속 만지는 동안에는 예약이 계속 미뤄지므로 잠금이 유지된다.
  void _touch([_]) {
    _unlockTimer?.cancel();
    lockMap(_reason);
    _unlockTimer = Timer(
      const Duration(milliseconds: 300),
      () => unlockMap(_reason),
    );
  }

  @override
  void dispose() {
    // 화면을 떠날 때 지도가 잠긴 채로 남지 않도록 (2026-07-20에 배운 것)
    _unlockTimer?.cancel();
    unlockMap(_reason);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _touch, // 마우스가 위를 지나갈 때
      onPointerDown: _touch,
      onPointerMove: _touch,
      onPointerSignal: _touch, // 휠 스크롤
      onPointerUp: _touch,
      onPointerCancel: _touch,
      child: widget.child,
    );
  }
}
