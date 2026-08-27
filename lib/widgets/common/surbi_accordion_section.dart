// lib/widgets/common/surbi_accordion_section.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/app/theme.dart';
import 'package:surbi_web/widgets/common/surbi_card.dart';

/// 접었다 펼치는 콘텐츠 섹션 — SurbiCard 위에 헤더(제목 + 화살표)를 얹고
/// 그 아래 child를 펼침/접힘으로 보여준다.
///
/// (2026-08-27 · Step 4 모바일 재구성 · 8/24 회의 지시 ④)
///
/// ⚠️ 접혔을 때 child를 트리에서 제거하지 않는다.
/// 8/26 하단 시트에서 "조건부 return으로 트리 모양을 바꾸면 그 안의 State가
/// 통째로 버려진다"는 걸 배웠다 — 이 섹션 안에 들어가는 AI 보고서(12초 타이머)나
/// 정부지원 목록(스크롤 위치)이 접었다 펼 때마다 초기화되면 안 되므로,
/// `Visibility(maintainState: true)`로 "안 보이게만 하고 State는 살려둔다".
class SurbiAccordionSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const SurbiAccordionSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<SurbiAccordionSection> createState() => _SurbiAccordionSectionState();
}

class _SurbiAccordionSectionState extends State<SurbiAccordionSection> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // ⚠️ 필드 초기화 시점이 아니라 initState에서 widget 값을 읽는다 —
    // 필드 초기화 구문은 State가 트리에 붙기 전에 실행될 수 있어 위험하다.
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return SurbiCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(SurbiRadius.card),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: SurbiText.subtitle,
                        fontWeight: FontWeight.bold,
                        color: SurbiColors.accent,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0, // 0.5 turn = 180도 (▾ ↔ ▴)
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: SurbiColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Visibility(
              visible: _expanded,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
