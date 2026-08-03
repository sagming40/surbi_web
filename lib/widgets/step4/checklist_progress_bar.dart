// lib/widgets/step4/checklist_progress_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/providers/checklist_provider.dart';
import 'package:surbi_web/app/theme.dart';

class ChecklistProgressBar extends ConsumerWidget {
  const ChecklistProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ 계산 결과만 구독 — 진행률만 바뀌면 여기만 다시 그려짐
    final progress = ref.watch(checklistProgressProvider);
    final ratio = progress.total == 0 ? 0.0 : progress.done / progress.total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '진행률',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                '${progress.done} / ${progress.total} 완료',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SurbiColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: SurbiColors.accentTint,
              valueColor: const AlwaysStoppedAnimation(SurbiColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
