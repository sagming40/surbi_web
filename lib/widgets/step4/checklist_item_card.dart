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

  @override
  Widget build(BuildContext context) {
    return SurbiCard(
      // ⭐ 카드 전체를 누르면 토글 (체크박스만 누르는 것보다 터치 영역 넓어서 UX 좋음)
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ⭐ 체크박스 자체
              Checkbox(
                value: item.isChecked,
                onChanged: (_) => onToggle(),
                activeColor: SurbiColors.accent,
              ),
              const SizedBox(width: 8),
              // ⭐ 내용 + 카테고리 태그
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content,
                      style: TextStyle(
                        fontSize: 14,
                        // ⭐ 체크된 항목은 취소선 + 흐린 색으로 "완료됨" 표시
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.isChecked ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SurbiColors.accentTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: SurbiColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
