// lib/services/mock_data.dart
// Task 4-1 · UI 개발용 Mock 데이터
// API 연동 완료 시 이 파일의 데이터를 실제 API 응답으로 교체 예정

import '../models/region.dart';
import '../models/commercial_area.dart';
import '../models/building.dart';
import '../models/score_result.dart';
import '../models/government_policy.dart';
import '../models/report.dart';
import '../models/checklist_item.dart';

class MockData {
  // ─────── Step 1 · 지역 목록 ───────
  static List<Region> regions() => [
    const Region(
      regionCode: '1144068000',
      regionName: '망원동',
      guName: '마포구',
      lat: 37.5558,
      lng: 126.9062,
    ),
    const Region(
      regionCode: '1144065000',
      regionName: '연남동',
      guName: '마포구',
      lat: 37.5613,
      lng: 126.9248,
    ),
    const Region(
      regionCode: '1144066000',
      regionName: '합정동',
      guName: '마포구',
      lat: 37.5492,
      lng: 126.9138,
    ),
  ];

  // ────────── Step 2 · 상권 목록 ──────────
  static List<CommercialArea> areas() => [
    const CommercialArea(
      regionCode: '1144068000',
      regionName: '마포구 망원동',
      score: 78.5,
      footTraffic: 15200,
      competitionRate: 0.42,
      closureRisk: 0.23,
      lat: 37.5558,
      lng: 126.9062,
    ),
    const CommercialArea(
      regionCode: '1144065000',
      regionName: '마포구 연남동',
      score: 85.2,
      footTraffic: 22400,
      competitionRate: 0.61,
      closureRisk: 0.18,
      lat: 37.5613,
      lng: 126.9248,
    ),
    const CommercialArea(
      regionCode: '1144066000',
      regionName: '마포구 합정동',
      score: 71.0,
      footTraffic: 11800,
      competitionRate: 0.35,
      closureRisk: 0.31,
      lat: 37.5492,
      lng: 126.9138,
    ),
  ];

  // ──────────── Step 3 · 건물 목록 ────────────
  static List<Building> buildings() => [
    const Building(
      buildingId: 'bld_001',
      buildingName: '망원 스퀘어',
      address: '서울 마포구 망원동 123-4',
      lat: 37.5561,
      lng: 126.9071,
      previewScore: 78.5,
    ),
    const Building(
      buildingId: 'bld_002',
      buildingName: '한강로 상가',
      address: '서울 마포구 망원동 56-2',
      lat: 37.5548,
      lng: 126.9055,
      previewScore: 65.3,
    ),
    const Building(
      buildingId: 'bld_003',
      buildingName: '망원역 코너빌딩',
      address: '서울 마포구 망원동 78-9',
      lat: 37.5571,
      lng: 126.9043,
      previewScore: 82.1,
    ),
  ];

  // ──────────────── Step 4 · AI 창업 점수 + SHAP ────────────────
  static ScoreResult scoreResult() => const ScoreResult(
    totalScore: 78.5,
    predictedSales: 4200000, // 예상 월 매출 420만원
    closureRiskPct: 23.1, // 폐업 위험도 23.1%
    shapFactors: [
      ShapFactor(name: '유동인구 지수', value: 18.2, maxScore: 20),
      ShapFactor(name: '업종 소비력', value: 15.1, maxScore: 20),
      ShapFactor(
        name: '경쟁 강도',
        value: -4.5, // 음수 = 감점 요인
        maxScore: 15,
      ),
      ShapFactor(name: '접근성', value: 8.3, maxScore: 10),
      ShapFactor(name: '운영 안정성', value: 12.0, maxScore: 15),
      ShapFactor(name: '정책 지원 적합도', value: 16.0, maxScore: 20),
    ],
  );

  // ──────────── Step 4 · 정부 지원사업 목록 ────────────
  static List<GovernmentPolicy> policies() => [
    const GovernmentPolicy(
      id: 'pol_001',
      title: '소상공인 정책자금 — 일반경영안정자금',
      organization: '소상공인시장진흥공단',
      category: '외식업',
      startDate: '2026-07-01',
      endDate: '2026-08-31',
      url: 'https://www.semas.or.kr',
    ),
    const GovernmentPolicy(
      id: 'pol_002',
      title: '청년 창업사관학교 12기 모집',
      organization: '중소벤처기업부',
      category: '외식업',
      startDate: '2026-07-15',
      endDate: '2026-09-15',
      url: 'https://www.bizinfo.go.kr',
    ),
    const GovernmentPolicy(
      id: 'pol_003',
      title: '마포구 골목상권 창업지원금',
      organization: '마포구청',
      category: '외식업',
      startDate: '2026-08-01',
      endDate: '2026-09-30',
      url: 'https://www.mapo.go.kr',
    ),
  ];

  // ──────────────── Step 4 · LLM 보고서 ────────────────
  static Report report() => const Report(
    reportId: 'rpt_001',
    regionName: '마포구 망원동',
    category: '카페',
    summary:
        '망원동은 20~30대 유동인구 비율이 높고 카페 업종 소비력이 '
        '서울 평균 대비 1.3배 수준입니다. '
        '한강공원 접근성과 감성 상권 이미지가 결합되어 '
        '카페 창업 적합도가 높은 지역으로 분석됩니다.',
    riskFactors:
        '동일 업종 경쟁 강도가 0.42로 중간 수준이며, '
        '망원역 인근 신규 카페 입점이 증가 추세입니다. '
        '임대료는 마포구 평균 대비 소폭 낮지만 '
        '상승 가능성에 유의가 필요합니다.',
    policyAdvice:
        '소상공인 정책자금 일반경영안정자금 신청이 가능합니다. '
        '마포구 골목상권 창업지원금 공고도 확인해 보세요. '
        '청년 창업자라면 청년 창업사관학교 지원도 검토하세요.',
    createdAt: '2026-06-28T10:00:00',
  );

  // ────────── Step 4 · 창업 행동 체크리스트 ──────────
  static List<ChecklistItem> checklistItems() => [
    const ChecklistItem(
      itemId: 'chk_001',
      content: '현장 방문 후 유동인구 체감 확인하기',
      category: '현장조사',
      isChecked: false,
      order: 1,
    ),
    const ChecklistItem(
      itemId: 'chk_002',
      content: '동일 업종 매장 수와 운영 시간대 조사하기',
      category: '현장조사',
      isChecked: false,
      order: 2,
    ),
    const ChecklistItem(
      itemId: 'chk_003',
      content: '예상 창업비용과 정책자금 신청 가능 여부 확인하기',
      category: '자금준비',
      isChecked: false,
      order: 3,
    ),
    const ChecklistItem(
      itemId: 'chk_004',
      content: '상권 분석 보고서를 바탕으로 후보 지역 3곳 비교하기',
      category: '의사결정',
      isChecked: false,
      order: 4,
    ),
  ];
} // MockData
