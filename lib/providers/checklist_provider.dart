// lib/providers/checklist_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/models/checklist_item.dart';

// ⭐ StateNotifier: "상태를 들고 있으면서, 상태를 바꾸는 방법도 제공하는 관리자"
class ChecklistNotifier extends StateNotifier<List<ChecklistItem>> {
  ChecklistNotifier() : super(_initialItems);

  // B안 원칙: 임시 데이터는 여기(Provider 계층)에만 격리
  // TODO: Task 4-6에서 실제 API 응답으로 교체 예정
  static const List<ChecklistItem> _initialItems = [
    ChecklistItem(
      itemId: 'temp_check_001',
      content: '현장 방문 후 유동인구 체감 확인하기',
      category: '현장조사',
      isChecked: false,
      order: 1,
    ),
    ChecklistItem(
      itemId: 'temp_check_002',
      content: '정책 지원사업 신청자격 요건 확인하기',
      category: '자금준비',
      isChecked: false,
      order: 2,
    ),
    ChecklistItem(
      itemId: 'temp_check_003',
      content: '임대차 계약서 특약사항 법무 검토받기',
      category: '법무',
      isChecked: false,
      order: 3,
    ),
  ];

  // ⭐ 체크 토글 메서드 — 체크 표시
  void toggleCheck(String itemId) {
    state = [
      for (final item in state)
        if (item.itemId == itemId)
          item.copyWith(isChecked: !item.isChecked)
        else
          item,
    ];
  }
}

// ⭐ StateNotifierProvider로 등록
final checklistProvider =
    StateNotifierProvider<ChecklistNotifier, List<ChecklistItem>>((ref) {
      return ChecklistNotifier();
    });

// ⭐ 진행률 계산용 파생 Provider (Step 3에서 쓸 예정, 미리 만들어둠)
final checklistProgressProvider = Provider<({int done, int total})>((ref) {
  final items = ref.watch(checklistProvider);
  final done = items.where((item) => item.isChecked).length;
  return (done: done, total: items.length);
});
