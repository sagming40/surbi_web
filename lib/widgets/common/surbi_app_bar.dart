// lib/widgets/common/surbi_app_bar.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

/// 앱 전체에서 공용으로 쓰는 AppBar
/// (흰 배경 + 그림자 없음 + 네이비 뒤로가기 + 하단 얇은 구분선)
class SurbiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SurbiAppBar({super.key, required this.title});

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
        onPressed: () => Navigator.pop(context),
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
