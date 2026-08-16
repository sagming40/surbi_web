import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:surbi_web/widgets/common/responsive_layout.dart'; // ⭐ 추가
import 'package:surbi_web/widgets/step4/step4_shell.dart'; // ⭐ Phase 3 추가
import 'package:surbi_web/views/step1_region_page.dart';
import 'package:surbi_web/views/step2_dashboard_page.dart'; // ⭐ 새로 추가
import 'package:surbi_web/views/step3_map_page.dart'; // ⭐ 새로 추가
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

      // ① 지역·업종 선택
      GoRoute(
        path: '/select',
        builder: (context, state) =>
            const ResponsiveLayout(child: Step1RegionPage()),
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
            child: Step3MapPage(
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
            child: Step2DashboardPage(
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
              return ResponsiveLayout(
                maxWidth: 1200, // 2컬럼 레이아웃이라 기본 500보다 넓게
                child: Step4Shell(
                  // TODO(Phase 3): 파라미터명을 districtCode+categoryCode로 교체
                  // 지금은 buildingId 자리에 districtCode를 넘겨 동작만 유지
                  buildingId: districtCode,
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
