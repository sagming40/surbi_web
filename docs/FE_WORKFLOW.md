# 📱 FRONT-END WORKFLOW — 사공민규

| 항목 | 내용 |
| --- | --- |
| 버전 | v5.0 |
| 생성일 | 2026년 6월 18일 |
| 최종 수정 | 2026년 8월 21일 |
| 담당자 | 사공민규 |
| 기술 스택 | Flutter Web · Firebase · Riverpod · go_router · fl_chart · 카카오맵 SDK · intl |

> 📌 **이 문서의 역할 — 현재 상태 + 다음 순서**
> 시제는 **현재·미래**이며, 상태가 바뀌면 **덮어씁니다.**
> **"지금 판단하는 데 필요한 것"만 둡니다.** 완료된 일의 경위·근거·예제 코드는
> [FE_DEVLOG.md](FE_DEVLOG.md)(과거)와 [참고코드_모음.md](참고코드_모음.md)가 담당합니다.
> ※ v5.0에서 707줄 → 약 280줄로 정리 (완료 항목 상세 · `<details>` 코드 이관)

---

## 🔥 다음 할 일

| 순위 | 작업 | 상태 | 비고 |
| --- | --- | --- | --- |
| **1** | **Step 1·2·3 통합 화면** (`feature/frontend-unified-map`) | 🔄 **착수** | 8/21 회의 결정. 아래 "통합 화면 계획" 참고 |
| **2** | Task 4-2 · API 협의 문서 v2.2 송부 | 🔄 진행 | Notion 게시 + Discord 공유 |
| **3** | ⭐ **`GET /api/businesses` 우선 제공 요청 (BE)** | ⏸️ 요청 예정 | 통합 화면의 핵심이 업소 **점** 표시. 데이터는 DB에 적재·검증 완료(537,488건)이고 **엔드포인트만 없음** → BE가 가장 빨리 줄 수 있는 항목 |
| **4** | ⭐ **점수 집계 기준 확인 (ML)** | ⏸️ **회신 필요** | 점수 CSV가 **상권 단위**라 (동×업종) 하나에 행이 최대 5개, 편차 중앙값 23점·최대 96점. 히트맵은 동 하나에 색 하나를 칠해야 하는데 **FE가 임의로 정할 수 없음** (DEVLOG 미해결 10번) |
| 5 | Task 4-2 · 세분화 점수 5종 `scores` 확장 가능 여부 (ML) | ⏸️ 회신 대기 | **Step 4 재설계 여부가 여기서 갈림** |
| 6 | Step 1 히트맵 — **점수 색칠 단계만 남음** | ⏳ 대기 | ①레이아웃 ②경계 렌더 완료(8/20). ③은 `fillColor` 교체 → **4번 회신이 선행** |
| 7 | Task 2-2 · 카카오·네이버 로그인 UI | ⏸️ BE 의존 | 엔드포인트 일정 미회신 |
| 8 | Task 2-5 · Firestore 연동 | ⏳ 대기 | `users`/`favorites` 테이블 존폐 확인 후 |
| 9 | **학교 PC 환경 정비** | ⏳ 대기 | Flutter 3.44.6 → 3.47.1 + `git config core.autocrlf true`. 집 PC는 8/20 완료 |

### 🟢 BE 회신 없이 착수 가능한 작업

> 완료된 항목은 DEVLOG로 보냈습니다. **지금 손댈 수 있는 것만** 남깁니다.

| 작업 | 근거 | 상태 |
| --- | --- | --- |
| **통합 Phase 1** — 상단 바 + 좌측 패널 + 지도 1개 셸 | 8/21 회의 결정 | ⏳ 착수 예정 |
| **통합 Phase 2** — 라우팅 통합 (`/explore/:구?/:동?/:업종?`) | 위와 동일 | ⏳ |
| **통합 Phase 3** — 상권 분석(Step 3)을 패널 탭으로 흡수 | 위와 동일 | ⏳ |
| 업소 마커 **점 렌더 + 축척별 전환** 구조 | 카카오맵형 표현 | ⏳ 구조만 선행 가능 (데이터는 3번 필요) |

---

## 🗺️ 통합 화면 계획 (2026-08-21 회의 결정)

> **결정 내용** — Step 1·2·3을 **하나의 지도 화면**으로 통합. Step 4는 별도 유지.
> 카카오맵은 **모양만 참고**하고 **데이터는 우리 DB**를 쓴다 (카카오 `categorySearch` 미사용).
> 최종 마감(10월) 대상이며, 빠를수록 좋음.

**근거** — 기획서 §7.3에 이미 정의된 레이아웃으로의 복귀다.
`<600px 전체화면 지도 + 하단 시트` / `600~1200 지도 60% + 패널 40%` / `>1200 사이드바 + 지도 + 상세 패널`.
현재의 Step 분리 화면이 오히려 기획서와 어긋나 있었다.

```
[ ‹ 서울특별시 › 마포구 › 망원1동 ]   [구▾][동▾][업종▾]      ← 상단 바
┌──────────────┬───────────────────────────────────────┐
│  좌측 패널     │   지도 (축척에 따라 자동 전환)            │
│  선택 전 → 안내 │   서울 → 자치구 25개 / 구 → 동 / 동 → 업소 점│
│  구 → 동 목록  │                                        │
│  동 → 업소 리스트│                              [+][−][지도/위성]│
│      + 분석 탭 │                                        │
└──────────────┴───────────────────────────────────────┘
                          [ AI 창업 점수 보기 → ]  → Step 4
```

| Phase | 내용 | BE 의존 |
| --- | --- | --- |
| ~~0~~ | ~~URL 미동기화 버그 수정~~ | ✅ **완료** (2026-08-21) |
| 1 | 통합 셸 — 상단 바 + 좌측 패널 + 지도 1개 | ❌ |
| 2 | 라우팅 통합 (Step 4는 `/score` 유지) | ❌ |
| 3 | 상권 분석을 패널 탭으로 흡수 | ❌ |
| 4 | 업소 **점** 렌더 + 축척별 전환 + 클러스터링 | ⏸️ `GET /api/businesses` |
| 5 | 히트맵 점수 색칠 | ⏸️ 점수 집계 기준 회신 |

> 💡 **Flutter Web 선택 근거와 충돌하지 않는다.** 기획서 §7.2의 선택 이유는
> ①로그인 후 쓰는 대시보드라 SEO 불필요 ②CanvasKit이 지도·차트 등 복잡한 UI에 강함
> ③단일 코드베이스 — **크로스 플랫폼이 아니다.** 웹 전용 코드는 지도 2파일
> (`kakao_map_interop` · `kakao_map_view_registry`)뿐이며, `models`·`providers`·`services`는
> 플랫폼 무관하게 유지된다.

---

## 🚧 현재 블로커

| # | 블로커 | 성격 | 해소 조건 |
| --- | --- | --- | --- |
| **B1** | `scores`에서 세부 점수 7종 + `score_reason` 전부 삭제됨 | 설계 붕괴 | ML이 세분화 점수 5종을 함께 내려줄 수 있는지 회신 |
| **B4** | LLM 보고서 입력값이 무엇인지 불명 | 명세 미확정 | ML·BE 회신 |
| **B5** | 점수 CSV가 **상권 단위** → 히트맵 색을 칠할 근거 없음 | 설계 붕괴 | ML 집계 기준 회신 (DEVLOG 미해결 10번) |

> ~~B2 `buildings` 테이블 부재~~ · ~~B3 Step 순서 불일치~~ → 2026-08-16 해소

### ❓ 착수 전 결정이 필요한 사항

| 항목 | 내용 | 상태 |
| --- | --- | --- |
| **8/18 회의의 Step 1 지시 내용** | ⚠️ **기록이 없음.** 기억으로는 "카테고리 선택 시 해당 업종 마커 표시"이나 Step 2와 중복 | ⏸️ 회의록 확인 또는 다음 회의에서 재확인 |
| **점수 없는 동의 히트맵 표시 규칙** | 커버리지가 업종별 43~92% → 최대 243개가 빈칸. 회색 유지 / 빗금 / 제외 중 택1 | ⏸️ 점수 색칠 착수 전 |
| **선택 동 강조 방식** | 현재 주황 **채움** → 점수 색이 면에 들어오면 그 동의 점수를 덮음 → **테두리 강조로 전환** 필요 | ⏸️ 점수 색칠 착수 시 |
| Step 4 접근 조건 | A: 로그인 필수 / B: 비로그인 허용 | ⏸️ Task 2-3 착수 전 |
| `users`/`favorites` 테이블 존폐 | 최신 ERD(7/20)에서 사라짐 → 스크랩 기능 근거 | ⏸️ DB 확인 |
| 업종 코드 변환 주체 | `businesses`=I/R코드 ↔ `sales_stats`·`scores`=CS코드 | ⏸️ BE 확인 |

---

## 📊 진행 현황

| EPIC | 내용 | 진행 | 상태 |
| --- | --- | --- | --- |
| **1** | 환경 구축 & 기반 설계 | 7 / 7 | ✅ 완료 |
| **2** | 인증 & 사용자 관리 | 1 / 5 | 🔄 Task 2-1만 완료 (PR #9) · 나머지 BE 의존 |
| **3** | Step 1~4 핵심 화면 개발 | 7 / 7 | ✅ 완료 (B1·B5로 Step 4 재설계 가능성) |
| **4** | 백엔드 API 연동 | 0 / 6 | 🔄 4-2 협의 중 |
| **5** | 품질 검증 & 배포 | 0 / 4 | ⏳ 대기 |

**브랜치 전략** — 1인 프론트 독립 개발이라 PR 승인 없이 `main` 직접 작업 가능.
단 **화면 전체 리팩터링·실험적 시도는 임시 브랜치** (상세: [BRANCH_STRATEGY.md](BRANCH_STRATEGY.md))

**팀 정기회의 지시 이행** — 7/13 지시 ①~⑤ **전부 완료**(①반응형은 8/20 Step 1 재설계와 함께 해소) ·
8/18 지시 ①② **전부 완료** · 8/21 지시(통합) **착수**. 경위는 DEVLOG 참조.

---

## 🔌 확정된 데이터 계약

> 팀 문서(DB 4_0 ERD / 3_3 / 3_4, ML 4_2 / 4_3 / 5_) 기준.
> **`models/` 필드명은 이 표를 정본으로 삼는다.**

### 업종 — CS코드 외식업 10종 (확정)

```
CS100001 한식음식점    CS100006 패스트푸드점
CS100002 중식음식점    CS100007 치킨전문점
CS100003 일식음식점    CS100008 분식전문점
CS100004 양식음식점    CS100009 호프-간이주점
CS100005 제과점        CS100010 커피-음료
```

⚠️ `businesses`는 **다른 코드 체계(I/R코드)** → 지도 마커와 점수를 함께 쓰려면 변환 필요

### `scores` — AI 창업 점수 (⚠️ 전면 축소됨)

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `score` | number 0~100 | 종합 창업 점수 |
| `expected_sales` | integer | 예상 월매출 — **가게 1곳당 평균 근사치** |
| `closure_risk` | number 0~100 | 폐업 위험도 (높을수록 위험) |

- 조회 단위: **행정동 × 업종** (건물 단위 아님) · `period_code`는 2026-08-12 제거 확정
- **삭제됨**: `total_score` 외 세부 점수 7종 · `model_version` · `score_reason`

**화면 표시 규칙 (ML 요청)**
- `closure_risk` → 수치 대신 **"낮음/보통/높음" 등급**
- `expected_sales` → **"가게 1곳당 평균 추정치"** 문구 병기 · **0원 1,454건**, 최대 612억 → 표시 가드
- 전반 → **"참고용 지표"** 안내 (매출 R²≈0.37, 폐업 정확도≈0.43)

**⚠️ 2026-08-20 CSV 실측 — 문서 기재와 실제가 다름**

| 업종 | 커버 동 | 업종 | 커버 동 |
| --- | --- | --- | --- |
| 한식음식점 | 392 (92%) | 패스트푸드점 | 258 (61%) |
| 커피-음료 | 373 (88%) | 제과점 | 272 (64%) |
| 호프-간이주점 | 359 (84%) | 일식음식점 | 210 (49%) |
| 분식전문점 | 355 (84%) | **양식음식점** | **182 (43%)** |
| 치킨전문점 | 313 (74%) | 중식음식점 | 268 (63%) |

- "점수 없는 동 30개"는 낙관적이었고 실제로는 **최대 243개** → 빈 결과 화면이 아니라
  **히트맵 기본 표시 규칙**으로 다뤄야 함
- **CSV가 상권 단위** — `commercial_area_code` 존재. (동×업종) 2,982조합 중 **1,808개(61%)가 다중 행**,
  편차 **중앙값 23점·최대 96점**. 집계 기준 확정 전에는 색칠 불가

### 히트맵 — 경계 데이터

| 항목 | 상태 |
| --- | --- |
| `districts.geom` 적재 | ✅ 완료 (2026-08-17 DB팀 확인) |
| `/api/map/heatmap` 엔드포인트 | ❓ 미확인 — 컬럼 적재 ≠ API 완성 |
| **FE 자체 경계 데이터** | ✅ 확보 (8/20) — **API 없이도 경계 렌더 가능** |
| 렌더 단위 | **축척 2단계** — 초기 = 자치구 25개 / 구 선택 후 = 그 구의 행정동 |
| 성능 (실측) | 구당 폴리곤 10~27개 / 좌표 109~241개 / **렌더 1~3ms**. 비용은 폴리곤 수가 아니라 **좌표 수**에 비례(≈100좌표당 1ms) |
| 서울 전역 425개 상시 렌더 | ❌ 폐기 — 생성은 19~21ms로 빨랐으나 **드래그·줌 유지 비용**이 큼. 자치구 25개(1,022좌표)로 교체 → 4~5ms |

### `government_supports` — 정부 지원사업

| FE 필드 | DB 컬럼 | 비고 |
| --- | --- | --- |
| 사업명 | `title` | ⚠️ `pblanc_nm` 아님 |
| 공고 ID | `pblanc_id` | UNIQUE |
| 기관 | `agency` / `jrsd_instt_nm` | ⚠️ 두 컬럼 의미가 문서마다 달라 **라벨 확정 필요** |
| 요약 | `summary` | HTML 제거 후 저장 |
| 신청기간 | `sprt_start_date` / `end_date` | 마감 필터는 BE 처리 |
| 링크 | `support_url` | |

**업종·지역 필터 불가**(컬럼 없음) → 전체 표시 · 1,417건 · 매주 월요일 갱신

### 기타 확정 사항

| 항목 | 내용 |
| --- | --- |
| 행정동 | `districts` 427건 · 자치구 25개 — 목록 API 제공 가능<br>⚠️ FE 보유 경계는 **425건** — 개편 시점 차이 추정 (DEVLOG 미해결 9번) |
| 업소 마커 | `businesses` **537,488건** — 조회 검증 완료. **엔드포인트만 미제공** |
| 임대료 | `rent_stats` — **자치구 단위**만 가능 → 화면 문구 명시 |
| 상권변화 | `market_trends.trend_grade`(HH/HL/LH/LL) — **BE가 문구까지 제공** |
| 체크리스트 | DB 테이블 없음 → **FE 고정 문구** |
| AR 기능 | Flutter **App 전용** → FE(Web) 담당 범위 아님 |

---

## 💻 개발 환경

| 환경 | Flutter | Dart | `core.autocrlf` | 확인일 |
| --- | --- | --- | --- | --- |
| **집 데스크탑** | **3.47.1** (`C:\src\flutter`) | 3.13.1 | ✅ true | 2026-08-20 |
| **학교 PC** | 3.44.6 | 3.12.2 | ❌ 미설정 | 2026-08-16 |

> ⚠️ **`lib/main.dart`의 `import 'package:flutter/cupertino.dart';`는 삭제 금지** —
> 구버전에선 불필요 경고가 뜨지만 신버전에선 필수다. 환경마다 반대 방향으로 잔소리하므로,
> **에러(신버전) > 경고(구버전)** 기준으로 판단한다.

**학교 PC 정비 절차** (집 PC는 8/20 완료 · 상세 경위는 DEVLOG 2026-08-20)
1. SDK 폴더를 **`C:\src\flutter`처럼 짧은 경로로 먼저 이동** ← 윈도우 260자 경로 제한 회피
2. `flutter upgrade --force` (**붙여쓸 것** — `-- force`로 띄우면 `--`가 옵션 종료 신호가 되어 실패)
3. 실패 시 `adb.exe` 등이 SDK 파일을 잡고 있는지 `resmon` → CPU → **연결된 핸들**로 확인
4. `git config core.autocrlf true`
5. 두 환경이 같아진 뒤 `pubspec.yaml`에 `environment.flutter: ">=3.47.0"` 명시

---

## 📦 패키지

| 패키지 | 버전 | 용도 |
| --- | --- | --- |
| flutter_riverpod | ^2.5.1 | 상태관리 |
| go_router | ^14.2.0 | 라우팅 |
| flutter_web_plugins | sdk | `usePathUrlStrategy` |
| fl_chart | ^0.68.0 | 차트 |
| intl | ^0.20.3 | 숫자 포맷 |
| web | ^1.1.1 | `dart:html` 대체 |
| firebase_core / firebase_auth / cloud_firestore | ^3.3.0 / ^5.1.0 / ^5.2.0 | 인증·저장 |
| url_launcher | ^6.3.1 | 외부 링크 |

> ⚠️ `riverpod_annotation` · `riverpod_generator` · `build_runner`는 **설치만 되고 미사용**
> (`.g.dart` 0개). 전통 방식(`Provider`/`StateNotifierProvider`)으로 구현 중 → 제거 검토
> ⚠️ `collection`은 **transitive dependency**이므로 직접 사용 금지

## 📂 Assets

| 경로 | 크기 | 내용 |
| --- | --- | --- |
| `assets/geo/seoul_dong.json` | 146KB | 서울 425개 행정동 경계. 행정안전부 고시 기준, mapshaper 10% 간소화. 좌표 4,396개 |
| `assets/geo/seoul_gu.json` | 24KB | 서울 25개 자치구 경계. **위 파일을 병합(dissolve)해 생성** — 별도 출처 없음. 좌표 1,022개 |

> ⚠️ **assets 추가·변경은 hot reload로 반영되지 않음** — 앱 완전 재시작 필요

---

## 📁 폴더 구조

```
lib/                                (총 42개 파일)
├── main.dart                     # ProviderScope + GoRouter + 카카오맵 뷰 등록
├── firebase_options.dart
├── data/                         # 스크립트 생성 데이터 전용 — 로직 금지
│   └── seoul_districts.dart      # 서울 425개 행정동 (수동 편집 금지)
├── app/
│   ├── router.dart               # go_router 전체 라우트 (StatefulShellRoute 포함)
│   └── theme.dart                # SurbiColors · TextStyle · ButtonStyle
├── models/                       # 7개
│   ├── region.dart · business.dart · area_analysis.dart
│   ├── score_result.dart         # ⚠️ B1 — scores 축소로 재설계 대상
│   └── report.dart · government_policy.dart · checklist_item.dart
├── services/                     # 2개 (⚠️ 웹 전용 — 앱 이식 시 교체 대상)
│   ├── kakao_map_interop.dart         # dart:js_interop 통역 레이어
│   ├── kakao_map_view_registry.dart   # HtmlElementView 등록 + 마커/오버레이/경계 폴리곤
│   ├── (예정) auth_service.dart       # Task 2-2
│   └── (예정) api_service.dart        # Task 2-4
├── providers/                    # 6개
│   └── region · business · area · score · checklist · auth
├── views/                        # 5개
│   ├── region_select_page.dart   # ① [구▾][동▾][업종▾] + 전체 화면 지도 (발견 화면)
│   ├── map_page.dart             # ② 업소 지도 + CustomOverlay 카드
│   ├── analysis_page.dart        # ③ 상권 분석 (매출 TOP5 + 지표 4종)
│   ├── policy_list_page.dart · checklist_page.dart
│   └── (예정) landing · login · auth_callback
└── widgets/                      # 17개
    ├── common/                   # 7개
    │   ├── surbi_dropdown.dart   # OverlayEntry + LayerLink
    │   │                         #   openUpward · onMenuVisibilityChanged 옵션
    │   ├── responsive_layout.dart · surbi_app_bar.dart · surbi_card.dart
    │   └── surbi_loading · surbi_error · surbi_empty
    └── step4/                    # 10개 ⚠️ 폴더명만 Step 번호 잔존 — 정리 검토 대상
        ├── score_shell.dart      # ④ 허브 — LayoutBuilder 900px 분기 + 탭바
        ├── score_hub_panel · score_gauge · shap_bar_chart(⚠️ B1)
        ├── report_loading · report_viewer · report_page
        └── policy_card · checklist_item_card · checklist_progress_bar
```

### 🗺️ 라우트 맵

| 팀 호칭 | URL | 화면 파일 |
| --- | --- | --- |
| — | `/` · `/login` | (PlaceholderPage) |
| Step 1 | `/select` | `region_select_page.dart` |
| Step 2 | `/map/:districtCode/:categoryCode` | `map_page.dart` |
| Step 3 | `/analysis/:districtCode/:categoryCode` | `analysis_page.dart` |
| Step 4 | `/score/:districtCode/:categoryCode` | `score_shell.dart` |
| └ 자식 | `/score/.../report` · `/policies` · `/checklist` | 각 페이지 |

> ⚠️ **화면 이동은 `context.go`만 사용한다.** `context.push`는 go_router 8.0+ 에서
> Flutter Web 주소창을 갱신하지 않는다 (2026-08-21 해소, DEVLOG 참조).
> `go`는 스택을 쌓지 않으므로 **뒤로가기 목적지는 각 화면이 직접 지정**한다.
> ⚠️ Step 1·2·3 통합 시 이 표는 `/explore` 계열로 재편 예정. Step 4는 유지.

---

## 📋 EPIC 요약

### ✅ EPIC 1 · 환경 구축 & 기반 설계 — 완료
Flutter Web 프로젝트 · 반응형 틀 · **Riverpod** · **go_router** · 공통 위젯 3종 ·
브랜치 전략 · Figma 와이어프레임. 설계 근거는 DEVLOG / [참고코드_모음.md](참고코드_모음.md)

### 🔄 EPIC 2 · 인증 & 사용자 관리

> 카카오/네이버 OAuth → 백엔드가 Firebase Custom Token 발급 → FE는 `signInWithCustomToken()`
> 📎 상세 설계: **FE_구현설계_참고_Task2-2_카카오네이버로그인.md**

- ✅ **2-1** Firebase 연동 (PR #9, 8/3 병합)
- ⏳ **2-2** 소셜 로그인 — 카카오/네이버 앱 등록 · `auth_service.dart` · `auth_callback_page.dart` · Custom 제공업체 활성화
- ⏳ **2-3** 로그인 상태 라우팅 — `authState` Provider · `redirect` 로직 · 콜백 경로 제외 처리 ❓Step 4 접근 조건 선결
- ⏳ **2-4** API 토큰 자동 첨부 — `api_service.dart` · 401 시 자동 로그아웃
  > ⚠️ `flutter_secure_storage`는 Web에서 `localStorage`라 XSS 취약 → **Firebase가 관리하게 두고 매 요청 `getIdToken()`**
- ⏳ **2-5** Firestore 스크랩/리포트 — ⚠️ `users`·`favorites` 테이블 존폐 확인 **선행**. 구조·Rules는 [참고코드_모음.md](참고코드_모음.md)

### ✅ EPIC 3 · Step 1~4 핵심 화면 — 완료 (잔여 항목만 아래)

| Step | 미완 항목 | 연결 |
| --- | --- | --- |
| 1 | 구/동 목록 하드코딩 제거 → 목록 API | Task 4-3 (8/20에 실데이터 425건으로 교체는 완료) |
| 1 | 히트맵 점수 색칠 | **B5 해소 후** |
| 1 | 업종 선택이 지도에 반응 안 함 | ⏳ 의도된 상태 — 업종의 역할은 마커 필터가 아니라 **히트맵 색 전환**이라 ③과 함께 연결 |
| 2 | 마커 클러스터링 · 오버레이 카드 거리 표시 | Task 4-5 (실데이터 후) |
| 3 | 소비 패턴(시간대/성별/연령) 차트 | Task 4-4 |
| 4 | 세부 점수·SHAP 패널 존폐 | ⏸️ **B1** |
| 4 | PDF 다운로드 · Firestore 저장 | 추후 / Task 2-5 |

### 🔵 EPIC 4 · 백엔드 API 연동

> 📎 **명세 전문**: [API_명세_협의_요청사항.md](API_명세_협의_요청사항.md) (v2.1)
> ❌ Task 4-1 Mock 데이터 — **폐기** (6/29 회의)

**미회신 항목** — P1-1 세분화 점수(ML) · P1-2 LLM 입력값(ML·BE) · P1-4 업종 코드 변환 주체(BE) · P1-5 인증 일정(BE)

| 메서드 / 경로 | 사용처 | 상태 |
| --- | --- | --- |
| `GET /api/businesses?district_name=&category_code=` | 업소 지도 마커 (**점 표시**) | 🆕 ⭐ **최우선 요청** |
| `GET /api/districts?gu=` | 구/동 드롭다운 | 🆕 제공 가능 확인 |
| `GET /api/categories` | 업종 드롭다운 | 🆕 |
| `GET /api/map/heatmap?category_code=` | 히트맵 (GeoJSON + score) | 🔄 완성 여부 미확인 (FE 자체 경계로 우회 가능) |
| `GET /api/analysis?district_name=&category_code=` | 상권 분석 (5종 통합) | 🆕 BFF형 |
| `GET /api/scores?district_name=&category_code=` | Step 4 점수 3종 | 🔄 파라미터 변경 |
| `GET /api/supports?period=current` | 정부지원 (필터 없음) | 🔄 |
| `POST /reports/generate` · `GET /reports/{id}` | 보고서 생성/폴링 | ⏸️ 입력값 미정 |
| `POST /auth/kakao` · `POST /auth/naver` | 로그인 콜백 | ⏸️ 일정 미정 |
| ~~`POST /favorites`~~ | ~~스크랩~~ | ❌ 테이블 부재 |

**Task 4-3~4-7** — 4-3 Step 1(목록·히트맵) · 4-4 상권 분석 바인딩 · 4-5 업소 마커 ·
4-6 점수 + 보고서 폴링(3초×20회, 코드는 [참고코드_모음.md](참고코드_모음.md)) · 4-7 로그인 백엔드 연동

### 🔵 EPIC 5 · 품질 검증 & 배포

- ⏳ **5-1** CanvasKit 로딩 스플래시 — 첫 방문 시 5~8MB Wasm 다운로드로 흰 화면 이탈 위험.
  로고(192×192) 준비 + `web/index.html` 오버레이 ([참고코드_모음.md](참고코드_모음.md))
- ⏳ **5-2** 에러 케이스 점검 — 네트워크 없음 / API 500 / 빈 결과 / **점수 없는 동(최대 243개)** /
  `expected_sales` 0원·극단값 / 로그인 만료 / 보고서 타임아웃
- ⏳ **5-3** 빌드 최적화 — `flutter build web --release`, **15MB 이하** 목표
- ⏳ **5-4** Firebase Hosting 배포 + URL 팀 공유 + 모바일 실기기 테스트

---

## 🔗 링크

**GitHub** — https://github.com/sagming40/surbi_web
**실행** — `flutter run -d chrome --web-port=5000` (카카오맵 도메인 등록 때문에 포트 고정 필수)
**Figma** — [Surbi 와이어프레임](https://www.figma.com/design/EN5re8TzbBLQcQLznIOjmJ/Surbi---Figma-와이어프레임?node-id=0-1)

**저장소 문서 (`docs/`)**
- [FE_DEVLOG.md](FE_DEVLOG.md) — 개발 일지 (과거 · 트러블슈팅 · **상시 규칙** · **미해결 현황**)
- [archive/FE_DEVLOG_2026-06_07.md](archive/FE_DEVLOG_2026-06_07.md) — 6~7월 일지 아카이브
- [참고코드_모음.md](참고코드_모음.md) — 나중에 쓸 코드 조각 (Riverpod 패턴 · Firestore Rules · 폴링 · 로딩 오버레이)
- [API_명세_협의_요청사항.md](API_명세_협의_요청사항.md) · [BRANCH_STRATEGY.md](BRANCH_STRATEGY.md) · [DESIGN.md](DESIGN.md)

**팀 참조 (Notion)** — DB `4.0 ERD 설계`·`3.3`·`3.4` / ML `4.2`·`4.3`·`5.`

---

*FRONT-END WORKFLOW v5.0 · 사공민규 · 최종 수정: 2026.08.21*
