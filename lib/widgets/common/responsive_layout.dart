import 'package:flutter/material.dart';

// 모든 화면을 이 위젯으로 감싸면
// PC에서는 500px로 제한, 모바일에서는 꽉 차게
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  const ResponsiveLayout({super.key, required this.child});

  static const double maxWidth = 500;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5), // PC에서 보이는 양 옆 배경색
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
