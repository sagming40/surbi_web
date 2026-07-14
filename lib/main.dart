import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Task 1-3 추가
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Task 1-4 추가
import 'app/router.dart'; // Task 1-4 추가
import 'services/kakao_map_view_registry.dart'; // Task 3-3 추가

void main() {
  usePathUrlStrategy(); // # 없는 깔끔한 주소 사용
  registerKakaoMapView(); // 추가 — 앱 켜지자마자 콘센트 등록

  runApp(
    // Task 1-3 추가 ProviderScope로 앱 전체를 감쌈
    const ProviderScope(child: SurbiApp()),
  );
}

// StatelessWidget → ConsumerWidget으로 변경 (router 읽으려면 필요)
class SurbiApp extends ConsumerWidget {
  const SurbiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // router 가져오기(Task 1-4)

    return MaterialApp.router(
      title: 'Surbi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        // 추가 ㅡ BottomSheet를 밑으로 드래그 할때 지도가 같이 딸려 내려가는 현상 개선
        //        지도는 고정된 채 BottomSheet만 부드럽게 위/아래로
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      /* home: ResponsiveLayout(
        child: Scaffold(
          body: Center(child: Text('Surbi 시작', style: TextStyle(fontSize: 24))),
        ),
      ), */
      routerConfig: router, // ← home 대신 이걸로 교체 (Task 1-4)
      // ⭐ ResponsiveLayout 제거 — 이제 각 route가 알아서 감쌈
      builder: (context, child) => child!,
    );
  }
}
