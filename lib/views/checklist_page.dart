// lib/views/checklist_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/checklist_provider.dart';
import 'package:surbi_web/widgets/common/surbi_empty.dart';
import 'package:surbi_web/widgets/step4/checklist_item_card.dart';
import 'package:surbi_web/widgets/step4/checklist_progress_bar.dart';
import 'package:surbi_web/app/theme.dart';

class ChecklistPage extends ConsumerWidget {
  // 2026-08-27 (사용자 확인 후 추가) — 좁은 화면 아코디언(흰 카드) 안에 넣을 때
  // 카드 배경(흰색)과 맞추기 위해 배경색을 바꿀 수 있게 열어둠.
  // 기본값은 그대로 SurbiColors.primary — 넓은 화면 탭(Scaffold 배경과 같은 색)
  // 쪽은 한 글자도 안 바뀐다.
  final Color? backgroundColor;

  const ChecklistPage({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checklistProvider);

    // ⭐ Scaffold(backgroundColor: ...) → Container(color: ...)로 대체
    return Container(
      color: backgroundColor ?? SurbiColors.primary,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: SurbiColors.accentTint,
            child: const Text(
              '⚠️ 현재는 임시 저장이며 새로고침 시 초기화됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SurbiText.caption,
                color: SurbiColors.textGray,
              ),
            ),
          ),
          const ChecklistProgressBar(),
          Expanded(
            child: items.isEmpty
                ? const SurbiEmpty(message: '아직 준비된 체크리스트가 없어요')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ChecklistItemCard(
                          item: item,
                          onToggle: () => ref
                              .read(checklistProvider.notifier)
                              .toggleCheck(item.itemId),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
