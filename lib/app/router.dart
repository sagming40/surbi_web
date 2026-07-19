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
  // redirect 로직(로그인 전이면 /login으로, 로그인 후면 /step1으로) 추가 예정

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

      // Step 1: 지역·카테고리 선택
      GoRoute(
        path: '/step1',
        builder: (context, state) =>
            const ResponsiveLayout(child: Step1RegionPage()), // ⭐ 교체
      ),

      // Step 2: 상권 분석 대시보드
      // :regionCode = 행정동 코드 (예: /step2/1114013600)
      GoRoute(
        path: '/step2/:regionCode',
        builder: (context, state) {
          final regionCode = state.pathParameters['regionCode'] ?? '없음';
          return ResponsiveLayout(
            child: Step2DashboardPage(regionCode: regionCode),
          ); // ⭐ 교체
        },
      ),

      // Step 3: 지도 모드 — 건물 탐색
      // :regionCode = 행정동 코드 (Step2에서 넘어옴)
      GoRoute(
        path: '/step3/:regionCode',
        builder: (context, state) {
          final regionCode = state.pathParameters['regionCode'] ?? '없음';
          return ResponsiveLayout(child: Step3MapPage(regionCode: regionCode));
        },
      ),

      // ══════════════════════════════════════════════
      // Step 4 — StatefulShellRoute 리팩터링 (Phase 2)
      // report/policies/checklist가 형제 자식으로 전환됨
      // ══════════════════════════════════════════════

      // 기존 경로(/step4/:buildingId) 호환용 redirect
      // Step 3에서 context.push('/step4/$buildingId')로 넘어오는 코드를
      // 하나도 안 건드리기 위해, 진입 즉시 report 자식으로 리다이렉트
      GoRoute(
        path: '/step4/:buildingId',
        redirect: (context, state) {
          final buildingId = state.pathParameters['buildingId']!;
          // ⚠️ redirect는 report/policies/checklist 전부의 부모.
          // 자식으로 이동할 때마다 매번 새로고침됨. "이미 자식 경로에 있는 경우"엔
          // redirect하면 안 되므로, 정확히 부모 경로 그 자체일 때만 이동시킴
          if (state.uri.path == '/step4/$buildingId') {
            return '/step4/$buildingId/report';
          }
          return null;
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              final buildingId = state.pathParameters['buildingId']!;
              return ResponsiveLayout(
                maxWidth: 1200, // ⭐ Step4는 2컬럼이라 기본 500보다 넓게 필요
                child: Step4Shell(
                  buildingId: buildingId,
                  navigationShell: navigationShell,
                ),
              );
            },
            branches: [
              // Branch 0: Step 4-1(게이지) + Step 4-2(LLM 보고서)
              StatefulShellBranch(
                navigatorKey: _reportNavigatorKey,
                routes: [
                  GoRoute(
                    path: 'report', // ⚠️ 앞에 '/' 없음 — 부모 경로에 이어붙는 상대경로
                    builder: (context, state) {
                      final buildingId = state.pathParameters['buildingId']!;
                      return ReportPage(buildingId: buildingId);
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
