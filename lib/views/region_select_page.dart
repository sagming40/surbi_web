import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/models/region.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/providers/region_provider.dart';
import 'package:surbi_web/widgets/common/surbi_dropdown.dart';
import 'package:surbi_web/services/kakao_map_view_registry.dart'; // ⭐ 추가

/// Step 1: 지역 및 카테고리 선택 화면
class RegionSelectPage extends ConsumerStatefulWidget {
  const RegionSelectPage({super.key});

  @override
  ConsumerState<RegionSelectPage> createState() => _RegionSelectPageState();
}

class _RegionSelectPageState extends ConsumerState<RegionSelectPage> {
  @override
  void initState() {
    super.initState();
    // 지도가 준비되면 "지금 선택 상태"를 반영해달라고 등록해 둔다.
    // ⚠️ ConsumerWidget → ConsumerStatefulWidget으로 바꾼 이유 (2026-08-21)
    //    ref.listen은 '값이 바뀔 때'만 발동한다. 브라우저 뒤로가기로 이 화면에
    //    돌아오면 선택값은 그대로(=변화 없음)인데 지도만 새로 만들어지므로,
    //    listen이 울리지 않아 지도가 초기 화면에 머물렀다.
    //    상태를 화면에 잇는 코드에는 두 축이 모두 필요하다 —
    //    ① 진입 시 1회 동기화(여기) ② 이후 변화 감지(build의 ref.listen)
    onStep1MapReady = _syncMapToSelection;
  }

  @override
  void dispose() {
    onStep1MapReady = null; // 다른 화면이 이 콜백을 물려받지 않도록 반드시 해제
    super.dispose();
  }

  /// 지금 선택 상태를 지도에 그대로 반영한다 (지도 준비 시 1회).
  ///
  /// 서울 전역을 그릴지 특정 구·동을 그릴지 **여기서만** 결정하므로,
  /// 같은 지도를 두 코드가 동시에 건드리는 상황이 생기지 않는다.
  Future<void> _syncMapToSelection() async {
    final selection = ref.read(regionNotifierProvider);

    // 아무것도 안 고른 첫 방문 — 서울 전역 자치구 경계
    if (selection.selectedGu == null) {
      await drawSeoulOverviewStep1();
      return;
    }

    final regionsInGu = ref.read(regionsByGuProvider(selection.selectedGu));
    await showGuOnStep1(regionsInGu);
    if (!mounted) return; // 그리는 사이 화면을 떠났으면 중단

    final region = _findSelectedRegion(regionsInGu, selection.regionCode);
    if (region != null) await focusRegionStep1(region);
  }

  @override
  Widget build(BuildContext context) {
    final guNameList = ref.watch(guNameListProvider);
    final categories = ref.watch(categoryListProvider);
    final selection = ref.watch(regionNotifierProvider);

    // ⭐ 선택 변화를 지도에 반영 (2026-08-20 — 동 선택 반응 추가)
    ref.listen<RegionSelection>(regionNotifierProvider, (previous, next) {
      // ① 구가 바뀌면 — 그 구의 동 경계 전체를 회색으로 깔고(히트맵 밑그림)
      //    이전 동 선택을 지운 뒤 동 마커를 다시 찍음.
      //    세 동작의 순서가 서로 얽혀 있어 showGuOnStep1() 한 함수로 묶음
      //    (기존: clearRegionBoundaryStep1() + addRegionMarkers())
      if (previous?.selectedGu != next.selectedGu) {
        showGuOnStep1(ref.read(regionsByGuProvider(next.selectedGu)));
      }

      // ② 동이 바뀌면 — 그 동의 경계를 칠하고 화면을 맞춤
      //    기존에는 동을 골라도 지도가 아무 반응이 없어, 내가 고른 동이
      //    지도의 어느 핀인지 알 수 없었음
      if (previous?.regionCode != next.regionCode && next.regionCode != null) {
        final region = _findSelectedRegion(
          ref.read(regionsByGuProvider(next.selectedGu)),
          next.regionCode,
        );
        if (region != null) focusRegionStep1(region);
      }
    });

    // 2026-08-20 재설계 — 이 화면은 "고른 것을 확인"하는 곳이 아니라
    // 팀 설계상 "행정동별 점수 히트맵에서 좋은 동을 발견"하는 곳이다.
    // 따라서 지도가 주인공이고, 컨트롤은 위아래로 얇게 물러난다.
    // (기존: 드롭다운 2개 + 칩 10개(4줄) + 높이 300 고정 지도)
    return Scaffold(
      backgroundColor: SurbiColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 분기는 '화면 전체 폭' 기준. 컨트롤 바 자신은 아래에서 760으로 제한되므로
            // 바 내부 폭으로 재면 이 기준값이 절대 나오지 않는다.
            //
            // 700인 근거: 화면 700 → 컨트롤 바 668 → 3분할 시 한 칸 214px.
            // 드롭다운 내부 여백 32 + 화살표 24를 빼면 텍스트에 158px이 남고,
            // 가장 긴 라벨 '호프-간이주점'(7글자 ≈ 98px)이 여유 있게 들어간다.
            // 다른 화면(score_shell)의 900은 2컬럼 기준이라 여기와 목적이 다르다.
            final isWide = constraints.maxWidth >= 700;

            return Column(
              children: [
                _buildControlBar(ref, guNameList, categories, selection, isWide),
                // 지도가 남는 세로를 전부 가져간다 (기존 height: 300 고정 폐지)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMapArea(ref, selection, categories),
                  ),
                ),
                _buildStartButton(context, selection),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 상단 컨트롤 바 — `[구▾] [동▾] [업종▾]`
  ///
  /// 지도는 화면 전체를 쓰되 컨트롤만 760으로 묶는다. 업소 지도(map_page)의
  /// 하단 바와 같은 방식이라, 두 화면을 오갈 때 컨트롤 위치·폭이 유지된다.
  Widget _buildControlBar(
    WidgetRef ref,
    List<String> guNameList,
    List<Map<String, String>> categories,
    RegionSelection selection,
    bool isWide,
  ) {
    final gu = _buildGuDropdown(ref, guNameList, selection);
    final dong = _buildRegionDropdown(ref, selection);
    final category = _buildCategoryDropdown(ref, categories, selection);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: isWide
              // 넓은 화면 — 셋을 한 줄에
              ? Row(
                  children: [
                    Expanded(child: gu),
                    const SizedBox(width: 12),
                    Expanded(child: dong),
                    const SizedBox(width: 12),
                    Expanded(child: category),
                  ],
                )
              // 좁은 화면 — 구·동은 "지역"이라는 한 질문이라 묶고,
              // 업종은 별개의 질문이자 라벨이 길어 한 줄을 다 쓴다
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: gu),
                        const SizedBox(width: 12),
                        Expanded(child: dong),
                      ],
                    ),
                    const SizedBox(height: 12),
                    category,
                  ],
                ),
        ),
      ),
    );
  }

  /// 드롭다운 메뉴가 열려 있는 동안 Step 1 지도의 드래그·휠을 잠금 (2026-08-20 추가)
  ///
  /// 메뉴는 Flutter 오버레이, 지도는 Platform View라 휠·드래그 이벤트가 양쪽에
  /// 이중 전달돼 목록을 스크롤하면 지도가 같이 움직였다. 업소 지도와 동일한 처리이나
  /// Step 1은 지도 인스턴스가 별개(kakaoMapInstanceStep1)라 전용 함수를 쓴다.
  void _lockMapWhileMenuOpen(bool isMenuOpen) {
    setMapInteractiveStep1(!isMenuOpen);
  }

  /// regions 목록에서 code와 일치하는 Region을 찾아 반환.
  /// 없으면 null — collection 패키지의 firstOrNull 대신 기본 문법으로 직접 구현
  /// (pubspec.yaml에 collection이 정식 등록돼 있지 않아, 이 작업만으로 의존성을
  ///  새로 추가하지 않기 위한 선택)
  Region? _findSelectedRegion(List<Region> regions, String? code) {
    if (code == null) return null;
    for (final region in regions) {
      if (region.regionCode == code) return region;
    }
    return null;
  }

  /// 업종 목록에서 code와 일치하는 항목을 찾아 반환. 없으면 null
  ///
  /// ⚠️ categoryListProvider가 `List<Map<String, String>>`이라 이런 헬퍼가 필요하다.
  /// Task 4-3에서 `GET /api/categories`를 붙일 때 `models/category.dart`로
  /// 승격시키면 `Region`과 같은 결이 되고 `category['name']!` 같은 느낌표도 사라진다.
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

  /// 구 드롭다운
  Widget _buildGuDropdown(
    WidgetRef ref,
    List<String> guNameList,
    RegionSelection selection,
  ) {
    return SurbiDropdown<String>(
      value: selection.selectedGu,
      hintText: '구 선택',
      items: guNameList,
      labelBuilder: (gu) => gu,
      onMenuVisibilityChanged: _lockMapWhileMenuOpen,
      onChanged: (guName) {
        ref.read(regionNotifierProvider.notifier).selectGu(guName);
      },
    );
  }

  /// 동 드롭다운 — 구를 고르기 전에는 비활성화(onChanged: null)
  Widget _buildRegionDropdown(WidgetRef ref, RegionSelection selection) {
    final regionsInGu = ref.watch(regionsByGuProvider(selection.selectedGu));
    final selectedRegion = _findSelectedRegion(
      regionsInGu,
      selection.regionCode,
    );

    return SurbiDropdown<Region>(
      value: selectedRegion,
      hintText: '동 선택',
      items: regionsInGu,
      labelBuilder: (region) => region.regionName,
      onMenuVisibilityChanged: _lockMapWhileMenuOpen,
      onChanged: selection.selectedGu == null
          ? null
          : (region) {
              ref
                  .read(regionNotifierProvider.notifier)
                  .selectRegion(region.regionCode);
            },
    );
  }

  /// 업종 드롭다운 (2026-08-20 — 칩 10개 Wrap을 대체)
  ///
  /// 기존에는 카테고리만 `Wrap` + `GestureDetector` 커스텀 칩이었다. 구·동·업종은
  /// 모두 동등한 필수 선택인데 하나만 생김새가 달라 위계가 어긋났고, 칩 4줄이
  /// 세로를 잡아먹어 지도가 300px밖에 못 썼다. 셋을 같은 문법으로 통일하면서
  /// 커스텀 코드 40여 줄이 `SurbiDropdown` 재사용으로 수렴했다.
  Widget _buildCategoryDropdown(
    WidgetRef ref,
    List<Map<String, String>> categories,
    RegionSelection selection,
  ) {
    return SurbiDropdown<Map<String, String>>(
      value: _findSelectedCategory(categories, selection.categoryCode),
      hintText: '업종 선택',
      items: categories,
      labelBuilder: (category) => category['name']!,
      onMenuVisibilityChanged: _lockMapWhileMenuOpen,
      onChanged: (category) {
        ref
            .read(regionNotifierProvider.notifier)
            .selectCategory(category['code']!);
      },
    );
  }

  /// 분석 시작 버튼 — 지역·카테고리 모두 선택돼야 활성화
  Widget _buildStartButton(BuildContext context, RegionSelection selection) {
    final isReady =
        selection.regionCode != null && selection.categoryCode != null;

    // 컨트롤 바와 같은 760 폭에 맞춰, 초대형 모니터에서 버튼이 화면을
    // 가로지르지 않도록 제한한다
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isReady
                  ? () {
                      // 새 플로우: 선택 → 지도 → 분석 → 점수
                      // go 사용 — push는 Flutter Web에서 주소창을 갱신하지 않음
                      // (go_router 8.0+ 동작. 상세는 DEVLOG 미해결 7번 참조)
                      context.go(
                        '/map/${selection.regionCode}/${selection.categoryCode}',
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SurbiColors.accent,
                disabledBackgroundColor: SurbiColors.placeholderGray,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SurbiRadius.pill),
                ),
              ),
              child: Text(
                '분석 시작 →',
                style: TextStyle(
                  color: isReady ? Colors.white : SurbiColors.textGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 지역 지도 영역 — Kakao 지도 + 현재 선택 상태 배지
  ///
  /// 2026-08-20 — 선택(구/동/업종)이 지도에 아무 흔적을 남기지 않아
  /// "내가 뭘 고른 상태인지" 알 수 없던 문제를 배지로 해소.
  /// TODO: 점수 기반 색칠 히트맵은 별도 구현 예정 (Task 4-3)
  Widget _buildMapArea(
    WidgetRef ref,
    RegionSelection selection,
    List<Map<String, String>> categories,
  ) {
    final regionsInGu = ref.watch(regionsByGuProvider(selection.selectedGu));
    final selectedRegion = _findSelectedRegion(
      regionsInGu,
      selection.regionCode,
    );

    // 높이를 주지 않는다 — 바깥 Expanded가 남는 세로를 전부 넘겨준다.
    // (2026-08-20 이전에는 height: 300 고정이라 화면이 커져도 지도가 안 커졌다)
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias, // 모서리를 둥글게 자르되, 내부 지도까지 잘리게 함
      decoration: BoxDecoration(
        color: SurbiColors.placeholderGray,
        borderRadius: BorderRadius.circular(SurbiRadius.card),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: HtmlElementView(viewType: 'kakao-map-view-step1'),
          ),
          // 구를 고르기 전에는 표시할 내용이 없으므로 배지 자체를 띄우지 않음
          if (selection.selectedGu != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildSelectionBadge(
                selection,
                selectedRegion,
                categories,
              ),
            ),
        ],
      ),
    );
  }

  /// 지도 위 선택 상태 배지 — `서울특별시 › 마포구 › 망원1동` + 업종 칩
  ///
  /// 업소 지도(map_page)의 컨텍스트 바와 같은 형태로 맞춰, 두 화면을 오갈 때
  /// 사용자가 같은 정보를 같은 자리에서 읽도록 함.
  Widget _buildSelectionBadge(
    RegionSelection selection,
    Region? selectedRegion,
    List<Map<String, String>> categories,
  ) {
    final parts = <String>['서울특별시'];
    if (selection.selectedGu != null) parts.add(selection.selectedGu!);
    if (selectedRegion != null) parts.add(selectedRegion.regionName);

    final categoryName = _findCategoryName(categories, selection.categoryCode);

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SurbiRadius.pill),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  parts.join(' › '),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SurbiColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (categoryName != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: SurbiColors.accent,
                    borderRadius: BorderRadius.circular(SurbiRadius.pill),
                  ),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 업종 코드로 표시용 이름을 찾음. 선택 전이거나 못 찾으면 null
  String? _findCategoryName(List<Map<String, String>> categories, String? code) {
    if (code == null) return null;
    for (final category in categories) {
      if (category['code'] == code) return category['name'];
    }
    return null;
  }

  // ⛔ _buildCategoryButtons() 삭제 (2026-08-20)
  //    Wrap + GestureDetector 커스텀 칩 10개 → SurbiDropdown 하나로 대체.
  //    자세한 근거는 _buildCategoryDropdown() 주석 참고.
}
