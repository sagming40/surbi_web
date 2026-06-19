import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Task 1-3 추가
import 'widgets/common/responsive_layout.dart'; // Task 1-2 추가

void main() {
  runApp(
    // Task 1-3 추가 ProviderScope로 앱 전체를 감쌈
    const ProviderScope(child: SurbiApp()),
  );
}

class SurbiApp extends StatelessWidget {
  const SurbiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surbi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: ResponsiveLayout(
        child: Scaffold(
          body: Center(child: Text('Surbi 시작', style: TextStyle(fontSize: 24))),
        ),
      ),
    );
  }
}
