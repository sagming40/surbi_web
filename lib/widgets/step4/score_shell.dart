// lib/widgets/step4/score_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/widgets/common/surbi_app_bar.dart';
import 'package:surbi_web/widgets/step4/score_hub_panel.dart';

// Step 4 허브 화면 — 게이지 패널(고정) + 3개 형제 탭(report/policies/checklist)
// StatefulShellRoute의 builder에서 반환됨 (Phase 2의 임시 화면을 대체)
class ScoreShell extends StatelessWidget {
  final String buildingId;
  final String categoryCode; // ⭐ 추가 — 뒤로가기 목적지(/analysis) 조립용
  final StatefulNavigationShell navigationShell;

  const ScoreShell({
    super.key,
    required this.buildingId,
    required this.categoryCode,
    required this.navigationShell,
  });

  /// 넓은 화면에서 탭 영역이 가져갈 최대 폭.
  ///
  /// 화면 전체를 쓰되(8/24 회의 지시 ③) **글줄이 무한정 길어지지는 않게** 한다.
  /// 1920 화면에서 제한이 없으면 본문 한 줄이 1,500px = 한글 100자를 넘어
  /// 눈이 줄 끝에서 다음 줄 시작으로 돌아오지 못한다. 읽기 좋은 길이는 40~50자다.
  ///   본문 14px × 45자 ≈ 630 + 카드 안쪽 여백 40 + 뷰어 바깥 여백 48 ≈ 720
  ///
  /// ⚠️ 라우트(ResponsiveLayout)가 아니라 **화면 안쪽**에서 잡는 이유 —
  /// 라우트를 좁히면 화면 전체가 가운데 박스에 갇혀 /explore와 다시 어긋난다.
  /// 좌측 요약 패널은 /explore의 좌측 패널처럼 화면 끝에 붙어 있어야 한다.
  static const double _contentMaxWidth = 720;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // /explore와 같은 바탕색. 명시하지 않으면 테마 기본값(거의 흰색)이 되어
      // 은백 배경 위의 흰 카드라는 규칙이 이 화면에서만 깨진다.
      backgroundColor: SurbiColors.primary,
      appBar: SurbiAppBar(
        title: 'AI 창업 분석',
        onBackPressed: () {
          // 다음에 다시 들어올 때 보고서 탭부터 시작하도록 초기화
          if (navigationShell.currentIndex != 0) {
            navigationShell.goBranch(0);
          }
          // 뒤로 = 방금 떠나온 지도 화면. go 통일로 스택이 없어 목적지를 직접 지정한다.
          //
          // 2026-08-23 — `/analysis`에서 `/explore`로 변경.
          // 예전 흐름은 `/map → /analysis → /score`라 뒤로가 /analysis가 맞았지만,
          // 통합 화면에서는 `/explore`에서 곧장 여기로 온다. 그대로 두면
          // **가본 적도 없는 화면**으로 되돌아가게 된다.
          //
          // buildingId에는 행정동 코드가 담긴다(라우터 TODO 참고) → 주소가 그대로 맞는다.
          context.go('/explore/$buildingId/$categoryCode');
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          if (isWide) {
            // 900px 이상 ㅡ 죄측 게이지 고정, 우측 탭 콘텐츠만 swap
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(width: 340, child: ScoreHubPanel()),
                const VerticalDivider(width: 1),
                Expanded(
                  // 탭바까지 함께 감싼다 — 콘텐츠만 좁히면 탭 3개가 1,500px에
                  // 퍼져서 밑줄만 길어지고 아래 카드와 폭이 어긋난다.
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _contentMaxWidth,
                      ),
                      child: Column(
                        children: [
                          _ScoreTabBar(navigationShell: navigationShell),
                          const Divider(height: 1),
                          Expanded(child: navigationShell),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // 900px 미만 ㅡ 세로 배치 (게이지 위, 탭+콘텐츠 아래)
          // ⚠️ 임시 flex 비율 ㅡ 디자인 다듬기 세션에서 조정 예정
          return Column(
            children: [
              const Expanded(flex: 4, child: ScoreHubPanel()),
              const Divider(height: 1),
              _ScoreTabBar(navigationShell: navigationShell),
              const Divider(height: 1),
              Expanded(flex: 6, child: navigationShell),
            ],
          );
        },
      ),
    );
  }
}

// 3개 형제 탭 ㅡ 순서에 우열 없음 → 크기·스타일 완전 동일
class _ScoreTabBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScoreTabBar({required this.navigationShell});

  static const _labels = ['AI 보고서', '정부 지원사업', '체크리스트'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (index) {
        final isSelected = navigationShell.currentIndex == index;
        return Expanded(
          child: InkWell(
            onTap: () => navigationShell.goBranch(
              index,
              // 이미 선택된 탭을 다시 누르면 해당 브랜치 초기 위치로 리셋
              initialLocation: index == navigationShell.currentIndex,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    // ⚠️ transparent는 '색'이 아니라 '여기엔 아무것도 안 그린다'는
                    //    뜻이라 테마 상수로 올릴 대상이 아니다. 회색으로 바꾸면
                    //    비선택 탭에도 3px 밑줄이 생겨 선택 표시가 무의미해진다.
                    color: isSelected ? SurbiColors.accent : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                _labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? SurbiColors.accent : SurbiColors.textGray,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
