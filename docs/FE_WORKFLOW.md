# 📱 FRONT-END WORKFLOW — 사공민규

| 항목 | 내용 |
| --- | --- |
| 버전 | v4.5 |
| 생성일 | 2026년 6월 18일 |
| 최종 수정 | 2026년 8월 20일 |
| 담당자 | 사공민규 |
| 기술 스택 | Flutter Web · Firebase · Riverpod · go_router · fl_chart · 카카오맵 SDK · intl |

> 📌 **이 문서의 역할 — 현재 상태 + 다음 순서**
> 시제는 **현재·미래**이며, 상태가 바뀌면 **덮어씁니다.**
> 과거에 있었던 일(오류·판단 배경·PR 이력)은 **[docs/FE_DEVLOG.md]**가 담당합니다.

> 💡 **전체 흐름** — 환경 구축 → 인증 → 화면 개발 → API 연동 → 품질 & 배포
> 🗺️ **사용자 플로우 (2026-08-16 재구조화)** — ① 지역·업종 선택 → ② 업소 지도 → ③ 상권 분석 → ④ AI 점수 허브
> 8/3 대조표 회의 안건 2 "지도 먼저" 결정 반영. 경로에서 Step 번호 제거 — 아래 "라우트 맵" 참고.

---

## 🔥 다음 할 일

| 순위 | 작업 | 상태 | 비고 |
| --- | --- | --- | --- |
| **1** | **Task 4-2 · API 협의 문서 v2.0 송부** | 🔄 진행 | Notion 게시 + Discord 공유 |
| **2** | Task 4-2 · 세분화 점수 5종 `scores` 확장 가능 여부 (ML) | ⏸️ 회신 대기 | **Step 4 재설계 여부가 여기서 갈림** |
| **3** | **⭐ 점수 집계 기준 확인 (ML)** | ⏸️ **회신 필요** | `surbi_final_scores.csv`가 **상권 단위**(`commercial_area_code` 포함)라 (동×업종) 조합 하나에 행이 최대 5개. **점수 편차 중앙값 23점 · 최대 96점.** 히트맵은 동 하나에 색 하나를 칠해야 하는데 어느 값을 쓸지 근거가 없음 (평균/최대/상권규모 가중?) — **FE가 임의로 정할 수 없는 값** |
| 4 | Step 1 히트맵 — **점수 색칠 단계만 남음** | ⏳ 대기 | ①레이아웃 ②경계 렌더 모두 완료(8/20). ③은 `fillColor`를 점수 기반 함수로 교체 → **3번 회신이 선행** |
| 5 | Task 2-2 · 카카오·네이버 로그인 UI | ⏸️ BE 의존 | 엔드포인트 일정 미회신 |
| 6 | Task 2-5 · Firestore 연동 | ⏳ 대기 | `users`/`favorites` 테이블 존폐 확인 후 |
| 7 | `context.push()` URL 미동기화 버그 원인 조사 | ⏳ 대기 | EPIC 5 배포 전 필수 (DEVLOG 미해결 7번) |
| 8 | **학교 PC 환경 정비** | ⏳ 대기 | Flutter 3.44.6 → 3.47.1 + `git config core.autocrlf true`. 집 PC는 8/20 완료 |

### 🟢 BE 회신 없이 착수 가능한 작업

| 작업 | 근거 | 상태 |
| --- | --- | --- |
| Step 1 카테고리 버튼 → CS코드 외식업 10종 교체 | DB팀 3_3 [전체] 3번 | ✅ **완료** (Phase 1.5) |
| 상권분석 화면 지표 표기 정정 (경쟁도 %→개수, 유동인구 축약, 임대료 자치구 명시, 기준분기 표기) | 대조표 🟢 2·3·5·7번 | ✅ **완료** (Phase 4) |
| 체크리스트 항목 **FE 고정 문구로 확정** | DB팀 3_3 [전체] 6번 | ✅ **완료** (2026-08-18, 6개 항목 + 카테고리 색상) |
| 정책 리스트 **category 필드 제거** | DB팀 3_3 [BE] 1번 | ✅ **완료** (2026-08-18, UI는 원래 필터 없었음) |
| 업소 지도 컨트롤 UI 보강 (하단 구/동 드롭다운 · 줌/스카이뷰 · 컨텍스트 바) | 8/18 회의 지시 ①② | ✅ **완료** (2026-08-19) |
| 행정동 경계 폴리곤 표시 + 행정동 목록 실데이터 425건 교체 | 8/18 회의 지시 ② 심화 | ✅ **완료** (2026-08-20) |
| Step 1 구 전체 동 경계 렌더 (히트맵 밑그림) + 성능 계측 | 히트맵 3단계 중 ② | ✅ **완료** (2026-08-20) — 구당 1~3ms 확인 |
| 경계 시인성 재설계 (코로플레스 방식 · 화면별 강조값 분리) | 위 작업의 후속 | ✅ **완료** (2026-08-20) |
| **Step 1 화면 재설계** — 카테고리 칩 → 드롭다운 · 지도 확대 · 반응형 | 7/13 회의 지시 ① + 히트맵 전제조건 | ✅ **완료** (2026-08-20) |
| 초기 화면에 자치구 25개 경계 표시 | 위 작업의 후속 (지도가 장식으로 보이던 문제) | ✅ **완료** (2026-08-20) |

---

### 🚧 현재 블로커

| # | 블로커 | 성격 | 해소 조건 |
| --- | --- | --- | --- |
| **B1** | **`scores` 테이블에서 세부 점수 7종 + `score_reason` 전부 삭제됨** | 설계 붕괴 | ML이 세분화 점수 5종을 함께 내려줄 수 있는지 회신 |
| ~~B2~~ | ~~`buildings` 테이블 부재~~ | ✅ **해소** | 8/16 Phase 3 — Building → Business(업소) 재정의 완료 |
| ~~B3~~ | ~~Step 순서 불일치~~ | ✅ **해소** | 8/3 대조표 안건 2 "지도 먼저" 확정 → 8/16 Phase 1 반영 완료 |
| **B4** | LLM 보고서 입력값이 무엇인지 불명 (`score_reason` 소멸) | 명세 미확정 | ML·BE 회신 |

### ❓ 착수 전 결정이 필요한 사항

| 항목 | 내용 | 상태 |
| --- | --- | --- |
| Step 4 접근 조건 | A: 로그인 필수 / B: 비로그인 허용 | ⏸️ 미정 (Task 2-3 착수 전) |
| `users`/`favorites` 테이블 존폐 | 최신 ERD(7/20)에서 두 테이블이 사라짐 → 스크랩 기능 근거 확인 필요 | ⏸️ DB 확인 필요 |
| 업종 코드 변환 주체 | `businesses`=I/R코드 ↔ `sales_stats`·`scores`=CS코드 (직접 JOIN 불가) | ⏸️ BE 확인 필요 |
| **8/18 회의의 Step 1 관련 지시 내용** | ⚠️ **기록이 남아있지 않음.** 기억으로는 "구/동 선택 → 지도 이동 → 카테고리 선택 → 해당 업종 마커만 표시"이나, 이는 Step 2와 중복이고 임시 데이터 3건뿐이라 보류 중 | ⏸️ 노션 회의록·디스코드 확인 또는 다음 정기회의에서 재확인 |
| **점수 없는 행정동 30개의 히트맵 표시 규칙** | `scores` 397개 vs FE 경계 425개 → 색칠 못 하는 동을 회색 유지 / 빗금 / 제외 중 무엇으로 할지 | ⏸️ Task 4-3 착수 전 결정 |
| **선택 동 강조 방식 (Task 4-3 재검토)** | 현재 선택 동은 주황 **채움**으로 표시. 점수 색이 면에 들어오면 그 동의 점수를 덮음 → 테두리 강조로 전환 필요 | ⏸️ 점수 색칠 착수 시 |
| ~~서울 전역(425개) 상시 렌더 여부~~ | ✅ **해소** — 2026-08-20, 요구사항이 **구 → 동 선택까지**로 확정되어 불필요. 성능상으로는 가능(추정 44ms)했으나 스코프 아웃 | ✅ |
| ~~Step 2 비교 그래프 범위~~ | ✅ **해소** — DB팀 권장안 채택: **TOP5 매출 순위**로 대체 | ✅ |
| ~~체크리스트 항목 개수~~ | ✅ **해소** — DB에 테이블 없음 → **FE 고정 문구** | ✅ |

### 📋 팀 정기회의 지시사항 (2026-07-13) — ①만 미착수

| # | 지시 내용 | 성격 | 상태 |
| --- | --- | --- | --- |
| ① | 반응형 레이아웃을 웹 사용자 중심으로 재검토 | ~~제안 수준~~ → **필수 전제조건으로 승격** | ✅ **완료** (2026-08-20) — Step 1 재설계 시 함께 처리. `LayoutBuilder` 700px 분기, `/select` maxWidth 500 → infinity |
| ② | Step 1 검색창에 행정동 기반 드롭다운 구현 | 필수 | ✅ 완료 |
| ③ | Step 1 히트맵 영역에 실제 지도 렌더링 | 제안 | ✅ 완료 (마커 포함) |
| ④ | Step 3 BottomSheet 재검토 | 필수 | ✅ 완료 (CustomOverlay 대체) |
| ⑤ | Step 4-1 부모 라우트 + 4-2·4-3·4-4 자식 재편 | 필수 | ✅ 완료 |

### 📋 팀 정기회의 지시사항 (2026-08-18) — 전부 완료

| # | 지시 내용 | 성격 | 상태 |
| --- | --- | --- | --- |
| ① | 업소 지도 하단에 드롭다운 — 행정동 선택 시 해당 마커로 이동 | 필수 | ✅ 완료 (2026-08-19) |
| ② | 기존 카카오맵 수준의 지도 UI 구현 | 필수 | ✅ 완료 (2026-08-19 컨트롤 UI + 2026-08-20 경계 폴리곤) |

---

## 📊 진행 현황

| EPIC | 내용 | 진행 | 상태 |
| --- | --- | --- | --- |
| **1** | 환경 구축 & 기반 설계 | 7 / 7 | ✅ 완료 |
| **2** | 인증 & 사용자 관리 | 1 / 5 | 🔄 진행 중 (Task 2-1 main 병합, PR #9) |
| **3** | Step 1~4 핵심 화면 개발 | 7 / 7 | ✅ 완료 (단, B1로 **재설계 가능성 있음**, B2는 8/16 해소) |
| **4** | 백엔드 API 연동 | 0 / 6 | 🔄 4-2 협의 중 |
| **5** | 품질 검증 & 배포 | 0 / 4 | ⏳ 대기 |

### 🌿 브랜치 전략 (2026-08-03~)

> 1인 프론트 독립 개발 체제 + 팀 정기회의에서 진행상황만 공유하는 구조
> **PR 승인 절차 없이 main 직접 작업 가능.**
> - 자잘한 수정·버그픽스: **main 직접 작업**
> - 화면 전체 리팩터링, 실험적 시도: **임시 브랜치 권장** (롤백 지점 확보)
> - 상세: `docs/BRANCH_STRATEGY.md`

---

## 🔌 확정된 데이터 계약 (2026-08-16 기준)

> 팀 문서 갱신분(DB 4_0 ERD / 3_3 / 3_4, ML 4_2 / 4_3 / 5_)에서 확정된 사항.
> **`models/` 필드명은 이 표를 정본으로 삼는다.**

### 업종 — CS코드 외식업 10종 (확정)

```
CS100001 한식음식점    CS100006 패스트푸드점
CS100002 중식음식점    CS100007 치킨전문점
CS100003 일식음식점    CS100008 분식전문점
CS100004 양식음식점    CS100009 호프-간이주점
CS100005 제과점        CS100010 커피-음료
```

⚠️ `businesses` 테이블은 **다른 코드 체계(I/R코드)** 를 씀 → 지도 마커와 점수를 함께 쓰려면 변환 필요

### `scores` — AI 창업 점수 (⚠️ 전면 축소됨)

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `score` | number 0~100 | 종합 창업 점수 |
| `expected_sales` | integer | 예상 월매출 — **가게 1곳당 평균 근사치** |
| `closure_risk` | number 0~100 | 폐업 위험도 (높을수록 위험) |

- 조회 단위: **행정동(`district_code`) × 업종(`category_code`)** — 건물 단위 아님
- `period_code`는 2026-08-12 제거 확정
- **삭제된 것**: `total_score`, `population_score`, `sales_score`, `age_target_score`, `competitor_score`, `ml_sales_score`, `transport_score`, `rent_score`, `model_version`, `score_reason`

**화면 표시 규칙 (ML 요청사항)**
- `closure_risk` → 절대 수치 대신 **"낮음/보통/높음" 등급**으로 노출
- `expected_sales` → **"가게 1곳당 평균 추정치"** 문구 병기 필수
- 전반 → **"참고용 지표"** 안내 (매출 R²≈0.37, 폐업 분류 정확도≈0.43)
- 예외 처리: `expected_sales` **0원 데이터 1,454건 존재**, 최대값 612억(비현실적) → 표시 가드 필요
- 데이터 커버리지: **행정동 397개만 존재**(전체 427개 중 30개 누락) → 빈 결과 화면 필요
- ⚠️ **2026-08-20 CSV 실측 — 위 "30개 누락"은 실제보다 낙관적이다.** 커버리지가 업종마다 달라
  외식업 10종 기준 다음과 같다 (FE 보유 경계 425개 대비):

| 업종 | 커버 동 | 업종 | 커버 동 |
| --- | --- | --- | --- |
| 한식음식점 | 392 (92%) | 패스트푸드점 | 258 (61%) |
| 커피-음료 | 373 (88%) | 제과점 | 272 (64%) |
| 호프-간이주점 | 359 (84%) | 일식음식점 | 210 (49%) |
| 분식전문점 | 355 (84%) | **양식음식점** | **182 (43%)** |
| 치킨전문점 | 313 (74%) | 중식음식점 | 268 (63%) |

  → **양식음식점을 고르면 동의 절반 이상이 빈칸이다.** "점수 없는 동 30개"가 아니라
  **최대 243개** 문제이므로, 빈 결과 화면이 아니라 **히트맵의 기본 표시 규칙**으로 다뤄야 한다.
- ⚠️ **CSV가 행정동이 아니라 상권 단위다** — `commercial_area_code` 컬럼이 존재하며
  (동 × 업종) 조합 2,982개 중 **1,808개(61%)가 행을 2개 이상** 갖는다.
  조합 내 점수 편차는 **중앙값 23점 · 최대 96점.** 팀 문서의 "조회 단위: 행정동 × 업종"과
  어긋나며, 집계 기준(평균/최대/가중)이 정해지기 전에는 히트맵 색을 칠할 수 없다.

### 히트맵 — `districts.geom`

| 항목 | 상태 |
| --- | --- |
| geom 컬럼 적재 | ✅ **완료** (2026-08-17 DB팀 확인) |
| `/api/map/heatmap` 엔드포인트 | ❓ 미확인 — 컬럼 적재 ≠ API 완성, 확인 질문 필요 |
| FE 자체 경계 데이터 | ✅ **확보** (2026-08-20, `assets/geo/seoul_dong.json` 425건) — API 없이도 경계 렌더 가능 |
| 경계 렌더 성능 (실측) | ✅ **확인** (2026-08-20) — 구당 폴리곤 10~27개 / 좌표 109~241개 / **렌더 1~3ms**. 비용은 폴리곤 개수가 아니라 **좌표 개수**에 비례(약 100좌표당 1ms). GeoJSON 파싱은 파일당 1회 후 캐시 |
| 렌더 단위 | **축척에 따라 두 단계** — 초기 화면 = 자치구 25개 / 구 선택 후 = 그 구의 행정동. 통계 지도의 표준 방식이며, 점수 색칠 때도 같은 원칙을 잇는다 |
| 서울 전역 425개 상시 렌더 | ❌ **폐기** (2026-08-20) — 생성은 19~21ms로 빨랐으나 **드래그·줌이 무거워졌다.** 폴리곤은 만들고 끝이 아니라 매 프레임 다시 그려지므로, 생성 비용이 싸다고 유지 비용까지 싼 게 아니다. → 자치구 25개(1,022좌표)로 교체, 렌더 4~5ms |

### `government_supports` — 정부 지원사업 (필드명 확정, 필터 불가)

| FE 필드 | DB 컬럼 | 비고 |
| --- | --- | --- |
| 사업명 | `title` | ⚠️ `pblanc_nm` 아님 |
| 공고 ID | `pblanc_id` | UNIQUE |
| 기관 | `agency` / `jrsd_instt_nm` | ⚠️ 두 컬럼의 의미(실행/주관/관할)가 문서마다 달라 **라벨 확정 필요** |
| 요약 | `summary` | HTML 제거 후 저장 |
| 신청기간 | `sprt_start_date` / `end_date` | 마감 필터는 BE 처리 |
| 링크 | `support_url` | |

- **업종·지역 필터 불가** (테이블에 해당 컬럼 없음) → 전체 표시
- 적재량 1,417건 · 매주 월요일 갱신

### 기타 확정 사항

| 항목 | 내용 |
| --- | --- |
| 행정동 | `districts` 427건 · 자치구 25개 — **목록 API 제공 가능** (Task 4-3에서 하드코딩 제거 예정)<br>⚠️ FE 보유 경계 데이터는 **425건** — 행정동 개편 시점 차이로 추정, 회의 확인 필요 (DEVLOG 미해결 9번) |
| 업소 마커 | `businesses` 537,488건 — `biz_name`/`category_name`/`lat`/`lng`/`open_status` 조회 검증 완료 |
| 임대료 | `rent_stats` — **자치구 단위**만 가능 (행정동 아님) → 화면 문구 명시 |
| 상권변화 | `market_trends.trend_grade`(HH/HL/LH/LL) + `trend_grade_nm` **BE가 문구까지 제공** |
| 체크리스트 | DB 테이블 없음 → **FE 고정 문구** |
| AR 기능 | Flutter **App 전용**, Web은 비활성화 → FE(Web) 담당 범위 아님 |

---

## 💻 개발 환경

> ⚠️ **작업 환경은 2대** — 집 데스크탑 / 학교 PC. (※ 노트북은 없음 — v4.3까지의 "노트북" 표기는 오기)
> **2026-08-16 발견** — 두 환경의 Flutter SDK 버전 차이로 빌드 실패 발생.
> 집 PC(3.41.6, 5개월 전)가 학교 PC(3.44.6)보다 구버전이었고, `CupertinoPageTransitionsBuilder`가
> **material.dart의 암묵적 export에 의존**하고 있던 게 신버전에서 걸러짐 (커밋: `fix: main.dart Flutter SDK 버전 호환성 수정`).
> "여기서 되니까 맞다"고 가정하면 안 됨 — **구버전이 더 관대해서 우연히 통과했을 뿐일 수 있음.**
> 여러 환경에서 작업할 경우 **작업 시작 전 `flutter --version` 확인** 습관화 필요.

| 환경 | Flutter | Dart | `core.autocrlf` | 확인일 |
| --- | --- | --- | --- | --- |
| **집 데스크탑** | **3.47.1** (`C:\src\flutter`) | 3.13.1 | ✅ true | 2026-08-20 |
| **학교 PC** | 3.44.6 (2026-07-08 릴리즈) | 3.12.2 | ❌ 미설정 | 2026-08-16 |

> ✅ **집 PC는 2026-08-20 업그레이드 완료** — `flutter doctor` · `flutter analyze` 이슈 0.
> ⚠️ **학교 PC가 이제 구버전.** 다음 등교 시 동일 절차 필요 (아래 권장 조치 참고).
> ⚠️ `lib/main.dart`의 `import 'package:flutter/cupertino.dart';`는 **삭제 금지** —
> 구버전에선 불필요 경고가 뜨지만 신버전에선 필수다.

**권장 조치**
- [x] ~~집 PC 버전 통일~~ — ✅ 2026-08-20 완료 (3.41.6 → 3.47.1)
- [ ] **학교 PC 업그레이드** — 아래 절차. 상세 경위는 DEVLOG 2026-08-20 참조
  1. SDK 폴더를 **`C:\src\flutter`처럼 짧은 경로로 먼저 이동** (윈도우 260자 경로 제한 회피)
  2. `flutter upgrade --force` (붙여쓸 것 — `-- force`로 띄우면 `--`가 옵션 종료 신호가 되어 실패)
  3. 실패 시 `adb.exe` 등이 SDK 파일을 잡고 있는지 `resmon` → CPU → **연결된 핸들**로 확인
- [ ] **학교 PC `git config core.autocrlf true`** — 미설정 시 줄바꿈만 다른 파일 전체가 변경으로 잡힘
- [ ] 두 환경이 같아진 뒤 `pubspec.yaml`에 `environment.flutter: ">=3.47.0"` 명시 (구버전 빌드 조기 차단)
- [ ] 가능하면 `fvm`(Flutter Version Management) 도입 검토 — 프로젝트별 SDK 버전 고정

> ⚠️ **v4.3까지 기재돼 있던 "SDK가 압축 배포판이라 git 기반 upgrade 불가"는 사실과 다름.**
> 실제 원인은 ① SDK 폴더의 로컬 변경(→ `--force`로 통과) ② **윈도우 260자 경로 제한**
> (SDK가 `Documents\flutter_windows_3.41.6-stable\` 아래 깊이 설치돼 있어 git checkout이
> `Filename too long`으로 실패)이었다. 폴더를 짧은 경로로 옮기니 정상 업그레이드됨.

## 📦 패키지

| 패키지 | 버전 | 추가 시점 | 용도 |
| --- | --- | --- | --- |
| flutter_riverpod | ^2.5.1 | Task 1-3 | 상태관리 |
| riverpod_annotation | ^2.3.5 | Task 1-3 | Riverpod 코드 생성 지원 |
| go_router | ^14.2.0 | Task 1-4 | 라우팅 |
| flutter_web_plugins | sdk: flutter | Task 1-4 | URL 전략 (`usePathUrlStrategy`) |
| fl_chart | ^0.68.0 | Task 3-2 | Step 2 비교 차트 |
| intl | ^0.20.3 | Task 3-4 | 숫자 포맷 |
| web | ^1.1.1 | Task 3-3 | `dart:html` 대체 |
| firebase_core | ^3.3.0 | Task 2-1 | Firebase 초기화 |
| firebase_auth | ^5.1.0 | Task 2-1 | Custom Token 로그인 기반 |
| cloud_firestore | ^5.2.0 | Task 2-1 | 스크랩/리포트 저장 (예정) |
| url_launcher | ^6.3.1 | Task 3-6 | 정책 상세 외부 링크 열기 |
| cupertino_icons | ^1.0.8 | Task 1-1 | flutter create 기본 포함 |

**dev_dependencies**

| 패키지 | 버전 | 용도 |
| --- | --- | --- |
| flutter_lints | ^6.0.0 | 린트 규칙 |
| riverpod_generator | ^2.4.0 | ⚠️ **미사용** — `.g.dart` 생성 파일 0개 |
| build_runner | ^2.4.8 | ⚠️ **미사용** — 동상 |

> ⚠️ `riverpod_annotation` 계열은 설치만 되어 있고 실제로는 전통 방식(`Provider`/`StateNotifierProvider`)으로 구현 중.
> 계속 이 방식으로 갈 경우 세 패키지 제거 검토 필요.
> ⚠️ `collection`은 **transitive dependency**이므로 직접 사용 금지 (`firstOrNull` 대신 헬퍼 함수)

---

## 📂 Assets

| 경로 | 크기 | 추가 시점 | 내용 |
| --- | --- | --- | --- |
| `assets/geo/seoul_dong.json` | 146KB | 2026-08-20 | 서울 425개 행정동 경계(GeoJSON). 행정안전부 고시 기준, mapshaper 10% 간소화. 좌표 4,396개 |
| `assets/geo/seoul_gu.json` | 24KB | 2026-08-20 | 서울 25개 자치구 경계. **위 파일을 구별로 병합(dissolve)해 생성** — 별도 출처 없음. 좌표 1,022개, 전부 단일 폴리곤·구멍 없음 |

> 💡 구 경계를 새로 구하지 않고 만들 수 있었던 건, 동 경계를 간소화할 때 **topology를 보존**해
> 인접한 동이 공유하는 선이 똑같이 깎였기 때문이다. 그래서 합쳤을 때 틈(sliver)이 생기지 않았다.

> `pubspec.yaml`에 `assets: - assets/geo/` 등록됨.
> ⚠️ **assets 추가·변경은 hot reload로 반영되지 않음** — 앱 완전 재시작 필요.

---

## 📁 폴더 구조

> ✅ **2026-08-16 Phase 1~4 재구조화 완료** · **2026-08-20 `data/` 레이어 신설** (총 42개 파일)
> 경로·파일명에서 Step 번호 제거 — 순서가 또 바뀌어도 파일은 안 건드리도록.
> `(예정)` 표시는 아직 생성되지 않은 파일입니다.

```
lib/
├── main.dart                     # ProviderScope + GoRouter + 카카오맵 콘센트 등록
├── firebase_options.dart         # FlutterFire CLI 자동 생성
├── data/                         # 1개 ⭐ 2026-08-20 신설
│   └── seoul_districts.dart      # 서울 425개 행정동 (스크립트 생성 · 수동 편집 금지)
├── app/
│   ├── router.dart               # go_router 전체 라우트 (StatefulShellRoute 포함)
│   └── theme.dart                # SurbiColors · TextStyle · ButtonStyle
├── models/                       # 7개
│   ├── region.dart               # 지역 / 행정동 (구·동 드롭다운)
│   ├── area_analysis.dart        # 상권 분석 결과 + CategorySales (Phase 4 신규)
│   ├── business.dart             # 업소 정보 (Phase 3 — building.dart 대체)
│   ├── score_result.dart         # ⚠️ B1 — scores 축소로 재설계 대상
│   ├── report.dart               # LLM 보고서 (7필드)
│   ├── government_policy.dart    # 정부 지원사업 (DB 스키마 기준 필드명)
│   └── checklist_item.dart       # 창업 체크리스트 항목
├── services/                     # 2개
│   ├── kakao_map_interop.dart         # dart:js_interop 통역 레이어
│   ├── kakao_map_view_registry.dart   # HtmlElementView 등록 + 마커/오버레이/경계 폴리곤
│   ├── (예정) auth_service.dart       # Task 2-2
│   └── (예정) api_service.dart        # Task 2-4
├── providers/                    # 6개
│   ├── auth_provider.dart · region_provider.dart
│   ├── area_provider.dart        # areaAnalysisProvider (Phase 4)
│   ├── business_provider.dart    # businessesProvider (Phase 3)
│   ├── score_provider.dart
│   └── checklist_provider.dart   # StateNotifierProvider + 파생 진행률
├── views/                        # 5개
│   ├── region_select_page.dart   # ① [구▾][동▾][업종▾] + 전체 화면 지도 (발견 화면)
│   ├── map_page.dart             # ② 업소 지도 + CustomOverlay 카드
│   ├── analysis_page.dart        # ③ 상권 분석 (매출 TOP5 + 지표 4종)
│   ├── policy_list_page.dart · checklist_page.dart
│   ├── (예정) landing_page.dart       # 현재 router.dart의 PlaceholderPage 사용
│   ├── (예정) login_page.dart         # Task 2-2
│   └── (예정) auth_callback_page.dart # Task 2-2
└── widgets/                      # 17개
    ├── common/                   # 7개
    │   ├── responsive_layout.dart     # maxWidth 파라미터화, 화면별 개별 적용
    │   ├── surbi_app_bar.dart · surbi_card.dart
    │   ├── surbi_dropdown.dart        # OverlayEntry + LayerLink 커스텀 드롭다운
    │   │                              #   openUpward · onMenuVisibilityChanged 옵션
    │   └── surbi_loading.dart · surbi_error.dart · surbi_empty.dart
    └── step4/                    # 10개 ⚠️ 폴더명은 아직 step4 유지
        ├── score_shell.dart           # ④ 허브 — LayoutBuilder 900px 분기 + 탭바
        ├── score_hub_panel.dart       # 게이지 + 예상성과 + SHAP 카드 묶음
        ├── score_gauge.dart           # CustomPainter 원형 게이지
        ├── shap_bar_chart.dart        # ⚠️ B1 — 데이터 근거 소멸
        ├── report_loading.dart · report_viewer.dart · report_page.dart
        ├── policy_card.dart
        └── checklist_item_card.dart · checklist_progress_bar.dart

※ widgets/step2/ 폴더 없음
※ widgets/step4/ 폴더명만 Step 번호가 남아있음 — 파일명 정리 시 함께 검토 대상
※ lib/data/ 는 스크립트가 생성한 데이터 전용 — 로직을 두지 않음
```

### 🗺️ 라우트 맵

| 팀 호칭 | URL | 화면 파일 |
| --- | --- | --- |
| — | `/` · `/login` | (PlaceholderPage) |
| Step 1 | `/select` | `region_select_page.dart` |
| Step 2 | `/map/:districtCode/:categoryCode` | `map_page.dart` |
| Step 3 | `/analysis/:districtCode/:categoryCode` | `analysis_page.dart` |
| Step 4 | `/score/:districtCode/:categoryCode` | `score_shell.dart` |
| └ 보고서 | `/score/.../report` | `report_page.dart` |
| └ 정부지원 | `/score/.../policies` | `policy_list_page.dart` |
| └ 체크리스트 | `/score/.../checklist` | `checklist_page.dart` |

> ⚠️ `:buildingId` 폐기됨 — 점수 단위가 건물 → 행정동+업종으로 확정(8/3 대조표 안건 1)

---

## ✅ EPIC 1 · 환경 구축 & 기반 설계

> 💡 **목표** — 개발을 본격적으로 시작하기 위한 기반 다지기

| Task | 내용 | 결과물 |
| --- | --- | --- |
| ✅ 1-1 | Flutter Web 프로젝트 생성 · 폴더 구조 세팅 | `surbi_web` — 레이어드 아키텍처 |
| ✅ 1-2 | 반응형 레이아웃 기본 틀 | `responsive_layout.dart` — `maxWidth` 파라미터화, 화면별 개별 적용 |
| ✅ 1-3 | 상태관리 — **Riverpod 확정** | `ProviderScope` 적용 |
| ✅ 1-4 | go_router 네비게이션 구조 | `app/router.dart` · `usePathUrlStrategy()` |
| ✅ 1-5 | 공통 위젯 3종 | `surbi_loading` · `surbi_error` · `surbi_empty` |
| ✅ 1-6 | GitHub 브랜치 전략 확정 | **[docs/BRANCH_STRATEGY.md]** |
| ✅ 1-7 | Figma 전체 화면 와이어프레임 | Notion 자료실 공유 완료 |

<details>
<summary><b>📎 설계 근거 (펼치기)</b></summary>

**Task 1-3 — Provider 대신 Riverpod을 선택한 이유**
- `Provider`는 `BuildContext`에 묶여 있어 Web 라우팅 변경 시 상태 소실 위험
- `Riverpod`은 Context 없이 어디서든 접근 가능 → Flutter Web에 최적
- `AsyncNotifier`로 로딩 / 에러 / 데이터 상태를 한 번에 관리 가능

**모든 화면에서 쓰는 표준 패턴**
```dart
final state = ref.watch(areaNotifierProvider);
state.when(
  loading: () => const SurbiLoading(message: '상권 데이터 불러오는 중...'),
  error:   (e, _) => SurbiError(message: e.toString(), onRetry: () => ref.refresh(areaNotifierProvider)),
  data:    (areas) => AreaListView(areas: areas),
);
```

**Task 1-4 — `Navigator.push`를 쓰면 안 되는 이유**
Flutter Web에서 URL이 바뀌지 않아 뒤로가기·북마크·공유 링크가 전부 작동하지 않음 → `go_router` 도입.
초기 구현 코드는 **[FE_완료코드_아카이브_Task1-4_go_router.md]** 참고. 최신 라우트는 GitHub `app/router.dart`.

</details>

---

## 🔄 EPIC 2 · 인증 & 사용자 관리

> 🔑 **인증 구조** — 카카오/네이버 OAuth → 백엔드가 Firebase Custom Token 발급 → FE는 `signInWithCustomToken()`으로 소비.

### ✅ Task 2-1 · Firebase 프로젝트 생성 및 Flutter Web 연동

- [x] Firebase Console 프로젝트 생성 (`surbi-web`, Spark 무료 플랜)
- [x] `flutterfire configure` → `firebase_options.dart` 자동 생성
- [x] `pubspec.yaml`에 `firebase_core` / `firebase_auth` / `cloud_firestore` 추가
- [x] main 병합 완료 (PR #9, 2026-08-03)

---

### ⏳ Task 2-2 · 카카오 · 네이버 소셜 로그인 구현

> ⚠️ **백엔드 의존** — `POST /auth/kakao`, `POST /auth/naver` 완성 필요. **UI만 먼저 구현**, 연동은 Task 4-7.
> 📎 상세 설계·전체 코드: **[FE_구현설계_참고_Task2-2_카카오네이버로그인.md]**

- [ ] 카카오 Developers 앱 등록 및 Redirect URI 설정
- [ ] 네이버 Developers 앱 등록 및 Callback URL 설정
- [x] `url_launcher` 패키지 추가 — ✅ Task 3-6에서 이미 설치됨 (`^6.3.1`)
- [ ] `services/auth_service.dart` 작성
- [ ] `views/auth_callback_page.dart` 작성
- [ ] Firebase Console Custom 제공업체 활성화

---

### ⏳ Task 2-3 · 로그인 상태 기반 라우팅 처리

> ❓ **선결 과제** — Step 4 로그인 필수 여부(A/B안) 결정 필요

- [ ] `providers/auth_provider.dart` — `authState` Provider 구현
- [ ] `router.dart`에 `ref.watch(authStateProvider)` + `redirect` 로직 추가
- [ ] `/auth/kakao/callback`, `/auth/naver/callback` 경로 추가
- [ ] OAuth 콜백 경로(`/auth/*`)는 redirect에서 제외 처리

---

### ⏳ Task 2-4 · FastAPI 요청 시 Firebase ID 토큰 자동 첨부

> ⚠️ `flutter_secure_storage`는 Web에서 `localStorage`를 써서 XSS에 취약.
> **Firebase가 토큰을 관리하게 두고, 매 요청마다 `getIdToken()`으로 최신 토큰을 가져올 것.**

- [ ] `services/api_service.dart` 작성
- [ ] `GET`, `POST` 메서드 구현 및 토큰 첨부 테스트
- [ ] 401 응답 시 자동 로그아웃 처리 확인

---

### ⏳ Task 2-5 · Firestore — 관심 상권 스크랩 / AI 리포트 내역 저장

> ⚠️ **재검토 필요** — 최신 ERD(2026-07-20)에 `users`·`favorites` 테이블이 **존재하지 않음.**
> 기존 전제("PostgreSQL `favorites`와 Firestore가 다른 목적으로 공존")가 성립하는지 DB 확인 필요.
> 성립하지 않으면 **스크랩·체크리스트를 Firestore 단독 관리**로 방향 전환.

- [ ] `users`/`favorites` 테이블 존폐 DB 확인 ← **선행**
- [ ] Firestore 컬렉션 구조 설계 및 생성
- [ ] Security Rules 적용
- [ ] 스크랩 저장 / 불러오기 → `policy_card.dart` 스텁 버튼 연결
- [ ] 체크리스트 완료 항목 저장 → `checklist_page.dart` 안내 배너 제거
- [ ] 리포트 내역 저장 / 불러오기

<details>
<summary><b>📎 참고 구조 · Security Rules (펼치기)</b></summary>

```
users/{uid}/
  ├── scraps/{scrapId}    → 관심 상권 스크랩
  └── reports/{reportId}  → AI 분석 리포트 내역
```

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == uid;
    }
  }
}
```

</details>

---

## ✅ EPIC 3 · Step 1~4 핵심 화면 개발

> ⚙️ **개발 방식** — **B안 원칙**: View에 데이터 하드코딩 금지, 각 Provider가 임시 데이터를 반환

| Task | 화면 | 상태 |
| --- | --- | --- |
| ✅ 3-1 | [Step 1] 지역 · 카테고리 선택 | 완료 |
| ✅ 3-2 | [Step 2] 상권 분석 대시보드 | 완료 |
| ✅ 3-3 | [Step 3] 건물 탐색 — 지도 모드 | 완료 (⚠️ B2로 재정의 가능성) |
| ✅ 3-4 | [Step 4] AI 점수 게이지 + SHAP | 완료 (⚠️ B1로 재설계 가능성) |
| ✅ 3-5 | [Step 4] LLM 보고서 출력 ⭐ 핵심 | 완료 (⚠️ B4로 입력값 미정) |
| ✅ 3-6 | [Step 4] 정부 지원사업 카드 리스트 | 완료 |
| ✅ 3-7 | [Step 4] 창업 행동 유도 체크리스트 | 완료 |

### ✅ 완료 — Step 4 `StatefulShellRoute` 리팩터링

> 점수 게이지를 **허브**로 두고 보고서/정부지원/체크리스트를 **순서 무관 형제 자식**으로 재구조화.
> 좌측 게이지 고정 + 우측 스왑 2컬럼(~900px), 모바일은 단일 컬럼. Phase 0~5 전부 완료 (PR #7·#8 병합).

### ⏳ 각 Step 잔여 항목

| Step | 미완 항목 | 상태 / 연결 Task |
| --- | --- | --- |
| 1 | ~~카테고리 버튼 CS코드 교체~~ | ✅ 완료 (Phase 1.5) |
| 1 | 구/동 목록 하드코딩 제거 → 행정동 목록 API | Task 4-3 — 8/20에 목록 자체는 **팀 DB 기준 실데이터 425건으로 교체**(하드코딩 형태는 유지) |
| 1 | 히트맵 실데이터 (점수 기반 색칠) | 🔄 ①레이아웃 ②경계 렌더 완료(8/20). ③은 `fillColor`를 점수 기반으로 교체 → **점수 집계 기준 회신이 선행**("다음 할 일" 3번) |
| 1 | ~~구 전체 동 경계 렌더 (히트맵 밑그림)~~ | ✅ 완료 (2026-08-20) — `drawGuBoundaries()` · `showGuOnStep1()` |
| 1 | ~~카테고리 칩 10개 → 드롭다운 전환 + 반응형 재설계~~ | ✅ 완료 (2026-08-20) — `[구▾][동▾][업종▾]` + 지도 `Expanded` |
| 1 | ~~초기 화면이 맨 지도라 화면 목적이 안 드러남~~ | ✅ 완료 (2026-08-20) — 자치구 25개 경계 표시 |
| 1 | 업종 선택이 지도에 반응하지 않음 | ⏳ 의도된 상태 — Step 1에서 업종의 역할은 **마커 필터가 아니라 히트맵 색 전환**이므로 ③점수 색칠과 함께 연결됨. 업종별 업소 마커는 Step 2의 일이라 중복하지 않음 |
| 2(지도) | ~~건물 → 업소 재정의~~ | ✅ 완료 (Phase 3) |
| 2(지도) | 마커 클러스터링 | Task 4-5 — 실데이터 464개 붙은 후 |
| 2(지도) | 오버레이 카드 거리 표시 | Task 4-5 |
| 2(지도) | ~~행정동 경계 폴리곤 표시~~ | ✅ 완료 (2026-08-20) — 선택 동 1개 렌더 + setBounds 자동 맞춤 |
| 3(분석) | ~~비교 차트 → TOP5 매출 순위~~ | ✅ 완료 (Phase 4) |
| 3(분석) | ~~지표 표기 정정(경쟁도·유동인구·임대료·분기)~~ | ✅ 완료 (Phase 4) |
| 3(분석) | 소비 패턴(시간대/성별/연령) 차트 | Task 4-4 |
| 4 | 세부 점수·SHAP 패널 존폐 | ⏸️ **B1 블로커** |
| 4 | ~~체크리스트 고정 문구 확정~~ | ✅ 완료 (2026-08-18) — 카테고리 색상 구분 포함 |
| 4 | ~~정책 카드 category 필드 제거~~ | ✅ 완료 (2026-08-18) |
| 4 | 체크리스트 카테고리 색상 구분 UX 검증 | ✅ 완료 (위와 동일 작업으로 함께 처리됨) |
| 4 | PDF 다운로드 버튼 | 추후 (Phase 3 항목) |
| 4 | 보고서·체크리스트 Firestore 저장 | Task 2-5 |

---

## 🔵 EPIC 4 · 백엔드 API 연동

> 💡 **목표** — EPIC 3에서 임시 데이터로 만들어둔 화면에 실제 백엔드 데이터 연결
> 🌿 **브랜치** — `feature/frontend-api-integration`

### ❌ Task 4-1 · Mock 데이터 구조 정의 — **폐기**

> 2026-06-29 회의에서 "Mock 데이터 사용 안 함" 확정. `models/`는 유지, `mock_data.dart`는 삭제 완료.

---

### 🔄 Task 4-2 · 백엔드 API 명세 확정 (With. BE)

> 📎 **명세 전문**: **[docs/API_명세_협의_요청사항.md](API_명세_협의_요청사항.md)** — **v2.1**
> **현황**: P1-6(geom)은 적재 완료 확인(8/17), 엔드포인트 완성 여부 재확인 대기.
> **P1 7건 중 6건 남음 · P2 11건** (ML 6 / BE 10 / DB 5)

- [x] ~~Step 순서 정본 확정~~ → 8/3 회의 확정, FE 반영 완료
- [x] ~~Step 3 데이터 근거 재정의~~ → 행정동+업종 단위 확정, FE 반영 완료
- [ ] **P1-1** 세분화 점수 5종 `scores` 확장 가능 여부 (ML)
- [ ] **P1-2** LLM 보고서 입력값 (ML·BE)
- [ ] **P1-4** 업종 코드 변환 주체 (BE)
- [ ] **P1-5** 인증 엔드포인트 일정 (BE)
- [ ] 합의된 명세 기반으로 `models/` 코드 확정

**엔드포인트 목록 (DB팀 3_4 제안 기준으로 전면 교체)**

| 메서드 / 경로 | 인증 | 프론트 사용처 | 상태 |
| --- | --- | --- | --- |
| `GET /api/categories` | ❌ | 업종 드롭다운 (CS코드 10종) | 🆕 신규 |
| `GET /api/districts?gu={구명}` | ❌ | Step 1 구/동 드롭다운 | 🆕 신규 (제공 가능 확인) |
| `GET /api/map/heatmap?category_code=` | ❌ | Step 1 히트맵 (GeoJSON + score) | 🔄 geom 적재 완료(8/17), 엔드포인트 완성 여부 확인 필요 |
| `GET /api/analysis?district_name=&category_code=` | ❓ | Step 2 대시보드 (5종 통합 응답) | 🆕 BFF형 |
| `GET /api/scores?district_name=&category_code=` | ❓ | Step 4 점수 3종 | 🔄 파라미터 변경 |
| `GET /api/supports?period=current` | ❌ | Step 4 정부지원 (필터 없음) | 🔄 필터 제거 |
| `POST /reports/generate` · `GET /reports/{id}` | ❓ | Step 4 보고서 (생성/폴링) | ⏸️ 입력값 미정 |
| `POST /auth/kakao` · `POST /auth/naver` | ❌ | 로그인 콜백 | ⏸️ 일정 미정 |
| `GET /api/businesses?district_name=&category_code=` | ❌ | ② 업소 지도 마커 | 🆕 신규 (buildings 폐기 대체) |
| ~~`POST /favorites`~~ | — | ~~스크랩~~ | ❌ **테이블 부재로 재검토** |

---

### ⏳ Task 4-3 ~ 4-6 · Step별 API 연동

| Task | 대상 | 핵심 작업 |
| --- | --- | --- |
| 4-3 | Step 1 | 업종 목록 · 행정동 목록 · 히트맵 연동 · 로딩/에러/빈 결과 |
| 4-4 | Step 2 | `GET /api/analysis` 바인딩 (경쟁업소·유동인구·매출·상권변화·임대료) |
| 4-5 | Step 3 | ⏸️ B2 해소 후 착수 — 업소 마커 바인딩 |
| 4-6 | Step 4 | 점수 3종 바인딩 + 보고서 폴링(3초 × 20회) |

<details>
<summary><b>📎 Task 4-6 폴링 패턴 (펼치기)</b></summary>

```dart
Future<String> pollReport(String reportId) async {
  for (int i = 0; i < 20; i++) {       // 최대 60초 (3초 × 20회)
    await Future.delayed(const Duration(seconds: 3));
    final res = await apiService.get('/reports/$reportId');
    final data = jsonDecode(res.body);
    if (data['status'] == 'completed') return data['content'];
  }
  throw Exception('보고서 생성 시간 초과');
}
```

</details>

---

### ⏳ Task 4-7 · 카카오 · 네이버 로그인 백엔드 연동

- [ ] Custom Token 수신 → Firebase 로그인 완료 구현
- [ ] `AuthCallbackPage`에 실제 로직 연결
- [ ] 성공 시 `/select` 이동 / 실패 시 에러 안내 후 `/login` 복귀

---

## 🔵 EPIC 5 · 품질 검증 & 배포

### ⏳ Task 5-1 · CanvasKit 초기 로딩 스플래시

> ⚠️ Flutter Web(CanvasKit)은 첫 방문 시 **5~8MB Wasm 다운로드** → 흰 화면 이탈 위험

- [ ] `icons/surbi_logo.png` 준비 (192×192px)
- [ ] `web/index.html` 로딩 오버레이 추가
- [ ] 실제 기기에서 로딩 → 앱 전환 확인

<details>
<summary><b>📎 참고 코드 (펼치기)</b></summary>

```html
<style>
  .loading-overlay {
    position: fixed; inset: 0;
    background: #1E3A5F;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    z-index: 9999;
    transition: opacity 0.5s ease;
  }
  .loading-overlay.hidden { opacity: 0; pointer-events: none; }
</style>

<div class="loading-overlay" id="loading">
  <img src="icons/surbi_logo.png" width="80" alt="Surbi 로고" />
  <p style="color:white; margin-top:24px; font-family:sans-serif;">잠시만 기다려주세요...</p>
</div>

<script>
  window.addEventListener('flutter-first-frame', () => {
    document.getElementById('loading').classList.add('hidden');
  });
</script>
```

</details>

---

### ⏳ Task 5-2 · 전체 화면 에러 케이스 점검

- [ ] 네트워크 연결 없음 → 에러 화면 표시
- [ ] API 500 → `SurbiError` + 재시도 버튼
- [ ] 검색 결과 없음 → `SurbiEmpty`
- [ ] **점수 데이터 없는 행정동 30개** → `SurbiEmpty` 안내
- [ ] **`expected_sales` 0원 / 비정상 대형값** → 표시 가드
- [ ] 로그인 만료 → 자동 로그아웃 후 로그인 화면 이동
- [ ] LLM 보고서 타임아웃(60초) → 에러 안내

---

### ⏳ Task 5-3 · Flutter Web 빌드 최적화

- [ ] 릴리즈 빌드 성공 확인 — `flutter build web --release`
- [ ] 빌드 결과물 용량 확인 (**목표: 15MB 이하**)
- [ ] 로컬 미리보기(`python3 -m http.server 8080`)로 최종 점검

---

### ⏳ Task 5-4 · Firebase Hosting 배포 및 URL 공유

- [ ] Firebase Hosting 연결 (`firebase init hosting` → Public: `build/web`, SPA: Yes)
- [ ] `firebase.json` 설정 확인
- [ ] 배포 (`firebase deploy --only hosting`) 후 URL 확인
- [ ] **배포 URL 팀 Notion 자료실에 공유**
- [ ] 모바일 기기 실제 접속 및 전체 플로우 테스트

---

## 🔗 링크

**GitHub** — https://github.com/sagming40/surbi_web

**실행 명령어** — `flutter run -d chrome --web-port=5000` (카카오맵 도메인 등록 때문에 포트 고정 필수)

**Figma 와이어프레임** — https://www.figma.com/design/EN5re8TzbBLQcQLznIOjmJ/Surbi---Figma-와이어프레임?node-id=0-1&t=mvClrMC6i4bGmxKV-1

**저장소 문서 (`docs/`)**
- [FE_DEVLOG.md](FE_DEVLOG.md) — 개발 일지 (과거 기록 · 트러블슈팅 · 상시 규칙)
- [API_명세_협의_요청사항.md](API_명세_협의_요청사항.md) — 백엔드 API 협의 요청 목록 (v2.1)
- [BRANCH_STRATEGY.md](BRANCH_STRATEGY.md) — 브랜치 전략
- [DESIGN.md](DESIGN.md) — 디자인 가이드

**팀 참조 문서 (Notion)**
- DB: `4.0 ERD 설계`(컬럼 정의서 최신) · `3.3 팀 확인 요청사항 정리` · `3.4 Surbi 데이터 연동 구조 정리`
- ML: `4.2 ML-DB 연동 및 결과값` · `4.3 ML-BE` · `5. ML 전체 파이프라인 요약`

---

*FRONT-END WORKFLOW v4.5 · 사공민규 · 최종 수정: 2026.08.20*
