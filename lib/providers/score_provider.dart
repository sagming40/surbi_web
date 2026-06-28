// lib/providers/score_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/score_result.dart';
import '../models/government_policy.dart';
import '../models/report.dart';
import '../models/checklist_item.dart';
import '../services/mock_data.dart';

// AI 창업 점수 — 현재는 Mock 데이터 반환 (Task 4-6에서 API로 교체)
final scoreResultProvider = Provider<ScoreResult>((ref) {
  return MockData.scoreResult();
});

// 정부 지원사업 목록 — 현재는 Mock 데이터 반환 (Task 4-6에서 API로 교체)
final policiesProvider = Provider<List<GovernmentPolicy>>((ref) {
  return MockData.policies();
});

// LLM 보고서 — 현재는 Mock 데이터 반환 (Task 4-6에서 API로 교체)
final reportProvider = Provider<Report>((ref) {
  return MockData.report();
});

// 체크리스트 — 현재는 Mock 데이터 반환
// LLM 보고서 내용 일부 / 완료 여부는 Firestore 저장 (Task 2-5)
final checklistProvider = Provider<List<ChecklistItem>>((ref) {
  return MockData.checklistItems();
});
