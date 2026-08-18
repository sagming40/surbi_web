// lib/providers/checklist_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:surbi_web/models/checklist_item.dart';

// ⭐ StateNotifier: "상태를 들고 있으면서, 상태를 바꾸는 방법도 제공하는 관리자"
class ChecklistNotifier extends StateNotifier<List<ChecklistItem>> {
  ChecklistNotifier() : super(_initialItems);

  // B안 원칙: 데이터는 Provider 계층에 격리
  // 2026-08-18 확정 — DB팀 확인 결과(3.3 [전체] 6번) 관련 테이블 자체가 없어
  // API 연동 대상이 아님. 이 6개 항목은 FE 고정값으로 영구 유지.
  static const List<ChecklistItem> _initialItems = [
    ChecklistItem(
      itemId: 'check_001',
      content: '선택한 동네를 직접 방문해 유동인구·경쟁 매장을 눈으로 확인하기',
      category: '현장조사',
      isChecked: false,
      order: 1,
    ),
    ChecklistItem(
      itemId: 'check_002',
      content: '같은 업종 인근 매장의 영업시간·가격대 조사하기',
      category: '현장조사',
      isChecked: false,
      order: 2,
    ),
    ChecklistItem(
      itemId: 'check_003',
      content: '추천된 정부 지원사업의 신청 자격 요건 확인하기',
      category: '자금준비',
      isChecked: false,
      order: 3,
    ),
    ChecklistItem(
      itemId: 'check_004',
      content: '초기 창업 자금(보증금·인테리어·재고) 예산 계획 세우기',
      category: '자금준비',
      isChecked: false,
      order: 4,
    ),
    ChecklistItem(
      itemId: 'check_005',
      content: '임대차 계약서 특약사항 법무 검토받기',
      category: '법무',
      isChecked: false,
      order: 5,
    ),
    ChecklistItem(
      itemId: 'check_006',
      content: '사업자등록·영업신고 등 필요 인허가 목록 확인하기',
      category: '법무',
      isChecked: false,
      order: 6,
    ),
  ];

  // ⭐ 체크 토글 메서드 — 체크 표시
  // TODO(Task 2-5): Firestore 연동 시 이 메서드 안에서 상태 변경 후
  //   FirebaseFirestore.instance
  //     .collection('users').doc(uid)
  //     .collection('checklist_progress').doc(itemId)
  //     .set({'isChecked': !item.isChecked})
  //   같은 방식으로 원격 저장도 함께 호출 예정.
  //   지금은 로컬 state만 변경 (새로고침 시 초기화됨 — 의도된 동작)
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
