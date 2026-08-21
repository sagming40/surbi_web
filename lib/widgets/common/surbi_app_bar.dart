// lib/widgets/common/surbi_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ⭐ 추가
import 'package:surbi_web/app/theme.dart';

/// 앱 전체에서 공용으로 쓰는 AppBar
/// (흰 배경 + 그림자 없음 + 네이비 뒤로가기 + 하단 얇은 구분선)
class SurbiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed; // ⭐ 추가 — 지정 안 하면 기본 동작 사용

  const SurbiAppBar({super.key, required this.title, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          size: 30,
          color: SurbiColors.accent,
        ),
        onPressed:
            onBackPressed ??
            () {
              // ⚠️ 2026-08-21 — 화면 이동을 context.go로 통일하면서 스택이 쌓이지
              // 않게 되어, 이 분기는 사실상 항상 아래쪽(/select)으로 간다.
              // 상위 경로가 /select가 아닌 화면은 onBackPressed로 목적지를 직접 지정할 것.
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/select');
              }
            },
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SurbiColors.accent,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey.shade200, height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
