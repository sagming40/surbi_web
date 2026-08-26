import 'package:flutter/material.dart';

class SurbiColors {
  // ── 메인 컬러 (Primary) ──────────────────
  static const Color primary = Color(0xFFF8FAFA); // 은백색 — 배경 (최종 확정)
  static const Color primaryLight = Color(0xFFCCFBF1); // 연한 틸 (미사용)

  /// 상단 바 배경 (2026-08-26 추가)
  ///
  /// 본문 배경(primary #F8FAFA)보다 **한 톤 밝은 순백**이다.
  /// 8/26 오전에는 상단 바도 primary로 통일했는데, 그러면 바가 본문에 녹아
  /// **어디까지가 바인지 안 보인다.** 통일해야 할 것은 "같은 색"이 아니라
  /// "같은 규칙"이었다 — 바는 어느 화면에서든 본문보다 한 톤 밝다.
  ///
  /// 면의 밝기 차 + 아래 divider를 함께 쓴다. 둘 중 하나만으로도 경계는
  /// 생기지만, 같이 쓰면 선을 1px로 얇게 두고도 확실히 읽힌다.
  static const Color barSurface = Color(0xFFFFFFFF);

  /// 구분선 (2026-08-26 추가)
  ///
  /// placeholderGray(#D9D9D9)를 재활용하지 않는 이유 — 그건 히트맵 빈칸을
  /// 채우는 **면** 색이라 1px 선으로 쓰면 너무 진해 화면을 자른다.
  /// 같은 회색이라도 면에 쓸 때와 선에 쓸 때 필요한 농도가 다르다.
  static const Color divider = Color(0xFFE5E9E9);

  /// 컨트롤 윤곽선 (2026-08-26 추가)
  ///
  /// divider와 **거의 같은 회색인데 왜 따로 두나** — 쓰이는 모양이 달라서다.
  ///   · divider — 화면을 가로지르는 **긴 직선**. 길어서 옅어도 눈에 들어온다.
  ///   · border  — 알약 모양 컨트롤을 **감싸는 짧고 굽은 선**. 같은 농도면 묻힌다.
  /// 회색 세 개(divider · border · placeholderGray)가 비슷해 보이지만
  /// 각자 하는 일이 다르다: 가르는 선 / 두르는 선 / 채우는 면.
  static const Color border = Color(0xFFDAE0E0);

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

/// 상단 바 규격 (2026-08-26 추가)
///
/// SurbiAppBar와 ExploreTopBar가 **세로 크기를 공유**하기 위한 값이다.
/// 예전에는 SurbiAppBar가 Material 기본값 kToolbarHeight(56), ExploreTopBar가
/// 패딩+드롭다운으로 76이 되어 **두 화면을 오갈 때 바 높이가 20px 널뛰었다.**
///
/// 낮은 쪽(56)에 맞추지 않은 이유 — 바 안에 드롭다운(52)이 들어가야 하는데
/// 56에 넣으면 위아래 여백이 2px밖에 안 남는다.
/// **내용이 있는 쪽이 높이를 정한다.**
class SurbiBar {
  /// 바 안에 들어가는 컨트롤(드롭다운)의 높이.
  /// ⚠️ SurbiDropdown.collapsedHeight가 **이 값을 읽는다** — 반대가 아니다.
  static const double controlHeight = 52;

  static const double verticalPadding = 12;
  static const double horizontalPadding = 16;
  static const double dividerHeight = 1;

  /// 구분선을 뺀 바 자체의 높이.
  static const double height = verticalPadding * 2 + controlHeight; // 76

  /// 구분선까지 포함한 높이 — AppBar의 preferredSize가 이 값이어야 한다.
  /// 안 더하면 선 높이만큼 본문이 바 밑으로 파고든다.
  static const double totalHeight = height + dividerHeight; // 77
}

/// 마우스·터치 반응 농도 (2026-08-26 추가)
///
/// 약한 신호(지나감)와 강한 신호(눌렀음)의 세기가 같으면 사용자는 방금 무슨 일이
/// 일어났는지 구분하지 못한다. 그래서 **한 계단씩** 올린다.
class SurbiOverlay {
  static const double hover = 0.04; // 마우스 올림
  static const double highlight = 0.06; // 누르는 중
  static const double focus = 0.08; // 키보드 포커스
  static const double pressed = 0.10; // 눌림·물결

  /// IconButton 전용 오버레이 — 상태를 보고 위 농도 중 하나를 고른다.
  ///
  /// ⚠️ **테마에만 둬서는 AppBar 안에서 안 먹는다.** (2026-08-26에 배운 것)
  ///    Material 3의 AppBar는 자기 leading·actions를 감쌀 IconButtonTheme을
  ///    **스스로 만들어 씌운다.** 그게 main.dart에 둔 전역 설정보다 위젯에
  ///    더 가까우므로 이긴다 — Theme은 명령이 아니라 상속이고,
  ///    상속은 언제나 **가장 가까운 조상**이 이긴다.
  ///    그래서 AppBar 안의 IconButton에는 위젯에 직접 넘겨야 한다.
  ///    (main.dart의 전역 설정과 SurbiAppBar가 이 하나를 같이 읽는다)
  static final WidgetStateProperty<Color?> iconButton =
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return SurbiColors.accent.withValues(alpha: pressed);
        }
        if (states.contains(WidgetState.hovered)) {
          return SurbiColors.accent.withValues(alpha: hover);
        }
        if (states.contains(WidgetState.focused)) {
          return SurbiColors.accent.withValues(alpha: focus);
        }
        return null;
      });
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
  static const double title = 20; // 화면 안의 큰 제목 (분석 화면 헤더 등)
  // ⚠️ 상단 바가 여기 있는 이유 — AppBar 제목과 ExploreTopBar 드롭다운이
  //    **같은 크기여야** 두 화면의 바가 같은 물건으로 보인다. (2026-08-26)
  //    화면 제목 > 카드 제목의 위계는 크기가 아니라 **위치**(바 안 vs 카드 안)와
  //    그 사이의 구분선이 만든다.
  static const double subtitle = 16; // 섹션·카드 제목 · 상단 바
  static const double body = 14; // 본문
  static const double label = 13; // 라벨·보조 (가장 많이 쓰인다)
  static const double caption = 11; // 각주·배지
}
