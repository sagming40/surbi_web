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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Column(
                    children: [
                      _ScoreTabBar(navigationShell: navigationShell),
                      const Divider(height: 1),
                      Expanded(child: navigationShell),
                    ],
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
                    color: isSelected
                        ? SurbiColors.accent
                        : SurbiColors.textGray,
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
