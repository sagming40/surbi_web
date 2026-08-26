import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // CupertinoPageTransitionsBuilder용
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Task 1-3 추가
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Task 1-4 추가
import 'app/router.dart'; // Task 1-4 추가
import 'app/theme.dart';
import 'services/kakao_map_view_registry.dart'; // Task 3-3 추가

void main() {
  usePathUrlStrategy(); // # 없는 깔끔한 주소 사용
  // 지도를 그릴 자리를 Flutter에 등록 — 앱 켜지자마자 딱 한 번
  // (2026-08-23 — 화면 통합으로 지도가 하나가 되면서 등록도 한 번으로 줄었다)
  registerKakaoMapView();

  runApp(
    // Task 1-3 추가 ProviderScope로 앱 전체를 감쌈
    const ProviderScope(child: SurbiApp()),
  );
}

// StatelessWidget → ConsumerWidget으로 변경 (router 읽으려면 필요)
class SurbiApp extends ConsumerWidget {
  const SurbiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // router 가져오기(Task 1-4)

    return MaterialApp.router(
      title: 'Surbi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ⚠️ 씨앗을 **브랜드 색**으로 (2026-08-26).
        //
        // 전까지는 #1565C0이었다 — Flutter 예제에서 흔히 쓰는 파랑이고
        // 우리 브랜드 네이비(#1E3A5F)와 다른 색이다.
        // ColorScheme.fromSeed는 이 씨앗 하나에서 hover·splash·focus·disabled·
        // surface 등 30개 넘는 색을 자동 생성하므로 **씨앗이 틀리면 전부 틀린다.**
        // (실제로 surbi_loading.dart가 이 값을 브랜드 색인 줄 알고 복붙해 쓰고 있었다)
        colorScheme: ColorScheme.fromSeed(seedColor: SurbiColors.accent),

        // 화면마다 Scaffold에 배경색을 적지 않아도 되도록 기본값을 못박는다
        scaffoldBackgroundColor: SurbiColors.primary,

        // ── 마우스·터치 반응 (2026-08-26) ──
        //
        // 앱 전체 InkWell 6곳이 색을 하나도 지정하지 않고 Material 기본값에
        // 기대고 있었다. 화면마다 정할 값이 아니라 여기서 한 번 정하는 값이다.
        //
        // 0.04 → 0.06 → 0.08 → 0.10으로 **단계를 두는 것**이 핵심이다.
        // 약한 신호(지나감)와 강한 신호(눌렀음)의 세기가 같으면
        // 사용자는 방금 무슨 일이 일어났는지 구분하지 못한다.
        // 농도는 SurbiOverlay가 갖고 있다 — 여기서 숫자를 직접 적으면
        // AppBar 쪽(SurbiAppBar)과 값이 갈린다.
        hoverColor: SurbiColors.accent.withValues(alpha: SurbiOverlay.hover),
        highlightColor: SurbiColors.accent.withValues(
          alpha: SurbiOverlay.highlight,
        ),
        focusColor: SurbiColors.accent.withValues(alpha: SurbiOverlay.focus),
        splashColor: SurbiColors.accent.withValues(alpha: SurbiOverlay.pressed),
        // ⚠️ IconButton은 Material 3에서 InkWell과 **다른 경로**를 탄다.
        //    자체 IconButtonTheme의 overlayColor를 보므로 위 hoverColor가 안 먹는다.
        //    지도 컨트롤 버튼이 여기 해당한다.
        // ⚠️ 단, **AppBar 안의 IconButton에는 이것도 안 닿는다** — AppBar가 자기
        //    IconButtonTheme을 더 가까이에 씌우기 때문이다. SurbiAppBar가
        //    같은 SurbiOverlay.iconButton을 위젯에 직접 넘겨서 맞춘다.
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(overlayColor: SurbiOverlay.iconButton),
        ),

        // 추가 ㅡ BottomSheet를 밑으로 드래그 할때 지도가 같이 딸려 내려가는 현상 개선
        //        지도는 고정된 채 BottomSheet만 부드럽게 위/아래로
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      /* home: ResponsiveLayout(
        child: Scaffold(
          body: Center(child: Text('Surbi 시작', style: TextStyle(fontSize: 24))),
        ),
      ), */
      routerConfig: router, // ← home 대신 이걸로 교체 (Task 1-4)
      // ⭐ ResponsiveLayout 제거 — 이제 각 route가 알아서 감쌈
      builder: (context, child) => child!,
    );
  }
}
