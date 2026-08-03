// lib/widgets/common/surbi_card.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

/// 앱 전체에서 공용으로 쓰는 카드 컨테이너
/// Card 대신 Container + BoxDecoration 사용
/// (Material 3의 자동 surfaceTintColor 간섭을 피하기 위함)
class SurbiCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor; // 지정 한 하면 흰색 기본값
  final EdgeInsetsGeometry padding;

  const SurbiCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(SurbiRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
