import 'package:flutter/material.dart';

class SurbiColors {
  // ── 메인 컬러 (Primary) ──────────────────
  static const Color primary = Color(0xFF0F766E); // 딥 틸 — 신뢰, 메인 브랜드
  static const Color primaryLight = Color(0xFFCCFBF1); // 연한 틸 — 배경, 검색창

  // ── 성공/완료 컬러 (Success) ──────────────
  static const Color success = Color(0xFF16A34A); // 그라스 그린 — 완료 배지, 체크리스트

  // ── 강조 컬러 (Accent) ────────────────────
  static const Color accent = Color(0xFFA0522D); // 번트 시에나 — 핵심 CTA 버튼, 점수 강조

  // ── 중립 컬러 (Neutral) ────────────────────
  static const Color placeholderGray = Color(0xFFD9D9D9); // 히트맵 placeholder 등
  static const Color textGray = Color(0xFF8E8E8E); // 보조 안내 텍스트

  // ⚠️ 주의: 아래 두 색은 Task 3-4 SHAP 차트 전용으로 예약됨.
  // 다른 용도로 재사용 금지 (양수 기여=파랑, 음수 기여=빨강 의미 고정)
  static const Color shapPositive = Color(0xFF2563EB);
  static const Color shapNegative = Color(0xFFDC2626);
}

class SurbiRadius {
  static const double pill = 50;
  static const double card = 20;
  static const double chip = 16;
}
