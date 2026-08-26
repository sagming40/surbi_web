// lib/widgets/common/surbi_back_button.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';

/// 뒤로가기 `‹` — **앱 안에 이 버튼은 하나뿐이다.** (2026-08-26)
///
/// 예전에는 [SurbiAppBar]와 ExploreTopBar가 각자 IconButton을 만들어 썼고,
/// 그때마다 아이콘 종류(`chevron_left` vs `_rounded`) · 크기(30 vs 28) ·
/// hover 원의 색과 크기 · 왼쪽 여백이 조금씩 달랐다.
///
/// 속성 목록 **두 벌을 손으로 맞추는 한 언젠가 또 갈린다.**
/// "같은 값을 두 곳에 적지 않는다"는 규칙은 숫자만이 아니라 위젯에도 적용된다.
class SurbiBackButton extends StatelessWidget {
  /// 버튼의 지름 — 마우스를 올리면 나타나는 **원의 크기**이기도 하다.
  static const double diameter = 48;

  /// 아이콘 자체의 크기.
  static const double iconSize = 28;

  /// 화면 왼쪽 끝에서 버튼까지의 여백.
  static const double gutter = 12;

  /// AppBar의 `leadingWidth`에 넣을 값.
  ///
  /// AppBar는 leading을 이 폭의 칸에 담고 **가운데 정렬**한다.
  /// 기본값이 56이라 버튼 중심이 왼쪽 끝에서 28px 지점에 왔는데,
  /// ExploreTopBar는 여백 12 뒤에 버튼을 두니 중심이 36px이었다.
  /// → 두 화면을 오갈 때 `‹`가 8px 움찔하며 옮겨 다녔다.
  ///
  /// 양쪽에 gutter를 둔 폭으로 맞추면 중심이 같아진다. (12 + 24 = 36)
  static const double leadingWidth = gutter * 2 + diameter; // 72

  /// null이면 되돌릴 곳이 없다는 뜻 — 회색으로 비활성 표시된다.
  final VoidCallback? onPressed;
  final String? tooltip;

  const SurbiBackButton({super.key, required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    // ⚠️ **부모가 tight 제약을 주면 자식의 fixedSize는 무시된다.** (2026-08-26)
    //
    //    AppBar는 leading을 두 번 옥죈다 —
    //      · 가로: ConstrainedBox(tightFor(width: leadingWidth))  → 72로 고정
    //      · 세로: _ToolbarLayout이 loose(size).tighten(height:)  → toolbarHeight(76)로 고정
    //    tight 제약 앞에서 자식은 자기 크기를 주장할 수 없다. 그래서 버튼 상자가
    //    48×48이 아니라 **72×76**이 됐고, CircleBorder는 상자의 짧은 변을
    //    지름으로 삼으므로 hover 원이 48이 아니라 **72**로 그려졌다.
    //    (ExploreTopBar는 Row 안이라 loose 제약 → 48 그대로. 그래서 둘이 달랐다)
    //
    //    Center + SizedBox로 **한 겹 감싸면** tight 제약이 그 껍데기에서 끝난다.
    //    껍데기가 늘어나 자리를 채우고, 안의 IconButton은 언제나 정확히
    //    diameter × diameter를 받는다. (제약은 아래로 흐르지만 껍데기가 막아준다)
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: diameter,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: const Icon(Icons.chevron_left_rounded),
          iconSize: iconSize,
          color: SurbiColors.accent,
          disabledColor: SurbiColors.placeholderGray,
          // ⚠️ 여기 값들은 **테마에 맡기지 않고 전부 못박는다.**
          //
          //    Material 3의 AppBar는 자기 leading·actions를 감쌀 IconButtonTheme을
          //    스스로 만들어 씌운다. 그게 main.dart의 전역 설정보다 위젯에 가까운
          //    조상이라 이긴다 — Theme은 명령이 아니라 상속이고, 상속은 언제나
          //    가장 가까운 조상이 이긴다.
          //
          //    그래서 AppBar 안(SurbiAppBar)과 밖(ExploreTopBar)에서 색만이 아니라
          //    원의 크기·모양까지 달라질 수 있다. 위젯에 직접 준 값은 테마보다
          //    항상 세므로, 여기서 못박으면 어디에 놓든 같은 모양이 된다.
          style: ButtonStyle(
            overlayColor: SurbiOverlay.iconButton,
            fixedSize: const WidgetStatePropertyAll(Size.square(diameter)),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            shape: const WidgetStatePropertyAll(CircleBorder()),
            // 데스크톱은 밀도가 compact라 원이 최대 4px 줄어든다 — 고정한다
            visualDensity: VisualDensity.standard,
          ),
        ),
      ),
    );
  }
}
