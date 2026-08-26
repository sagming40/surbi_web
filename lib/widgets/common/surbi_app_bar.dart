// lib/widgets/common/surbi_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ⭐ 추가
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/widgets/common/surbi_back_button.dart';

/// 앱 전체에서 공용으로 쓰는 AppBar
///
/// 통합 화면(/explore)의 ExploreTopBar와 **같은 규칙**을 따른다 —
/// 순백 배경(본문보다 한 톤 밝게) · 그림자 없음 · 아래 1px 구분선 ·
/// 왼쪽에 [SurbiBackButton]. (2026-08-25 지시 ③ / 8/26 재조정)
///
/// ⚠️ 8/26 오전에 "배경색을 primary로 통일"했다가 되돌렸다. 상단 바와 본문이
///    같은 색이면 **어디까지가 바인지 안 보인다.** 통일해야 할 대상은
///    "같은 색"이 아니라 "같은 규칙"이었다 — 바는 어느 화면에서든
///    본문보다 한 톤 밝고, 아래에 얇은 선을 둔다.
///
/// 뒤로가기는 [SurbiBackButton] 하나를 ExploreTopBar와 **공유**한다.
/// 속성을 각자 적어두면 언젠가 또 갈린다.
class SurbiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed; // ⭐ 추가 — 지정 안 하면 기본 동작 사용

  const SurbiAppBar({super.key, required this.title, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SurbiColors.barSurface,
      elevation: 0,
      // ⚠️ 기본값 kToolbarHeight(56)를 쓰면 ExploreTopBar(76)와 20px 어긋난다.
      //    두 화면을 오갈 때 바가 널뛴다. (2026-08-26)
      toolbarHeight: SurbiBar.height,
      // ⚠️ Material 3은 본문이 AppBar 밑으로 스크롤돼 들어가면 surfaceTintColor를
      //    덧씌워 색을 바꾼다 (scrolledUnderElevation 기본값 3).
      //    backgroundColor를 명시했는데도 **스크롤할 때만** 색이 변하는 현상이 이것이다.
      //    SurbiCard가 Card 대신 Container를 쓰는 이유와 같은 문제라 여기서도 명시적으로 끈다.
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // ⚠️ leadingWidth를 지정하지 않으면 AppBar 기본값 56이 쓰여
      //    ExploreTopBar보다 `‹`가 8px 왼쪽에 붙는다. (SurbiBackButton 주석 참고)
      leadingWidth: SurbiBackButton.leadingWidth,
      leading: SurbiBackButton(
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
          // ExploreTopBar의 드롭다운 글자와 **같은 크기**여야 한다.
          // 두 바를 오갈 때 크기가 다르면 같은 자리에 있는 같은 역할의 글자가
          // 화면마다 무게가 달라져, 바가 서로 다른 물건처럼 보인다.
          // (8/26에 18 → 20 → 16으로 두 번 옮겼다. 20으로 올렸던 근거였던
          //  "카드 제목보다 커야 한다"는 위계는 위치와 구분선이 이미 만든다)
          fontSize: SurbiText.subtitle,
          fontWeight: FontWeight.w600,
          color: SurbiColors.accent,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(SurbiBar.dividerHeight),
        child: Divider(
          height: SurbiBar.dividerHeight,
          thickness: SurbiBar.dividerHeight,
          color: SurbiColors.divider,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(SurbiBar.totalHeight);
}
