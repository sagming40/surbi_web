import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:surbi_web/widgets/common/responsive_layout.dart'; // ⭐ 추가
import 'package:surbi_web/widgets/step4/score_shell.dart'; // ⭐ Phase 3 추가
import 'package:surbi_web/views/region_select_page.dart';
import 'package:surbi_web/views/explore_page.dart'; // 🚧 Phase 1 통합 화면
import 'package:surbi_web/views/analysis_page.dart'; // ⭐ 새로 추가
import 'package:surbi_web/views/map_page.dart'; // ⭐ 새로 추가
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
          style: const TextStyle(fontSize: 20),
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
  // redirect 로직(로그인 전이면 /login으로, 로그인 후면 /select로) 추가 예정

  // ══════════════════════════════════════════════
  // 2026-08-16 플로우 재구조화 (Phase 1)
  //   구: /step1 → /step2(분석) → /step3(지도) → /step4/:buildingId
  //   신: /select → /map(지도) → /analysis(분석) → /score
  //
  //   ① 8/3 대조표 안건 2 — "지도 먼저"로 순서 확정
  //   ② 8/3 대조표 안건 1 — 점수 단위가 건물 → 행정동+업종으로 확정
  //      → :buildingId 폐기, :districtCode + :categoryCode 조합으로 교체
  //   ③ 경로에서 Step 번호 제거 — 순서가 또 바뀌어도 경로는 안 건드리도록
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

      // ① 지역·업종 선택 (= 행정동 점수 히트맵에서 좋은 동을 '발견'하는 화면)
      // 2026-08-20 — maxWidth 500(기본값) → infinity.
      // 지도가 주인공인 화면이라 폭 제한을 풀었고, ②업소 지도와 폭이 같아져
      // 화면 전환 시 레이아웃이 급변하지 않는다. 컨트롤 바·버튼은 화면 안에서
      // 각자 760으로 묶여 초대형 모니터에서도 늘어지지 않는다.
      GoRoute(
        path: '/select',
        builder: (context, state) => const ResponsiveLayout(
          maxWidth: double.infinity,
          child: RegionSelectPage(),
        ),
      ),

      // 🚧 통합 지도 화면 (Phase 2-A · 2026-08-23)
      // Step 1·2·3을 하나로 합치는 8/21 회의 결정의 결과물.
      // Phase 2-B에서 위 `/select`와 아래 `/map`을 삭제한다. 그때까지는 셋 다
      // 살아 있다 — 새 화면이 덜 됐을 때 기존 화면으로 시연할 수 있어야 하기 때문.
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

      // ② 업소 지도 — 선택한 동네의 경쟁 업소 분포 확인
      // :districtCode = 행정동 코드 8자리 / :categoryCode = 업종 코드(CS1xxxxx)
      GoRoute(
        path: '/map/:districtCode/:categoryCode',
        builder: (context, state) {
          final districtCode = state.pathParameters['districtCode']!;
          final categoryCode = state.pathParameters['categoryCode']!;
          return ResponsiveLayout(
            maxWidth: double.infinity, // 지도 화면 — 폭 제한 없음
            child: MapPage(
              regionCode: districtCode,
              categoryCode: categoryCode,
            ),
          );
        },
      ),

      // ③ 상권 분석 대시보드
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
                maxWidth: 1200, // 2컬럼 레이아웃이라 기본 500보다 넓게
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
