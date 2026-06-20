import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// 지금은 화면이 없으니 임시로 글자만 출력해주는 화면
class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label, style: const TextStyle(fontSize: 22))),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PlaceholderPage(label: 'Surbi 시작'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const PlaceholderPage(label: '로그인 화면 (준비중)'),
      ),
      GoRoute(
        path: '/step1',
        builder: (context, state) =>
            const PlaceholderPage(label: 'Step 1 (준비중)'),
      ),
    ],
  );
});
