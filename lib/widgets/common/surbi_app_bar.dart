// lib/widgets/common/surbi_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ⭐ 추가
import 'package:surbi_web/app/theme.dart';

/// 앱 전체에서 공용으로 쓰는 AppBar
///
/// 통합 화면(/explore)의 상단 바와 같은 모양이다 —
/// 은백 배경 · 그림자 없음 · 구분선 없음 · 네이비 뒤로가기.
/// (2026-08-25 회의 지시 ③ 디자인 통일)
class SurbiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed; // ⭐ 추가 — 지정 안 하면 기본 동작 사용

  const SurbiAppBar({super.key, required this.title, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SurbiColors.primary,
      elevation: 0,
      // ⚠️ Material 3은 본문이 AppBar 밑으로 스크롤돼 들어가면 surfaceTintColor를
      //    덧씌워 색을 바꾼다 (scrolledUnderElevation 기본값 3).
      //    backgroundColor를 명시했는데도 **스크롤할 때만** 색이 변하는 현상이 이것이다.
      //    SurbiCard가 Card 대신 Container를 쓰는 이유와 같은 문제라 여기서도 명시적으로 끈다.
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
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
              // 않게 되어, 이 분기는 사실상 항상 아래쪽(/explore)으로 간다.
              // 상위 경로가 /explore가 아닌 화면은 onBackPressed로 목적지를 직접 지정할 것.
              //
              // 2026-08-23 — 통합 화면으로 목적지 변경 (`/select` 폐기)
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/explore');
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
