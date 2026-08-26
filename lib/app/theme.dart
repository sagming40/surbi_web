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
  /// 본문 글자색 (2026-08-26 추가)
  ///
  /// 지금까지 본문용 상수가 없어서 화면마다 Material 기본값을 골라 썼다 —
  /// black87 / black54 / grey[700] / grey[800] / Colors.black **다섯 갈래.**
  /// 위계는 세 단계면 충분하다:
  ///   제목·강조 → accent (#1E3A5F)
  ///   본문      → textPrimary
  ///   보조·힌트 → textGray (#8E8E8E)
  ///
  /// 순검정(#000)을 쓰지 않는 이유 — 은백 배경(#F8FAFA) 위에서 대비가 너무 강해
  /// 글자만 도드라진다. accent와 같은 네이비 계열로 살짝 눕혔다.
  static const Color textPrimary = Color(0xFF333A42);

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

  /// 배지·태그·작은 버튼 (2026-08-26 추가) — 흩어져 있던 10·8·6을 흡수
  static const double small = 8;

  /// 막대 끝·진행바 (2026-08-26 추가) — 흩어져 있던 3을 흡수
  static const double tiny = 4;
}

/// 그림자 — 은백 배경 위에 흰 카드를 띄우는 규칙 (2026-08-26 추가)
///
/// `Colors.black.withValues(alpha: 0.05)`와 **같은 값**을 `Color(0x0D000000)`으로
/// 적은 이유: withValues는 런타임 계산이라 const가 안 되지만 이 형태는 된다.
/// (0x0D = 13 ≈ 255 × 0.05)
class SurbiShadow {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

/// 글자 크기 사다리 (2026-08-26 추가)
///
/// 도입 전 실측 — **12종류가 41곳**에 흩어져 있었다.
///   13×13  12×5  20×4  16×4  14×4  15×3  11×3  22×2  40·24·18·17·10 각 1회
/// 17이나 10처럼 한 번만 쓰인 값은 그때그때 눈대중으로 정한 것이다.
///
/// ⚠️ 지금은 **상수만 만들고, 값이 이미 같은 곳부터** 교체한다.
/// 22·18·17·15·12·10처럼 사다리와 어긋나는 값은 실물을 보며 하나씩 판단한다 —
/// 한 번에 다 바꾸면 어디가 어색해졌는지 찾을 수 없다. (DEVLOG 2026-08-20)
class SurbiText {
  static const double display = 40; // 점수 게이지 숫자
  static const double title = 20; // 화면·카드 제목
  static const double subtitle = 16; // 섹션 제목·AppBar
  static const double body = 14; // 본문
  static const double label = 13; // 라벨·보조 (가장 많이 쓰인다)
  static const double caption = 11; // 각주·배지
}
