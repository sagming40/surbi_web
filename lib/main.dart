import 'package:flutter/material.dart';
import 'widgets/common/responsive_layout.dart';

void main() {
  runApp(const SurbiApp());
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
