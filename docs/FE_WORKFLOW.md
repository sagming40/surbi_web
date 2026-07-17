# 📱 FRONT-END WORKFLOW — 사공민규

| 항목 | 내용 |
| --- | --- |
| 버전 | v3.14 |
| 생성일 | 2026년 6월 18일 |
| 최종 수정 | 2026년 7월 17일 |
| 담당자 | 사공민규 |
| 기술 스택 | Flutter Web · Firebase · Riverpod · go_router · fl_chart · 카카오맵 SDK · intl |

> 📌 **이 문서의 역할 — 현재 상태 + 다음 순서**
> 시제는 **현재·미래**이며, 상태가 바뀌면 **덮어씁니다.**
> 과거에 있었던 일(오류·판단 배경·PR 이력)은 **[docs/FE_DEVLOG.md]**가 담당합니다.

> 💡 **전체 흐름** — 환경 구축 → 인증 → 화면 개발 → API 연동 → 품질 & 배포
> 🗺️ **사용자 플로우** — Step 1 지역 선택 → Step 2 상권 분석 → Step 3 건물 탐색(지도) → Step 4 AI 점수 + LLM 보고서

---

## 🔥 다음 할 일

| 순위 | 작업 | 상태 | 비고 |
| --- | --- | --- | --- |
| **1** | **Step 4 `StatefulShellRoute` 리팩터링** (Phase 0~5) | 🔄 진행 중 | 브랜치 `feature/frontend-step4-refactor` · 7/13 회의 지시 ⑤ |
| 2 | Task 4-2 · API 명세 최종 협의 (With. 최민수) | ⏸️ BE 회신 대기 | 협의 문서 v1.6 송부 완료 |
| 3 | 7/13 회의 지시 ①~④ 반영 | ⏳ 대기 | 아래 참조 |
| 4 | Task 2-2 · 카카오·네이버 로그인 UI | ⏸️ BE 의존 | `/auth/kakao`, `/auth/naver` 완성 후 실연동 |
| 5 | Task 2-5 · Firestore 연동 | ⏳ 대기 | 스크랩 버튼 · 체크리스트 스텁 실동작 연결 |

### 🚧 현재 블로커
- Step 4 리팩터링 Phase 0 착수 전 **`router.dart` 실제 파일 내용 확인 필요**

### ❓ 착수 전 결정이 필요한 사항

| 항목 | 내용 | 결정 시점 |
| --- | --- | --- |
| Step 4 접근 조건 | A: 로그인 필수 / B: 비로그인 허용 | **Task 2-3 착수 전** |
| Step 2 비교 그래프 범위 | 인근 소수 비교 vs 카테고리 전체(`districts` 427건) | Task 4-2 협의 시 |
| 체크리스트 항목 개수 | 실제 API 응답 시 평균/최대 몇 개? | Task 4-2 협의 시 |
| Step 3 BottomSheet 존치 | 별도 화면 분리 vs 다른 정보 제공 방식 | 회의 지시 ④ |

### 📋 팀 정기회의 지시사항 (2026-07-13)

| # | 지시 내용 | 성격 | 상태 |
| --- | --- | --- | --- |
| ① | 반응형 레이아웃을 **웹 사용자 중심**으로 재검토 | 제안 수준 | ⏳ |
| ② | Step 1 검색창에 **행정동 기반 드롭다운** 구현 | 필수 | ⏳ |
| ③ | Step 1 히트맵 영역에 **실제 지도** 렌더링 | 제안 | ⏳ |
| ④ | Step 3 **BottomSheet 재검토** (분리 or 대체) | 필수 | ⏳ |
| ⑤ | **Step 4-1을 부모 라우트로, 4-2·4-3·4-4를 자식으로 재편** | 필수 | 🔄 진행 중 |

---

## 📊 진행 현황

| EPIC | 내용 | 진행 | 상태 |
| --- | --- | --- | --- |
| **1** | 환경 구축 & 기반 설계 | 7 / 7 | ✅ 완료 |
| **2** | 인증 & 사용자 관리 | 1 / 5 | 🔄 진행 중 |
| **3** | Step 1~4 핵심 화면 개발 | 7 / 7 | ✅ 완료 (리팩터링 진행 중) |
| **4** | 백엔드 API 연동 | 0 / 6 | 🔄 4-2 협의 중 |
| **5** | 품질 검증 & 배포 | 0 / 4 | ⏳ 대기 |

---

## 📦 패키지

| 패키지 | 버전 | 추가 시점 | 용도 |
| --- | --- | --- | --- |
| flutter_riverpod | ^2.5.1 | Task 1-3 | 상태관리 |
| riverpod_annotation | ^2.3.5 | Task 1-3 | Riverpod 코드 생성 지원 |
| go_router | ^14.2.0 | Task 1-4 | 라우팅 |
| flutter_web_plugins | sdk: flutter | Task 1-4 | URL 전략 (`usePathUrlStrategy`) |
| fl_chart | ^0.68.0 | Task 3-2 | Step 2 유동인구 비교 차트 |
| intl | ^0.20.3 | Task 3-4 | 숫자 포맷 (천 단위 콤마) |
| web | ^1.1.1 | Task 3-3 | `dart:html` 대체 — HTMLDivElement, ResizeObserver |
| firebase_core | ^3.3.0 | Task 2-1 | Firebase 초기화 |
| firebase_auth | ^5.1.0 | Task 2-1 | Custom Token 로그인 기반 (예정, EPIC 2) |
| cloud_firestore | ^5.2.0 | Task 2-1 | 스크랩/리포트 저장 (예정, Task 2-5) |

---

## 📁 폴더 구조

> 이 섹션은 **실제 프로젝트 상태만** 반영합니다. 향후 계획은 각 Task 체크리스트에서 관리.

```
lib/
├── main.dart                     # 진입점 — ProviderScope + GoRouter + 카카오맵 콘센트 등록
├── firebase_options.dart         # FlutterFire CLI 자동 생성 (웹 플랫폼 설정)
├── app/
│   ├── router.dart               # go_router 전체 라우트 정의
│   └── theme.dart                # 공통 테마 (SurbiColors, TextStyle, ButtonStyle)
├── models/
│   ├── region.dart               # 지역 / 행정동
│   ├── commercial_area.dart      # 상권 분석 결과
│   ├── building.dart             # 건물 정보 (Step 3)
│   ├── score_result.dart         # AI 창업 점수 + SHAP
│   ├── government_policy.dart    # 정부 지원사업 (DB 스키마 기준 필드명)
│   ├── checklist_item.dart       # 창업 체크리스트 항목
│   └── user.dart                 # 유저 프로필
├── services/
│   ├── auth_service.dart              # OAuth + Custom Token (예정, EPIC 2)
│   ├── api_service.dart               # FastAPI 호출 (예정, EPIC 4)
│   ├── kakao_map_interop.dart         # dart:js_interop 기반 Dart ↔ 카카오맵 JS 통역 레이어
│   └── kakao_map_view_registry.dart   # HtmlElementView 콘센트 등록 + 마커/이벤트 로직
├── providers/
│   ├── auth_provider.dart
│   ├── region_provider.dart
│   ├── area_provider.dart
│   ├── building_provider.dart
│   ├── score_provider.dart
│   └── checklist_provider.dart   # StateNotifierProvider — toggleCheck() + 파생 진행률
├── views/
│   ├── landing_page.dart
│   ├── login_page.dart
│   ├── auth_callback_page.dart   # OAuth 콜백 (예정, EPIC 2)
│   ├── step1_region_page.dart
│   ├── step2_dashboard_page.dart
│   ├── step3_map_page.dart       # 지도/마커/BottomSheet 전부 이 파일에 구현
│   ├── step4_score_page.dart
│   ├── policy_list_page.dart
│   └── checklist_page.dart
└── widgets/
    ├── common/
    │   ├── surbi_loading.dart · surbi_error.dart · surbi_empty.dart
    │   ├── surbi_app_bar.dart    # 공용 AppBar
    │   └── surbi_card.dart       # 공용 카드 (Container+BoxDecoration — Card 대체)
    ├── step2/                    # 현재는 page 내부 private 메서드로 구현
    └── step4/
        ├── score_gauge.dart              # CustomPainter 원형 게이지
        ├── shap_bar_chart.dart           # diverging bar chart (fl_chart 미사용)
        ├── report_loading.dart           # 단계별 로딩 메시지
        ├── report_viewer.dart            # 보고서 문서형 레이아웃
        ├── report_page.dart              # 로딩/완료 전환 상태 관리
        ├── policy_card.dart
        ├── checklist_item_card.dart
        └── checklist_progress_bar.dart
```

---

## ✅ EPIC 1 · 환경 구축 & 기반 설계

> 💡 **목표** — 개발을 본격적으로 시작하기 위한 기반 다지기
> 🌿 **브랜치** — `main` 직접 작업 (초기 세팅 단계로 되돌릴 위험이 낮음)

| Task | 내용 | 결과물 |
| --- | --- | --- |
| ✅ 1-1 | Flutter Web 프로젝트 생성 · 폴더 구조 세팅 | `surbi_web` — 레이어드 아키텍처 |
| ✅ 1-2 | 반응형 레이아웃 기본 틀 | `responsive_layout.dart` — Max Width 500px + 중앙 정렬 |
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
- 2024년 Flutter 공식 Codelab에서 Riverpod 권장

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
Flutter Web에서 URL이 바뀌지 않아 뒤로가기 버튼·북마크·공유 링크가 전부 작동하지 않음 → `go_router` 도입.
계획에 없었으나 실제로 필요했던 것: `usePathUrlStrategy()`(URL `#` 제거), `ResponsiveLayout`을 `home:` → `builder:`로 이동, `flutter_web_plugins`는 `^버전` 대신 `sdk: flutter`로 작성.
→ 초기 구현 코드는 **[FE_완료코드_아카이브_Task1-4_go_router.md]** 참고. 최신 라우트는 GitHub `app/router.dart`.

**미완 항목 (EPIC 2~3에서 각 화면 개발 시 처리)**
- [ ] `flutter pub run build_runner build` 코드 생성 확인

</details>

---

## 🔄 EPIC 2 · 인증 & 사용자 관리

> 💡 **목표** — 인증 구조를 먼저 잡아야 이후 모든 화면에서 유저 정보를 쓸 수 있음
> 🌿 **브랜치** — `feature/frontend-epic2-auth`
> 🔑 **인증 구조** — 카카오/네이버 OAuth → 백엔드가 Firebase Custom Token 발급 → FE는 `signInWithCustomToken()`으로 소비. 세션 유지는 Firebase SDK가 자동 처리.

### ✅ Task 2-1 · Firebase 프로젝트 생성 및 Flutter Web 연동

- [x] Firebase Console 프로젝트 생성 (`surbi-web`, Spark 무료 플랜)
- [x] `flutterfire configure` → `firebase_options.dart` 자동 생성
- [x] `pubspec.yaml`에 `firebase_core` / `firebase_auth` / `cloud_firestore` 추가

> ℹ️ `web/index.html`에 Firebase SDK 스크립트 수동 삽입은 **불필요** — Dart 패키지(`firebase_core`) 연동 방식.

---

### ⏳ Task 2-2 · 카카오 · 네이버 소셜 로그인 구현

> ⚠️ **백엔드 의존** — 카카오·네이버는 Firebase 기본 지원이 없어 백엔드가 `POST /auth/kakao`, `POST /auth/naver`를 완성해야 실연동 가능. **UI만 먼저 구현**, 연동은 EPIC 4(Task 4-7).

> 📎 **상세 설계·전체 코드**: **[FE_구현설계_참고_Task2-2_카카오네이버로그인.md]**
> (OAuth 5단계 흐름 · 사전 준비 절차 · `auth_service.dart` / `auth_callback_page.dart` 전체 코드)

- [ ] 카카오 Developers 앱 등록 및 Redirect URI 설정
- [ ] 네이버 Developers 앱 등록 및 Callback URL 설정
- [ ] `url_launcher` 패키지 추가
- [ ] `services/auth_service.dart` 작성
- [ ] `views/auth_callback_page.dart` 작성
- [ ] Firebase Console Custom 제공업체 활성화

---

### ⏳ Task 2-3 · 로그인 상태 기반 라우팅 처리

> 💡 **이 Task에서 `router.dart`를 최종 완성** — Task 1-4에서는 뼈대만, 여기서 `authStateProvider` 구독 + `redirect` 로직 + OAuth 콜백 경로를 추가.
> ❓ **선결 과제** — Step 4 로그인 필수 여부(A/B안) 결정 필요

- [ ] `providers/auth_provider.dart` — `authState` Provider 구현
- [ ] `router.dart`에 `ref.watch(authStateProvider)` + `redirect` 로직 추가
- [ ] `/auth/kakao/callback`, `/auth/naver/callback` 경로 추가
- [ ] OAuth 콜백 경로(`/auth/*`)는 redirect에서 제외 처리

<details>
<summary><b>📎 참고 코드 (펼치기)</b></summary>

```dart
// providers/auth_provider.dart
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
  // authStateChanges()는 로그인/로그아웃 시 자동으로 User 또는 null 반환
  // Custom Token 로그인도 동일하게 작동함
}
```

</details>

---

### ⏳ Task 2-4 · FastAPI 요청 시 Firebase ID 토큰 자동 첨부

> 💡 Custom Token으로 로그인을 완료했어도, 이후 API 요청엔 Firebase가 발급한 **ID 토큰**을 쓰면 됨 (구글 로그인과 동일).

> ⚠️ **Flutter Web 토큰 저장 주의** — `flutter_secure_storage`는 Web에서 내부적으로 `localStorage`를 써서 XSS에 취약. **Firebase가 토큰을 관리하게 두고, 매 요청마다 `getIdToken()`으로 최신 토큰을 가져올 것.**

- [ ] `services/api_service.dart` 작성
- [ ] `GET`, `POST` 메서드 구현 및 토큰 첨부 테스트
- [ ] 401 응답 시 자동 로그아웃 처리 확인

<details>
<summary><b>📎 참고 코드 (펼치기)</b></summary>

```dart
// services/api_service.dart
class ApiService {
  final _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _headers() async {
    final token = await _auth.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final res = await http.get(
      Uri.parse('${Env.apiBase}$path'),
      headers: await _headers(),
    );
    if (res.statusCode == 401) await _auth.signOut(); // 토큰 만료 처리
    return res;
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('${Env.apiBase}$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }
}
```

</details>

---

### ⏳ Task 2-5 · Firestore — 관심 상권 스크랩 / AI 리포트 내역 저장

> 💡 **PostgreSQL `favorites` 테이블과의 관계** — DB 설계에 `favorites`가 있으나(BE 관리), Firestore는 앱에서 빠르게 읽어야 하는 스크랩·리포트 목록용(FE 관리). **두 저장소가 다른 목적으로 공존.**

> 🔗 **연결 대기 중인 스텁** — `policy_card.dart` 스크랩 버튼 · `checklist_page.dart` 체크 상태

- [ ] Firestore 컬렉션 구조 설계 및 생성
- [ ] Security Rules 적용
- [ ] 스크랩 저장 / 불러오기 구현 → `policy_card.dart` 스텁 버튼 실동작 연결
- [ ] 체크리스트 완료 항목 저장 → `checklist_page.dart` 안내 배너 제거
- [ ] 리포트 내역 저장 / 불러오기 구현

<details>
<summary><b>📎 참고 구조 · Security Rules (펼치기)</b></summary>

```
// Firestore 구조
users/{uid}/
  ├── scraps/{scrapId}    → 관심 상권 스크랩
  └── reports/{reportId}  → AI 분석 리포트 내역
```

```
// Security Rules — 본인 데이터만 접근
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

> 💡 **목표** — 사용자가 실제로 보고 사용하는 화면 개발 (EPIC 1의 와이어프레임 기준)
> 🌿 **브랜치** — 화면별로 `feature/frontend-step{N}-ui` 분리 운영
> ⚙️ **개발 방식** — **B안 원칙**: View에 데이터 하드코딩 금지, 각 Provider가 임시 데이터를 반환 → API 연동 시 Provider 내부만 교체

| Task | 화면 | 상태 |
| --- | --- | --- |
| ✅ 3-1 | [Step 1] 지역 · 카테고리 선택 | 완료 |
| ✅ 3-2 | [Step 2] 상권 분석 대시보드 | 완료 |
| ✅ 3-3 | [Step 3] 건물 탐색 — 지도 모드 | 완료 |
| ✅ 3-4 | [Step 4] AI 점수 게이지 + SHAP | 완료 |
| ✅ 3-5 | [Step 4] LLM 보고서 출력 ⭐ 핵심 | 완료 |
| ✅ 3-6 | [Step 4] 정부 지원사업 카드 리스트 | 완료 |
| ✅ 3-7 | [Step 4] 창업 행동 유도 체크리스트 | 완료 |

### 🔄 진행 중 — Step 4 `StatefulShellRoute` 리팩터링

> 💡 **설계** — Step 4-1(점수 게이지)을 **허브 화면**으로 두고, 4-2(보고서) / 4-3(정부지원) / 4-4(체크리스트)를 **순서 무관 형제 자식 화면**으로 재구조화.
> 점수 게이지가 좌측 고정 + 자식 화면이 우측에서 스왑되는 **2컬럼 레이아웃**(~900px), 모바일은 단일 컬럼 전환.

| Phase | 내용 | 상태 |
| --- | --- | --- |
| 0 | 브랜치 생성 및 스냅샷 커밋 | 🔄 |
| 1 | `ResponsiveLayout` 브레이크포인트 500px → 900px 확장 | ⏳ |
| 2 | `StatefulShellRoute` 스켈레톤 + 플레이스홀더 | ⏳ |
| 3 | Shell 위젯 (점수 게이지 + 탭 버튼 3개 + 반응형 분기) | ⏳ |
| 4 | 기존 자식 화면 브랜치로 연결 | ⏳ |
| 5 | 뒤로가기 · 상태 유지 검증 + 데드코드 제거 | ⏳ |

### ⏳ 각 Step 잔여 항목

| Step | 미완 항목 | 연결 Task |
| --- | --- | --- |
| 1 | 히트맵 실데이터 연동 (현재 회색 placeholder — DB `geom` 미적재) | Task 4-3 |
| 2 | 경쟁도 · 소비 패턴 차트 (유동인구 차트로 `fl_chart` 방식은 검증 완료) | Task 4-2 확정 후 판단 |
| 3 | BottomSheet 거리 표시 (사용자 위치 기반 계산) | Task 4-5 |
| 4 | PDF 다운로드 버튼 | 추후 (공유 링크로 대체 가능) |
| 4 | 보고서 Firestore 저장 (현재 버튼 자체 없음) | Task 2-5 |
| 4 | 체크리스트 Firestore 저장 (현재 로컬 state만) | Task 2-5 |

<details>
<summary><b>📎 화면별 설계 메모 (펼치기)</b></summary>

**Task 3-2 · Step 2**
- `fl_chart` BarChart — 터치 시 지역명+수치 커스텀 툴팁, 70점 기준 막대 색상 동적 분기
- 카드 클릭 → Step 3 이동 (`go_router :regionCode` + `selectedAreaProvider`)
- 카드 터치 피드백: `GestureDetector` → `Material` + `InkWell` 리플

**Task 3-5 · LLM 보고서**
- 생성에 10~30초 소요 → 단순 스피너 대신 **단계별 메시지**(3초마다 교체, 마지막에서 정지)
  ```dart
  static const List<String> _messages = [
    '상권 데이터 분석 중...', 'AI 모델 추론 중...', '보고서 작성 중...', '거의 다 됐어요!',
  ];
  ```
- 섹션 구성: **상권 요약 / 리스크 요인 / 정책 추천 3개** (성격별 색상 카드)
  → 체크리스트는 Task 3-7의 독립 화면이므로 보고서에 **미포함**

**Task 3-6 · 정부 지원사업**
- 진입 경로: 보고서 하단 고정 버튼 → `/step4/:buildingId/policies` (중첩 경로)
- 모델 필드명은 **실제 DB 스키마 기준**: `pblanc_id` / `agency`+`jrsd_instt_nm` / `summary` / `sprt_start_date` / `end_date` / `support_url`
- 카드 구성: 사업명 / 지원 기관(실행+주관) / 신청 기간 / 요약 / 외부 링크

**Task 3-7 · 체크리스트**
- 진입 경로: 보고서 하단 버튼 → `/step4/:buildingId/checklist`
  → Task 3-6과 **형제 관계**(의존 없음) → 병렬(`Row`+`Expanded`) 배치
- `ChecklistNotifier`(StateNotifierProvider) `toggleCheck()` + `checklistProgressProvider`(파생)로 진행률 계산을 화면과 분리

</details>

---

## 🔵 EPIC 4 · 백엔드 API 연동

> 💡 **목표** — EPIC 3에서 임시 데이터로 만들어둔 화면에 실제 백엔드 데이터 연결
> ⚠️ **선행** — Task 4-2 API 명세 확정 (With. BE)
> 🌿 **브랜치** — `feature/frontend-api-integration`

### ❌ Task 4-1 · Mock 데이터 구조 정의 — **폐기**

> 2026-06-29 회의에서 "Mock 데이터 사용 안 함" 방침 확정 → Task 자체가 폐기됨.
> **B안 원칙**으로 각 Provider가 임시 데이터를 직접 반환하는 방식으로 대체.
> `models/` 하위 모델 파일은 유지(API 연동 시 재사용), `mock_data.dart`는 삭제 완료.

---

### 🔄 Task 4-2 · 백엔드 API 명세 확정 (With. BE)

> 📎 **명세 전문은 별도 문서** — **[docs/API_명세_협의_요청사항.md](API_명세_협의_요청사항.md)**

> **현황**: 협의 문서 재작성 완료(v1.7) → **BE 회신 대기 중**. 본체(명세 확정)는 미완.
> P1(최우선) 5건 · P2(일반) 15건 = 총 20건 요청

- [ ] 인증 엔드포인트 2개(`/auth/kakao`, `/auth/naver`) 구현 일정 최민수와 합의
- [ ] 필드명 및 응답 형식 최종 합의
- [ ] 합의된 명세 기반으로 `models/` 코드 확정

**엔드포인트 목록 (초안)**

| 메서드 / 경로 | 인증 | 프론트 사용처 |
| --- | --- | --- |
| `POST /auth/kakao` · `POST /auth/naver` | ❌ | 로그인 콜백 |
| `GET /regions?category={cat}` | ❌ | Step 1 히트맵 |
| `GET /areas?region={code}&category={cat}` | ✅ | Step 2 |
| `GET /buildings?lat={}&lng={}&r={}` | ❌ | Step 3 |
| `GET /areas/{id}/score` | ✅ | Step 4 점수+SHAP |
| `POST /reports/generate` · `GET /reports/{id}` | ✅ | Step 4 보고서 (생성/폴링) |
| `GET /policies?category={cat}&region={code}` | ❌ | Step 4 정부지원 |
| `POST /favorites` | ✅ | Step 2·3 스크랩 |

---

### ⏳ Task 4-3 ~ 4-6 · Step별 API 연동

| Task | 대상 | 핵심 작업 |
| --- | --- | --- |
| 4-3 | Step 1 | `GET /regions` → **히트맵 실데이터 연동** · 로딩/에러/빈 결과 처리 |
| 4-4 | Step 2 | `GET /areas` → 대시보드 바인딩 · 로딩/에러/빈 결과 처리 |
| 4-5 | Step 3 | `GET /buildings` → 마커 바인딩 · GPS 기반 동적 재조회 |
| 4-6 | Step 4 | `GET /areas/{id}/score` → 점수/SHAP · `POST /reports/generate` → **3초 폴링**(최대 60초) |

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

> ⚠️ 백엔드 `/auth/kakao`, `/auth/naver` 완성 후 진행

- [ ] Custom Token 수신 → Firebase 로그인 완료 구현 (카카오/네이버 각각)
- [ ] `AuthCallbackPage`에 실제 로직 연결
- [ ] 성공 시 `/step1` 자동 이동 / 실패 시 에러 안내 후 `/login` 복귀

---

## 🔵 EPIC 5 · 품질 검증 & 배포

> 💡 **목표** — 완성된 앱을 실제 사용자가 쓸 수 있도록 마무리

### ⏳ Task 5-1 · CanvasKit 초기 로딩 스플래시

> ⚠️ Flutter Web(CanvasKit)은 첫 방문 시 **5~8MB Wasm 다운로드** → 흰 화면이 뜨면 이탈 위험

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
  <p style="color:white; margin-top:24px; font-family:sans-serif;">
    잠시만 기다려주세요...
  </p>
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
- [ ] 로그인 만료 → 자동 로그아웃 후 로그인 화면 이동
- [ ] LLM 보고서 타임아웃(60초) → 에러 안내

---

### ⏳ Task 5-3 · Flutter Web 빌드 최적화

- [ ] 릴리즈 빌드 성공 확인 — `flutter build web --web-renderer canvaskit --release`
- [ ] 빌드 결과물 용량 확인 (**목표: 15MB 이하**)
- [ ] 로컬 미리보기(`python3 -m http.server 8080`)로 전체 화면 최종 점검

---

### ⏳ Task 5-4 · Firebase Hosting 배포 및 URL 공유

- [ ] Firebase Hosting 프로젝트 연결 (`firebase init hosting` → Public: `build/web`, SPA: Yes)
- [ ] `firebase.json` 설정 확인
- [ ] 배포 (`firebase deploy --only hosting`) 후 URL 확인
- [ ] **배포 URL 팀 Notion 자료실에 공유**
- [ ] 모바일 기기 실제 접속 및 전체 플로우 테스트

---

## 🔗 링크

**GitHub** — https://github.com/sagming40/surbi_web

**Figma 와이어프레임** — https://www.figma.com/design/EN5re8TzbBLQcQLznIOjmJ/Surbi---Figma-와이어프레임?node-id=0-1&t=mvClrMC6i4bGmxKV-1

**저장소 문서 (`docs/`)**
- [FE_DEVLOG.md](FE_DEVLOG.md) — 개발 일지 (과거 기록 · 트러블슈팅 · 상시 규칙)
- [API_명세_협의_요청사항.md](API_명세_협의_요청사항.md) — 백엔드 API 협의 요청 목록
- [BRANCH_STRATEGY.md](BRANCH_STRATEGY.md) — 브랜치 전략
- [DESIGN.md](DESIGN.md) — 디자인 가이드

**Notion 자료실**
- FE_구현설계_참고_Task2-2_카카오네이버로그인.md
- FE_완료코드_아카이브_Task1-4_go_router.md

---

*FRONT-END WORKFLOW v3.14 · 사공민규 · 최종 수정: 2026.07.17*
