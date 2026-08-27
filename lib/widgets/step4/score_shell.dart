// lib/widgets/step4/score_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/providers/score_provider.dart';
import 'package:surbi_web/views/checklist_page.dart';
import 'package:surbi_web/views/policy_list_page.dart';
import 'package:surbi_web/widgets/common/surbi_accordion_section.dart';
import 'package:surbi_web/widgets/common/surbi_app_bar.dart';
import 'package:surbi_web/widgets/step4/report_page.dart';
import 'package:surbi_web/widgets/step4/score_hub_panel.dart';
import 'package:surbi_web/widgets/step4/shap_bar_chart.dart';

// Step 4 허브 화면 — 게이지 패널(고정) + 3개 형제 탭(report/policies/checklist)
// StatefulShellRoute의 builder에서 반환됨 (Phase 2의 임시 화면을 대체)
//
// 2026-08-27 — 900px 미만(좁은 화면) 쪽을 아코디언으로 재구성했다
// (8/24 회의 지시 ④, 방향 C안). 900px 이상(넓은 화면)은 그대로 둔다 —
// 잘 되고 있던 코드를 오늘 문제와 무관하게 건드릴 이유가 없어서다.
class ScoreShell extends StatelessWidget {
  final String buildingId;
  final String categoryCode; // ⭐ 추가 — 뒤로가기 목적지(/analysis) 조립용
  final StatefulNavigationShell navigationShell;

  const ScoreShell({
    super.key,
    required this.buildingId,
    required this.categoryCode,
    required this.navigationShell,
  });

  /// 넓은 화면에서 **본문 전체**(좌측 요약 + 탭 영역)가 가져갈 최대 폭.
  ///
  ///   340(요약) + 1(구분선) + 859(탭 콘텐츠) = 1200
  ///
  /// 제한하는 이유 — 1920 화면에서 제한이 없으면 본문 한 줄이 1,500px = 한글
  /// 100자를 넘어 눈이 줄 끝에서 다음 줄 시작으로 돌아오지 못한다.
  /// 1200이면 탭 콘텐츠가 859px(한글 약 60자)다. 타이포그래피 권장치(40~50자)보다
  /// 길지만, 실물로 720과 비교했을 때 720은 허전해 1200을 택했다. (2026-08-26)
  ///
  /// ⚠️ **AppBar와 배경은 이 제한 밖에 둔다.** 라우트(ResponsiveLayout)를 좁히면
  /// AppBar까지 가운데 박스에 갇혀 /explore와 어긋난다 (8/24 회의 지시 ③).
  /// 화면 전체를 쓰는 것은 상단 바와 바탕이고, 읽을 것만 가운데로 모은다.
  ///
  /// ⚠️ 좌측 요약을 /explore처럼 화면 끝에 붙이지 않는 이유 — /explore의 좌측
  /// 패널이 벽에 붙는 것은 **지도가 나머지를 다 써야 하기 때문**이다. /score에는
  /// 지도가 없으므로 그 근거가 성립하지 않는다.
  static const double _contentMaxWidth = 1200;

  /// 좁은 화면 아코디언에서 "AI 보고서"·"정부 지원사업"·"체크리스트"를 펼쳤을 때
  /// 줄 내부 스크롤 영역 높이.
  ///
  /// ⚠️ 이 세 섹션만 고정 높이 + 내부 스크롤을 쓰는 이유 — 정부지원 목록은
  /// 필터 없이 전체 표시하며 1,417건(FE_WORKFLOW 확정 사항)이고, AI 보고서도
  /// 생성되는 본문 길이가 늘어날 수 있다. 펼친 만큼 페이지 전체가 늘어나는
  /// 방식(ListView shrinkWrap 등)을 쓰면 정부지원 쪽은 1,417개 카드를 한 번에
  /// 다 그려야 해서(가상화가 무력화됨) 접었다 펼 때마다 버벅인다.
  ///
  /// ⚠️ SHAP만 예외로 높이 제한을 안 둔다 (2026-08-27, 사용자 확인) —
  /// "길이와 무관하게 한눈에 다 보여야 한다"는 요구라, 여기만 그대로
  /// 펼쳐지게(=페이지가 그만큼 길어지게) 둔다.
  static const double _accordionListHeight = 420;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // /explore와 같은 바탕색. 명시하지 않으면 테마 기본값(거의 흰색)이 되어
      // 은백 배경 위의 흰 카드라는 규칙이 이 화면에서만 깨진다.
      backgroundColor: SurbiColors.primary,
      appBar: SurbiAppBar(
        title: 'AI 창업 분석',
        onBackPressed: () {
          // 다음에 다시 들어올 때 보고서 탭부터 시작하도록 초기화
          if (navigationShell.currentIndex != 0) {
            navigationShell.goBranch(0);
          }
          // 뒤로 = 방금 떠나온 지도 화면. go 통일로 스택이 없어 목적지를 직접 지정한다.
          //
          // 2026-08-23 — `/analysis`에서 `/explore`로 변경.
          // 예전 흐름은 `/map → /analysis → /score`라 뒤로가 /analysis가 맞았지만,
          // 통합 화면에서는 `/explore`에서 곧장 여기로 온다. 그대로 두면
          // **가본 적도 없는 화면**으로 되돌아가게 된다.
          //
          // buildingId에는 행정동 코드가 담긴다(라우터 TODO 참고) → 주소가 그대로 맞는다.
          context.go('/explore/$buildingId/$categoryCode');
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          if (isWide) {
            // 900px 이상 ㅡ 좌측 게이지 고정, 우측 탭 콘텐츠만 swap
            return Center(
              child: SizedBox(
                // 창이 _contentMaxWidth보다 좁으면 SizedBox가 부모 제약에 맞춰
                // 알아서 줄어든다 — 따로 min 계산을 하지 않아도 된다.
                width: _contentMaxWidth,
                // ⚠️ 높이를 명시해야 한다. Center는 자식에게 "0~부모높이"로 느슨한
                //    제약을 주는데, 그러면 아래 Row의 stretch가 기댈 높이가 없어지고
                //    ScoreHubPanel(SingleChildScrollView)이 내용만큼 늘어나 넘친다.
                height: constraints.maxHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(width: 340, child: ScoreHubPanel()),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Column(
                        children: [
                          _ScoreTabBar(navigationShell: navigationShell),
                          const Divider(height: 1),
                          Expanded(child: navigationShell),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 900px 미만 ㅡ 아코디언 (2026-08-27, 8/24 회의 지시 ④ · C안)
          return _NarrowAccordionBody(
            buildingId: buildingId,
            accordionListHeight: _accordionListHeight,
          );
        },
      ),
    );
  }
}

// 좁은 화면 본문 — 게이지+예상성과는 항상 펼침(ScoreOverviewHeader),
// SHAP/AI보고서/정부지원/체크리스트 4개는 SurbiAccordionSection으로 접었다 편다.
//
// navigationShell(StatefulShellRoute의 IndexedStack)을 여기서는 쓰지 않는다 —
// 아코디언은 "여러 섹션을 한 화면에서 동시에 보여줄 수 있어야" 하는데
// IndexedStack은 항상 그중 하나만 보여주는 구조라 이 화면엔 안 맞는다.
// 대신 report/policies/checklist 위젯을 라우팅 없이 직접 그린다 — 이 위젯들은
// 전부 Riverpod provider만 읽는 ConsumerWidget이라(내부에서 Navigator를 쓰지
// 않음) 셸 바깥에서 그려도 문제 없다.
class _NarrowAccordionBody extends ConsumerWidget {
  final String buildingId;
  final double accordionListHeight;

  const _NarrowAccordionBody({
    required this.buildingId,
    required this.accordionListHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreResult = ref.watch(scoreResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 항상 펼침 — "이 동네 몇 점인지"는 탭/아코디언 뒤에 숨기지 않는다
          const ScoreOverviewHeader(),

          SurbiAccordionSection(
            title: '점수 상세 분석 (SHAP)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '막대그래프를 길게 누르면 이 점수가 무엇을 뜻하는 지 볼 수 있어요',
                  style: TextStyle(
                    fontSize: SurbiText.label,
                    color: SurbiColors.textGray,
                  ),
                ),
                const SizedBox(height: 12),
                ShapBarChart(factors: scoreResult.shapFactors),
              ],
            ),
          ),

          SurbiAccordionSection(
            title: 'AI 보고서',
            // 기본으로 펼쳐둠 — 지금 라우팅 리다이렉트 기본값(/report)과 맞춘 것
            initiallyExpanded: true,
            // 2026-08-27 (사용자 확인 후 추가) — 보고서 본문이 길어질 수 있어
            // 정부지원·체크리스트와 같은 방식(고정 높이 + 내부 스크롤)으로 통일.
            // ReportViewer가 이미 SingleChildScrollView라 높이만 정해주면 그 안에서
            // 알아서 스크롤된다. ⚠️ SHAP은 반대로 "길이와 무관하게 한눈에 다 보여야
            // 한다"는 요구라 일부러 높이 제한을 안 둔다.
            child: SizedBox(
              height: accordionListHeight,
              child: ReportPage(buildingId: buildingId),
            ),
          ),

          SurbiAccordionSection(
            title: '정부 지원사업',
            // 1,417건 — 고정 높이 + 내부 스크롤 (accordionListHeight 주석 참고)
            child: SizedBox(
              height: accordionListHeight,
              child: const PolicyListPage(),
            ),
          ),

          SurbiAccordionSection(
            title: '체크리스트',
            child: SizedBox(
              height: accordionListHeight,
              // 2026-08-27 (사용자 확인 후 추가) — ChecklistPage는 원래 자기 배경을
              // SurbiColors.primary(은백)로 직접 칠한다. 넓은 화면 탭에서는 그게
              // Scaffold 배경과 같아서 안 보였는데, 아코디언 카드(흰 배경) 안에서는
              // 헤더는 흰색·내용은 은백으로 갈려 이질감이 생겼다. backgroundColor로
              // 흰색을 넘겨 카드와 맞춘다 (기본값은 그대로 primary라 넓은 화면 탭은
              // 한 글자도 안 바뀐다).
              child: const ChecklistPage(backgroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// 3개 형제 탭 ㅡ 순서에 우열 없음 → 크기·스타일 완전 동일 (넓은 화면 전용)
class _ScoreTabBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScoreTabBar({required this.navigationShell});

  static const _labels = ['AI 보고서', '정부 지원사업', '체크리스트'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (index) {
        final isSelected = navigationShell.currentIndex == index;
        return Expanded(
          child: InkWell(
            onTap: () => navigationShell.goBranch(
              index,
              // 이미 선택된 탭을 다시 누르면 해당 브랜치 초기 위치로 리셋
              initialLocation: index == navigationShell.currentIndex,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    // ⚠️ transparent는 '색'이 아니라 '여기엔 아무것도 안 그린다'는
                    //    뜻이라 테마 상수로 올릴 대상이 아니다. 회색으로 바꾸면
                    //    비선택 탭에도 3px 밑줄이 생겨 선택 표시가 무의미해진다.
                    color: isSelected ? SurbiColors.accent : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                _labels[index],
                textAlign: TextAlign.center,
                // 이 탭바는 TabBar 위젯이 아니라 우리가 Container로 직접 그린
                // 것이라, 상속받을 '부모의 뜻'이 없다 — 명시하지 않으면
                // DefaultTextStyle(bodyMedium)을 우연히 탄다
                style: TextStyle(
                  fontSize: SurbiText.body,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? SurbiColors.accent : SurbiColors.textGray,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
