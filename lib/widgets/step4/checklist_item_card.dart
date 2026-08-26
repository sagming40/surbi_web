// lib/widgets/step4/checklist_item_card.dart

import 'package:flutter/material.dart';
import 'package:surbi_web/models/checklist_item.dart';
import 'package:surbi_web/widgets/common/surbi_card.dart';
import 'package:surbi_web/app/theme.dart';

class ChecklistItemCard extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;

  const ChecklistItemCard({
    super.key,
    required this.item,
    required this.onToggle,
  });

  // 2026-08-18 — 카테고리별 색상 매핑
  // 현장조사는 accent(네이비) 재사용, 나머지 2개는 theme.dart에 신규 추가
  Color _categoryColor(String category) {
    switch (category) {
      case '현장조사':
        return SurbiColors.accent;
      case '자금준비':
        return SurbiColors.checklistFunding;
      case '법무':
        return SurbiColors.checklistLegal;
      default:
        return SurbiColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(item.category);

    return SurbiCard(
      // 2026-08-18 — 체크 완료 시 카드 배경을 옅은 초록으로 (C안)
      // 기존 취소선(TextDecoration.lineThrough) 방식은 Flutter Web CanvasKit에서
      // 공백 위치가 끊겨 보이는 알려진 렌더링 버그가 있어(DEVLOG 미해결 항목),
      // 취소선 자체를 쓰지 않는 표현으로 교체
      backgroundColor: item.isChecked
          ? SurbiColors.success.withValues(alpha: 0.08)
          : null,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 체크박스 — 완료 시 success 색으로 강조 (취소선 대신 이게 "완료됨"을 전달)
              Checkbox(
                value: item.isChecked,
                onChanged: (_) => onToggle(),
                activeColor: SurbiColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content,
                      style: TextStyle(
                        fontSize: SurbiText.body,
                        fontWeight: item.isChecked
                            ? FontWeight.normal
                            : FontWeight.w500,
                        // 취소선 대신 색 대비로만 완료 여부 표시
                        color: item.isChecked
                            ? SurbiColors.textGray
                            : SurbiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(SurbiRadius.small),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: SurbiText.caption,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 완료 시 우측에 체크 아이콘 — 취소선의 대체 신호
              if (item.isChecked)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: SurbiColors.success,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
