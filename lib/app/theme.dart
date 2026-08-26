import 'package:flutter/material.dart';

class SurbiColors {
  // ── 메인 컬러 (Primary) ──────────────────
  static const Color primary = Color(0xFFF8FAFA); // 은백색 — 배경 (최종 확정)
  static const Color primaryLight = Color(0xFFCCFBF1); // 연한 틸 (미사용)

  // ── 성공/완료 컬러 (Success) ──────────────
  static const Color success = Color(0xFF16A34A); // 그라스 그린 — 완료 배지, 체크리스트

  // ── 강조 컬러 (Accent) ────────────────────

  // 네이비 — 선택됨/CTA (최종 확정)
  static const Color accent = Color(0xFF1E3A5F);

  // ⭐ 추가 — 네이비 계열 연한 배경 (카드 등)
  static const Color accentTint = Color(0xFFE3E9F0);

  // ── 중립 컬러 (Neutral) ────────────────────

  static const Color placeholderGray = Color(0xFFD9D9D9); // 히트맵 placeholder 등
  static const Color textGray = Color(0xFF8E8E8E); // 보조 안내 텍스트

  // ⚠️ 주의: 아래 두 색은 Task 3-4 SHAP 차트 전용으로 예약됨.
  // 다른 용도로 재사용 금지 (양수 기여=파랑, 음수 기여=빨강 의미 고정)

  static const Color shapPositive = Color(0xFF2563EB);
  static const Color shapNegative = Color(0xFFDC2626);

  // ── 체크리스트 카테고리 컬러 (2026-08-18) ──
  // 현장조사는 accent(네이비) 재사용, 아래 2개만 신규 추가
  static const Color checklistFunding = Color(0xFFB45309); // 자금준비 — 앰버
  static const Color checklistLegal = Color(0xFF4338CA); // 법무 — 인디고

  // ── 상태 3단계 — 좋음 / 주의 / 나쁨 (2026-08-26) ──
  //
  // 점수 게이지 · 폐업 위험도 · 보고서 섹션이 전부 이 3단계를 그리는데,
  // 지금까지 세 파일이 **각자 다른 값**을 쓰고 있었다.
  //   score_gauge     : Colors.green / orange / red   (Material 기본)
  //   score_hub_panel : Colors.green / orange / red   (Material 기본)
  //   report_viewer   : #2E7D32 / #B86E00             (직접 지정)
  // 뜻이 같으면 색도 같아야 한다.
  //
  // ⚠️ 이름을 high/low로 짓지 않은 이유 — **방향이 반대인 곳이 있다.**
  // 점수는 높을수록 좋고(70점 이상 = good), 폐업 위험도는 높을수록 나쁘다
  // (30% 이상 = bad). 숫자의 크기가 아니라 **뜻**을 이름에 담아야
  // 두 곳이 같은 상수를 쓰면서 헷갈리지 않는다.
  //
  // ⚠️ bad는 shapNegative와 **값이 같지만 별도 상수다.** SHAP 색은 위 주석대로
  // "양수 기여=파랑 / 음수 기여=빨강"으로 의미가 고정돼 있어, 한쪽 의미를
  // 바꿀 때 다른 쪽이 함께 끌려오면 안 된다.
  static const Color good = success; // #16A34A — success와 뜻이 이어져 값을 공유
  static const Color warn = Color(0xFFD97706); // 앰버
  static const Color bad = Color(0xFFDC2626); // 레드

  // 위 3단계의 연한 배경 (보고서 섹션 카드 등).
  // '정보' 톤의 연한 배경은 accentTint(#E3E9F0)가 이미 맡고 있다.
  static const Color goodTint = Color(0xFFE0F0E2);
  static const Color warnTint = Color(0xFFFCECC9);
}

class SurbiRadius {
  static const double pill = 50;
  static const double card = 20;
  static const double chip = 16;
}
