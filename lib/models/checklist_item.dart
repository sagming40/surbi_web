// lib/models/checklist_item.dart

class ChecklistItem {
  final String itemId; // 체크리스트 항목 고유 ID
  final String content; // 항목 내용 (예: '현장 방문 후 유동인구 체감 확인하기')
  final String category; // 항목 분류 (예: '현장조사', '자금준비', '법무')
  final bool isChecked; // 체크 완료 여부 — Firestore에 저장되는 핵심 필드
  final int order; // 항목 표시 순서

  const ChecklistItem({
    required this.itemId,
    required this.content,
    required this.category,
    required this.isChecked,
    required this.order,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      itemId: json['item_id'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      isChecked: json['is_checked'] as bool,
      order: json['order'] as int,
    );
  }

  ChecklistItem copyWith({bool? isChecked}) {
    return ChecklistItem(
      itemId: itemId,
      content: content,
      category: category,
      isChecked: isChecked ?? this.isChecked,
      order: order,
    );
  }
}
