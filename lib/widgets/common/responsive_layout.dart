import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

// 모든 화면을 이 위젯으로 감싸면
// 화면마다 원하는 최대 폭을 각자 지정할 수 있음
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth; // ⭐ 추가 — 화면마다 다른 값을 줄 수 있도록

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 500, // ⭐ 기본값 500 — 안 넘겨주면 지금까지랑 동일하게 동작
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SurbiColors.primary,
      child: Center(
        child: ConstrainedBox(
          // ⭐ const 제거 (런타임 값이라)
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
