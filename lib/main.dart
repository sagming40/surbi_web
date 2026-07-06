import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Task 1-3 추가
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Task 1-4 추가
import 'widgets/common/responsive_layout.dart'; // Task 1-2 추가
import 'app/router.dart'; // Task 1-4 추가

void main() {
  usePathUrlStrategy(); // # 없는 깔끔한 주소 사용

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
      ),
      /* home: ResponsiveLayout(
        child: Scaffold(
          body: Center(child: Text('Surbi 시작', style: TextStyle(fontSize: 24))),
        ),
      ), */
      routerConfig: router, // ← home 대신 이걸로 교체 (Task 1-4)
      builder: (context, child) {
        return ResponsiveLayout(child: child!);
      },
    );
  }
}
