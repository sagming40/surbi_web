// lib/views/checklist_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/checklist_provider.dart';
import 'package:surbi_web/widgets/common/surbi_app_bar.dart';
import 'package:surbi_web/widgets/common/surbi_empty.dart';
import 'package:surbi_web/widgets/step4/checklist_item_card.dart';
import 'package:surbi_web/widgets/step4/checklist_progress_bar.dart';
import 'package:surbi_web/app/theme.dart';

class ChecklistPage extends ConsumerWidget {
  const ChecklistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ 체크리스트 목록 구독 — 항목이 토글될 때마다 이 화면이 자동으로 다시 그려짐
    final items = ref.watch(checklistProvider);

    return Scaffold(
      backgroundColor: SurbiColors.primary,
      appBar: const SurbiAppBar(title: '창업 준비 체크리스트'),
      body: Column(
        children: [
          const ChecklistProgressBar(), // ⭐ '진행률' 바
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
                          // ⭐ Notifier → toggleCheck() 호출
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
