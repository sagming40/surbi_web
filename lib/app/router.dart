import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/widgets/common/responsive_layout.dart'; // ⭐ 추가
import 'package:surbi_web/widgets/step4/score_shell.dart'; // ⭐ Phase 3 추가
import 'package:surbi_web/views/explore_page.dart'; // 통합 지도 화면
import 'package:surbi_web/views/analysis_page.dart'; // ⭐ 새로 추가
import 'package:surbi_web/widgets/step4/report_page.dart';
import 'package:surbi_web/views/policy_list_page.dart'; // ⭐ Task 3-6 추가
import 'package:surbi_web/views/checklist_page.dart'; // ⭐ Task 3-7 추가

// 테스트용 import
// import '../widgets/common/surbi_loading.dart';
// import '../widgets/common/surbi_error.dart';
// import '../widgets/common/surbi_empty.dart';

// 실제 화면이 완성되기 전까지 임시로 텍스트만 보여주는 화면
// EPIC 2~3에서 실제 화면(LoginPage, Step1RegionPage 등)으로 교체 예정
class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: const SurbiLoading(message: '불러오는 중...'),
      // body: SurbiError(message: '데이터를 불러올 수 없습니다', onRetry: () {}),
      // body: const SurbiEmpty(message: '검색 결과가 없습니다'),
      body: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: SurbiText.title),
          textAlign: TextAlign.center, // 줄바꿈(\n) 있을때 가운데 정렬
        ),
      ),
    );
  }
}

/// 통합 지도 화면의 세 경로가 **같은 화면**임을 Navigator에 알려주는 페이지.
///
/// `key`를 같게 주는 것이 핵심이다. 이게 없으면 `/explore` → `/explore/11680`
/// 이동이 "다른 페이지로 갈아타기"로 처리돼 화면이 통째로 다시 만들어진다.
/// 그러면 지도(Platform View)가 새로 생성되면서 깜빡이고, 경계 폴리곤도
/// 처음부터 다시 그린다 — 주소만 바뀌었을 뿐인데.
///
/// > 호텔 방 번호표와 같다. 번호가 같으면 **같은 방에서 가구만 바꾸는 것**이고,
/// > 다르면 짐을 싸서 옆방으로 옮기는 것이다.
///
/// [NoTransitionPage]인 이유: 같은 화면 안에서 선택만 바뀌는데 전환
/// 애니메이션이 끼면 지도가 미끄러지듯 움직여 오히려 어지럽다.
Page<dynamic> _explorePage(BuildContext context, GoRouterState state) {
  return const NoTransitionPage(
    key: ValueKey('explore'),
    child: ResponsiveLayout(maxWidth: double.infinity, child: ExplorePage()),
  );
}

final _reportNavigatorKey = GlobalKey<NavigatorState>();
final _policiesNavigatorKey = GlobalKey<NavigatorState>();
final _checklistNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // ref는 지금 사용 안 함
  // EPIC 2에서 Firebase 연동 후 authStateProvider를 ref.watch()로 구독하고
  // redirect 로직(로그인 전이면 /login으로, 로그인 후면 /explore로) 추가 예정

  // ══════════════════════════════════════════════
  // 경로 변천사
  //
  // 2026-08-16 (플로우 재구조화)
  //   구: /step1 → /step2(분석) → /step3(지도) → /step4/:buildingId
  //   신: /select → /map(지도) → /analysis(분석) → /score
  //   ① 8/3 대조표 안건 2 — "지도 먼저"로 순서 확정
  //   ② 8/3 대조표 안건 1 — 점수 단위가 건물 → 행정동+업종으로 확정
  //      → :buildingId 폐기, :districtCode + :categoryCode 조합으로 교체
  //   ③ 경로에서 Step 번호 제거 — 순서가 또 바뀌어도 경로는 안 건드리도록
  //
  // 2026-08-23 (화면 통합 · Phase 2)
  //   /select + /map  →  /explore  로 흡수
  //   남은 흐름: /explore → /analysis → /score
  //   ※ /analysis는 Phase 3에서 /explore 패널로 다시 흡수될 예정
  // ══════════════════════════════════════════════

  return GoRouter(
    routes: [
      // 랜딩 페이지
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const ResponsiveLayout(child: PlaceholderPage(label: 'Surbi 시작')),
      ),

      // 로그인 페이지 (카카오·네이버 소셜 로그인 — EPIC 2에서 구현)
      GoRoute(
        path: '/login',
        builder: (context, state) => const ResponsiveLayout(
          child: PlaceholderPage(label: '로그인 화면 (준비중)'),
        ),
      ),

      // ① 통합 지도 화면 (Phase 2-B · 2026-08-23)
      // Step 1·2·3을 하나로 합치는 8/21 회의 결정의 결과물.
      //
      // 이 자리에 있던 `/select`(지역 선택)와 아래의 `/map`(업소 지도)은
      // 2026-08-23에 삭제했다. 두 화면의 역할을 이 하나가 전부 흡수했고,
      // 살려두면 **지도 인스턴스를 두 벌 유지**해야 해서 같은 함수가
      // `zoomIn`/`zoomInStep1`처럼 쌍으로 늘어난다.
      //
      // ── 경로가 곧 선택 상태다 (2026-08-23) ────────────────
      //   /explore                        → 서울 전체
      //   /explore/11680                  → 강남구      (5자리 = 구)
      //   /explore/11680510               → 신사동      (8자리 = 동)
      //   /explore/11680510/CS100007      → + 치킨전문점
      //
      // 구·동을 코드 길이로 가르는 것은 우리가 만든 규칙이 아니라
      // **행정안전부 행정구역 코드 체계**가 원래 계층이기 때문이다
      // (앞 5자리 = 자치구, 8자리 전체 = 행정동).
      //
      // 셋을 따로 쓰지 않고 [_explorePage] 하나로 만드는 이유는 아래 주석 참고.
      GoRoute(path: '/explore', pageBuilder: _explorePage),
      GoRoute(path: '/explore/:districtCode', pageBuilder: _explorePage),
      GoRoute(
        path: '/explore/:districtCode/:categoryCode',
        pageBuilder: _explorePage,
      ),

      // ② 상권 분석 대시보드
      //
      // ⚠️ 2026-08-23 현재 **이 화면으로 들어가는 링크가 없다.**
      // 유일한 입구였던 `/map`의 업소 카드 → 상세 버튼이 Phase 2-B에서 사라졌고,
      // `/score`의 뒤로가기도 `/explore`로 옮겼다. 주소를 직접 쳐야만 보인다.
      //
      // 그래도 지우지 않는 이유: Phase 3에서 **이 화면의 내용을 `/explore`
      // 패널 탭으로 흡수**할 예정이라, 그때 옮길 원본이 필요하다.
      // 흡수가 끝나면 이 라우트와 `analysis_page.dart`를 함께 삭제한다.
      GoRoute(
        path: '/analysis/:districtCode/:categoryCode',
        builder: (context, state) {
          final districtCode = state.pathParameters['districtCode']!;
          final categoryCode = state.pathParameters['categoryCode']!;
          return ResponsiveLayout(
            child: AnalysisPage(
              regionCode: districtCode,
              categoryCode: categoryCode,
            ),
          );
        },
      ),

      // ══════════════════════════════════════════════
      // ④ AI 점수 허브 — StatefulShellRoute
      // report/policies/checklist가 순서 우열 없는 형제 자식
      // ══════════════════════════════════════════════
      GoRoute(
        path: '/score/:districtCode/:categoryCode',
        redirect: (context, state) {
          final districtCode = state.pathParameters['districtCode']!;
          final categoryCode = state.pathParameters['categoryCode']!;
          // ⚠️ 이 redirect는 report/policies/checklist 전부의 부모라서
          // 자식으로 이동할 때마다 매번 재평가된다. "이미 자식 경로에 있는 경우"엔
          // redirect하면 안 되므로, 정확히 부모 경로 그 자체일 때만 이동시킴
          // (state.matchedLocation은 항상 부모 패턴이라 자식 구분 불가 → uri.path 사용)
          if (state.uri.path == '/score/$districtCode/$categoryCode') {
            return '/score/$districtCode/$categoryCode/report';
          }
          return null;
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              final districtCode = state.pathParameters['districtCode']!;
              final categoryCode = state.pathParameters['categoryCode']!;
              return ResponsiveLayout(
                // 2026-08-26 — /explore와 화면 크기를 통일 (8/24 회의 지시 ③).
                // 넓은 화면에서 보고서 글줄이 길어지는 문제는 라우트가 아니라
                // 탭 콘텐츠 안쪽에서 잡는다 — 라우트를 좁히면 두 화면이 다시 어긋난다
                maxWidth: double.infinity,
                child: ScoreShell(
                  // TODO(Phase 3): buildingId → districtCode로 파라미터명 교체
                  // 지금은 buildingId 자리에 districtCode를 넘겨 동작만 유지
                  buildingId: districtCode,
                  categoryCode: categoryCode,
                  navigationShell: navigationShell,
                ),
              );
            },
            branches: [
              // Branch 0: 점수 게이지 + LLM 보고서
              StatefulShellBranch(
                navigatorKey: _reportNavigatorKey,
                routes: [
                  GoRoute(
                    path: 'report', // ⚠️ 앞에 '/' 없음 — 부모 경로에 이어붙는 상대경로
                    builder: (context, state) {
                      final districtCode =
                          state.pathParameters['districtCode']!;
                      // TODO(Phase 3): ReportPage 파라미터명 교체
                      return ReportPage(buildingId: districtCode);
                    },
                  ),
                ],
              ),

              // Branch 1: 정부 지원사업 카드 리스트
              StatefulShellBranch(
                navigatorKey: _policiesNavigatorKey,
                routes: [
                  GoRoute(
                    path: 'policies',
                    builder: (context, state) => const PolicyListPage(),
                  ),
                ],
              ),

              // Branch 2: 창업 행동 유도 체크리스트
              StatefulShellBranch(
                navigatorKey: _checklistNavigatorKey,
                routes: [
                  GoRoute(
                    path: 'checklist',
                    builder: (context, state) => const ChecklistPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
