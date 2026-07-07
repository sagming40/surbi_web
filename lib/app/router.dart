import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../views/step1_region_page.dart'; // ⭐ 새로 추가
import '../views/step2_dashboard_page.dart'; // ⭐ 새로 추가

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

final routerProvider = Provider<GoRouter>((ref) {
  // ref는 지금 사용 안 함
  // EPIC 2에서 Firebase 연동 후 authStateProvider를 ref.watch()로 구독하고
  // redirect 로직(로그인 전이면 /login으로, 로그인 후면 /step1으로) 추가 예정

  return GoRouter(
    initialLocation: '/',
    routes: [
      // 랜딩 페이지
      GoRoute(
        path: '/',
        builder: (context, state) => const PlaceholderPage(label: 'Surbi 시작'),
      ),

      // 로그인 페이지 (카카오·네이버 소셜 로그인 — EPIC 2에서 구현)
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const PlaceholderPage(label: '로그인 화면 (준비중)'),
      ),

      // Step 1: 지역·카테고리 선택
      GoRoute(
        path: '/step1',
        builder: (context, state) => const Step1RegionPage(), // ⭐ 교체
      ),

      // Step 2: 상권 분석 대시보드
      // :regionCode = 행정동 코드 (예: /step2/1114013600)
      GoRoute(
        path: '/step2/:regionCode',
        builder: (context, state) {
          final regionCode = state.pathParameters['regionCode'] ?? '없음';
          return Step2DashboardPage(regionCode: regionCode); // ⭐ 교체
        },
      ),

      // Step 3: 지도 모드 — 건물 탐색
      GoRoute(
        path: '/step3/map',
        builder: (context, state) =>
            const PlaceholderPage(label: 'Step 3: 지도 모드 (준비중)'),
      ),

      // Step 4: AI 창업 점수 + LLM 보고서
      // :buildingId = 선택한 건물 고유 ID (예: /step4/bld_00123)
      GoRoute(
        path: '/step4/:buildingId',
        builder: (context, state) {
          final buildingId = state.pathParameters['buildingId'] ?? '없음';
          return PlaceholderPage(
            label: 'Step 4: AI 분석 (준비중)\n건물 ID: $buildingId',
          );
        },
      ),
    ],
  );
});
