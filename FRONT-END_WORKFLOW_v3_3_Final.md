# 📱 FRONT-END WORKFLOW — 사공민규

| 항목 | 내용 |
| --- | --- |
| 카테고리 | 기획 |
| 파일형태 | 문서 |
| 버전 | v3.3 (Task 3-1 완료 · Mock 데이터 정책 폐기 · 브랜드 컬러 최종 확정) |
| 생성일 | 2026년 6월 18일 |
| 최종 수정 | 2026년 7월 6일 |
| 담당자 | 사공민규 |
| 기술 스택 | Flutter Web · Firebase · Riverpod · go_router |

---

> 💡 **전체 흐름 한 줄 요약**
> 환경 구축 → 인증 → 화면 개발 → API 연동 → 품질 & 배포

> 🗺️ **사용자 플로우 (기획서 기준)**
> Step 1 지역 선택 → Step 2 상권 분석 → Step 3 건물 탐색 (지도 모드) → Step 4 AI 창업 점수 + LLM 보고서

---

> 📋 **버전 변경 이력**
>
> **v3.3 (2026-07-06) 변경 내용**
> - Task 3-1 [Step 1] 지역·카테고리 선택 UI 전체 구현 완료 → main 병합(PR #2)
> - Task 4-1 Mock 데이터 구조 정의 **폐기** (2026-06-29 방침 변경) → Provider 직접 관리 방식으로 대체
> - 브랜드 컬러 최종 확정: 은백색(#F8FAFA) 배경 + 네이비(#1E3A5F) 강조 → main 병합(PR #3)
> - 메모 하단에 🔧 트러블슈팅 섹션 신설
>
> **v3.2 (2026-06-28) 변경 내용**
> - Task 1-6 브랜치 전략 확정 ✅ → EPIC 1은 main 직접 작업 / EPIC 2~5는 feature 브랜치
> - 로그인 방식 확정: 구글 로그인 제거 → **카카오 · 네이버 로그인만 지원**
> - Task 2-2 전면 재작성 (카카오 · 네이버 OAuth → 백엔드 Custom Token → Firebase 로그인)
> - `views/auth_callback_page.dart` 신규 추가 (OAuth 콜백 처리 전담)
> - `app/router.dart`에 콜백 경로 2개 추가 (`/auth/kakao/callback`, `/auth/naver/callback`)
> - Task 4-2 API 명세에 인증 엔드포인트 추가 (`POST /auth/kakao`, `POST /auth/naver`)
> - EPIC 1 전체 7개 Task 완료 처리
>
> **v3.1 (2026-06-18) 변경 내용**
> - AR 모드 제거
> - AR 관련 패키지 3개 제거 (`camera`, `geolocator`, `flutter_compass`)
> - Step 3을 지도 모드 단일 구조로 단순화
> - Task 3-4 (AR 모드) 삭제 → Task 번호 재정렬
> - LLM 보고서 기능 강화 (핵심기능)

---

## 📁 폴더 구조

```
lib/
├── main.dart                     # 앱 진입점 — ProviderScope + GoRouter 주입
├── app/
│   ├── router.dart               # go_router 전체 라우트 정의
│   └── theme.dart                # 공통 테마 (Color, TextStyle, ButtonStyle)
├── models/
│   ├── region.dart               # 지역 / 행정동 모델
│   ├── commercial_area.dart      # 상권 분석 결과 모델
│   ├── building.dart             # 건물 정보 모델 (Step 3)
│   ├── score_result.dart         # AI 창업 점수 + SHAP 모델
│   └── user.dart                 # 유저 프로필 모델
├── services/
│   ├── auth_service.dart         # 카카오·네이버 OAuth + Firebase Custom Token 로직
│   └── api_service.dart          # FastAPI 호출 — 토큰 자동 첨부
├── providers/
│   ├── auth_provider.dart
│   ├── region_provider.dart
│   ├── area_provider.dart
│   ├── building_provider.dart
│   └── score_provider.dart
├── views/
│   ├── landing_page.dart
│   ├── login_page.dart
│   ├── auth_callback_page.dart   # ⭐ v3.2 신규 — 카카오·네이버 OAuth 콜백 처리
│   ├── step1_region_page.dart
│   ├── step2_analysis_page.dart
│   ├── step3_map_page.dart       # Step 3 지도 모드
│   └── step4_score_page.dart
└── widgets/
    ├── common/
    │   ├── surbi_loading.dart
    │   ├── surbi_error.dart
    │   └── surbi_empty.dart
    ├── step2/
    │   ├── area_score_card.dart
    │   └── analysis_chart.dart
    ├── step3/
    │   └── building_tag.dart
    └── step4/
        ├── score_gauge.dart
        ├── shap_bar_chart.dart
        └── report_viewer.dart
```

---

## ✅ EPIC 1. 환경 구축 & 기반 설계 ✅ **완료**

> 💡 **이 EPIC의 목표**
> 개발을 본격적으로 시작하기 위한 기반 다지기

---

### ✅ Task 1-1 · Flutter Web 프로젝트 생성 및 폴더 구조 세팅

- [x]  레이어드 아키텍처 기반 초기 폴더 트리 세팅
- [x]  크롬 디바이스 환경에서 정상 빌드 및 구동 확인
- [x]  파일명: `surbi_web`

---

### ✅ Task 1-2 · 모바일 웹 최적화 반응형 레이아웃 기본 틀 구현

- [x]  PC 환경 접근 시 Max Width: `500px` 설정
- [x]  중앙 정렬(Center Matrix) 제약 조건 추가
- [x]  모바일 디바이스 뷰 전환 시 100% 꽉 차는 반응형 스케일링 검증

관련 파일: `main.dart`, `responsive_layout.dart`

---

### ✅ Task 1-3 · 상태관리 라이브러리 세팅 — Riverpod 확정

> ✅ **Provider 대신 Riverpod을 선택한 이유**
>
> - `Provider`는 `BuildContext`에 묶여 있어 Web 라우팅 변경 시 상태 소실 위험
> - `Riverpod`은 Context 없이 어디서든 접근 가능 → Flutter Web에 최적
> - `AsyncNotifier`로 로딩 / 에러 / 데이터 상태를 한 번에 관리 가능
> - 2024년 Flutter 공식 Codelab에서 Riverpod 권장

**pubspec.yaml**

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.8
```

**main.dart — ProviderScope 적용**

```dart
void main() {
  runApp(
    ProviderScope(       // 앱 전체를 ProviderScope로 감싸야 함
      child: SurbiApp(),
    ),
  );
}
```

**화면에서 사용하는 패턴 (모든 화면 동일하게 사용)**

```dart
final state = ref.watch(areaNotifierProvider);
state.when(
  loading: () => const SurbiLoading(message: '상권 데이터 불러오는 중...'),
  error:   (e, _) => SurbiError(message: e.toString(), onRetry: () => ref.refresh(areaNotifierProvider)),
  data:    (areas) => AreaListView(areas: areas),
);
```

- [x]  `flutter pub add flutter_riverpod riverpod_annotation`
- [x]  `ProviderScope` main.dart 적용
- [ ]  `AuthNotifier`, `RegionNotifier`, `AreaNotifier`, `ScoreNotifier` 기본 구조 생성 → ⏳ EPIC 2~3에서 각 화면 개발 시 구현
- [ ]  `flutter pub run build_runner build` 코드 생성 확인 → ⏳ EPIC 2~3에서 구현

---

### ✅ Task 1-4 · go_router 네비게이션 구조 설정

> ⚠️ **Navigator.push를 쓰면 안 되는 이유**
> Flutter Web에서 URL이 바뀌지 않아 뒤로가기 버튼, 북마크, 공유 링크가 전부 작동하지 않음

> 🛠️ **실제 구현하며 추가된 사항 (계획에 없었지만 필요했던 것들)**
> 워크플로우 작성 시점엔 안 보였지만, 실제로 연결해보니 아래 3가지가 추가로 필요했음
>
> - `usePathUrlStrategy()` — URL에서 `#` 제거
> - `ResponsiveLayout`을 `home:` → `builder:`로 이동
> - `flutter_web_plugins` SDK 패키지 추가

**pubspec.yaml**

```yaml
dependencies:
  go_router: ^14.2.0
  flutter_web_plugins:        # ⭐ 추가 — usePathUrlStrategy()에 필요
    sdk: flutter              # 버전 번호(^) 대신 sdk: flutter로 작성
```

> ⚠️ **`flutter_web_plugins`는 일반 패키지와 작성법이 다름**
> pub.dev에서 받는 패키지가 아니라 Flutter SDK 내장 패키지라서 `^버전` 대신 `sdk: flutter`로 적어야 함. (오타 주의: `plugins`는 끝에 **s** 있음)

**app/router.dart — EPIC 1 구현 코드 (PlaceholderPage 뼈대)**

> 💡 **왜 PlaceholderPage인가?**
> Firebase가 없는 상태에서 `authStateProvider`를 쓰면 빌드 에러가 남.
> EPIC 1 단계에서는 라우트 구조만 잡아두고,
> EPIC 2에서 Firebase 연동 후 실제 로직으로 단계별 교체함.
>
> **EPIC 2에서 추가될 것들:**
> - `ref.watch(authStateProvider)` — 로그인 상태 구독
> - `redirect` 로직 — 미로그인 시 `/login`, 로그인 시 `/step1` 이동
> - `/auth/kakao/callback`, `/auth/naver/callback` 라우트
>
> **EPIC 3에서 교체될 것들:**
> - `PlaceholderPage` → 실제 화면 (`LoginPage`, `Step1RegionPage` 등)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// 실제 화면이 완성되기 전까지 임시로 텍스트만 보여주는 화면
// EPIC 2~3에서 실제 화면으로 교체 예정
class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // ref는 지금 사용 안 함
  // EPIC 2에서 Firebase 연동 후 authStateProvider를 ref.watch()로 구독하고
  // redirect 로직(로그인 전 → /login, 로그인 후 → /step1) 추가 예정

  return GoRouter(
    initialLocation: '/',
    routes: [

      // 랜딩 페이지
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const PlaceholderPage(label: 'Surbi 시작'),
      ),

      // 로그인 페이지 (카카오·네이버 소셜 로그인 — EPIC 2에서 구현)
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const PlaceholderPage(label: '로그인 화면 (준비중)'),
      ),

      // Step 1: 지역·카테고리 선택
      GoRoute(
        path: '/step1',
        builder: (context, state) =>
            const PlaceholderPage(label: 'Step 1: 지역·카테고리 선택 (준비중)'),
      ),

      // Step 2: 상권 분석 대시보드
      // :regionCode = 행정동 코드 (예: /step2/1114013600)
      GoRoute(
        path: '/step2/:regionCode',
        builder: (context, state) {
          final regionCode =
              state.pathParameters['regionCode'] ?? '없음';
          return PlaceholderPage(
            label: 'Step 2: 상권 분석 (준비중)\n지역코드: $regionCode',
          );
        },
      ),

      // Step 3: 지도 모드 — 건물 탐색
      GoRoute(
        path: '/step3/map',
        builder: (context, state) =>
            const PlaceholderPage(label: 'Step 3: 지도 모드 (준비중)'),
      ),

      // Step 4: AI 창업 점수 + LLM 보고서
      // :buildingId = 선택한 건물 고유 ID (예: /step4/bld_00123)
      GoRoute(
        path: '/step4/:buildingId',
        builder: (context, state) {
          final buildingId =
              state.pathParameters['buildingId'] ?? '없음';
          return PlaceholderPage(
            label: 'Step 4: AI 분석 (준비중)\n건물 ID: $buildingId',
          );
        },
      ),

    ],
  );
});
```

**main.dart — 최종 코드**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';  // ⭐ 추가
import 'app/router.dart';
import 'widgets/common/responsive_layout.dart';

void main() {
  usePathUrlStrategy();   // ⭐ 추가 — # 없는 깔끔한 URL 사용
  runApp(
    const ProviderScope(
      child: SurbiApp(),
    ),
  );
}

class SurbiApp extends ConsumerWidget {
  const SurbiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Surbi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
      ),
      routerConfig: router,
      builder: (context, child) {                  // ⭐ 추가
        return ResponsiveLayout(child: child!);     // ⭐ 추가
      },
    );
  }
}
```

> ⚠️ **`child!` 의 느낌표** — `builder`가 주는 `child`는 `Widget?` (null 가능) 타입인데,
> `ResponsiveLayout`은 `Widget` (null 불가) 타입을 요구해서 타입 에러.
> `child!`로 "반드시 값이 있다"고 알려주면 해결

**테스트 시 URL 입력 방법**

```
# usePathUrlStrategy() 적용 후
http://localhost:포트번호/login     ✅ 정상 작동

# 만약 usePathUrlStrategy()를 안 썼다면
http://localhost:포트번호/#/login   (# 필요)
```

- [x]  `go_router` 패키지 설치
- [x]  `flutter_web_plugins` SDK 패키지 추가
- [x]  `app/router.dart` 작성
- [x]  `main.dart`에 `routerConfig` 적용 (`MaterialApp` → `MaterialApp.router`)
- [x]  `usePathUrlStrategy()` 적용
- [x]  `ResponsiveLayout`을 `builder`로 이동
- [x]  각 Step 페이지 라우트 연결 및 화면 전환 테스트

---

### ✅ Task 1-5 · 공통 위젯 정의 — 로딩 / 에러 / 빈 화면

> ⚠️ **이 Task를 건너뛰면 API 실패 시 띄울 안내 화면이 없음**
> 모든 화면에서 재사용할 3개 위젯

**widgets/common/surbi_loading.dart**

```dart
class SurbiLoading extends StatelessWidget {
  final String? message;
  const SurbiLoading({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF1565C0)),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: const TextStyle(color: Colors.grey)),
        ],
      ],
    ));
  }
}
```

**widgets/common/surbi_error.dart**

```dart
class SurbiError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const SurbiError({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
      ],
    ));
  }
}
```

**widgets/common/surbi_empty.dart**

```dart
class SurbiEmpty extends StatelessWidget {
  final String message;
  const SurbiEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, color: Colors.grey, size: 48),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: Colors.grey)),
      ],
    ));
  }
}
```

- [x]  `widgets/common/surbi_loading.dart` 작성
- [x]  `widgets/common/surbi_error.dart` 작성
- [x]  `widgets/common/surbi_empty.dart` 작성

---

### ✅ Task 1-6 · GitHub 브랜치 전략 확정

> 💡 **결정 배경**
> Surbi 팀 지침: 한 주간 각자 개별 개발 후 주간 정기회의에서 진행상황 공유.
> 1인 Frontend 개발 체제이므로 PR 리뷰 없이 아래 2단계 구조로 운영하기로 확정.

**확정된 브랜치 전략 (`BRANCH_STRATEGY.md` 기준)**

```
main                              배포 가능한 안정 버전
 └─ feature/frontend-{기능명}     실제 작업 브랜치 (EPIC 2~5)
```

| 단계 | 브랜치 | 이유 |
|------|--------|------|
| EPIC 1 (환경 구축) | `main` 직접 작업 | 초기 세팅 단계로 되돌릴 위험이 낮음 |
| EPIC 2~5 (Firebase · 화면 · API · 배포) | `feature/frontend-*` 작업 후 `main`에 Merge | 외부 서비스 연동·화면 개발 시 시행착오가 많아 안전한 작업 공간 필요 |

**브랜치 이름 예시**

```
feature/frontend-epic2-auth        Firebase 인증 (Task 2-1 ~ 2-5)
feature/frontend-step1-ui          Step 1 화면 (Task 3-1)
feature/frontend-step2-ui          Step 2 화면 (Task 3-2)
feature/frontend-step3-ui          Step 3 지도 화면 (Task 3-3)
feature/frontend-step4-ui          Step 4 점수·보고서 화면 (Task 3-4~3-5)
feature/frontend-api-integration   백엔드 API 연동 (EPIC 4)
```

**작업 흐름 (GitHub Desktop 기준)**

```
1. GitHub Desktop → 현재 브랜치: main
2. Branch → New Branch → 이름 입력 (예: feature/frontend-epic2-auth)
3. feature 브랜치에서 코딩 → Commit → Push (여러 번 반복)
4. 기능 단위 작업 완료 시
   → Branch → main으로 전환
   → Branch → Merge into Current Branch → feature 브랜치 선택
5. main Push
```

**커밋 메시지 컨벤션**

```
<type>: <설명> (Task 번호)

feat: Riverpod 상태관리 세팅 (Task 1-3)
fix: ResponsiveLayout child 타입 에러 수정
docs: 브랜치 전략 문서 작성 (Task 1-6)
refactor: auth_service 구조 개선
```

- [x]  `BRANCH_STRATEGY.md` 작성 및 GitHub Push 완료
- [x]  EPIC 2부터 `feature/frontend-*` 브랜치 운영 확정
- [x]  커밋 메시지 컨벤션 문서화

---

### ✅ Task 1-7 · Figma 전체 화면 와이어프레임 제작 및 팀원 컨펌

> 💡 **왜 EPIC 1에서 와이어프레임 짜는 이유**
> 화면 설계가 확정되어야 Step별 UI 개발을 시작할 수 있다고 판단 + 개발 편의성

- [x]  Step 1 ~ Step 4 전 화면
- [x]  랜딩 페이지 / 로그인 페이지
- [x]  **로딩 화면 / 에러 화면 / 검색 결과 없음 화면 포함**
- [x]  Step 3 지도 모드 화면 포함
- [x]  Figma 링크 팀 Notion 자료실에 공유

---

## 🔵 EPIC 2. 인증 & 사용자 관리

> 💡 **이 EPIC의 목표**
> 인증 구조를 먼저 잡아야 이후 모든 화면에서 유저 정보를 쓸 수 있음

> 🌿 **브랜치**: `feature/frontend-epic2-auth`

---

### ⏳ Task 2-1 · Firebase 프로젝트 생성 및 Flutter Web 연동

- [ ]  Firebase Console에서 프로젝트 생성
- [ ]  `flutterfire configure` 명령어로 `firebase_options.dart` 자동 생성
- [ ]  `web/index.html`에 Firebase SDK 스크립트 삽입 확인
- [ ]  `pubspec.yaml`에 Firebase 패키지 추가

```yaml
dependencies:
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.2.0
```

---

### ⏳ Task 2-2 · 카카오 · 네이버 소셜 로그인 구현

> 💡 **왜 카카오 · 네이버인가?**
> 국내 서비스 타겟 + 주 사용자층(예비 창업자)의 SNS 접근성 고려.
> 구글 로그인은 지원하지 않음.

> ⚠️ **카카오·네이버 로그인은 백엔드 의존성이 있음**
> 구글 로그인과 달리, 카카오·네이버는 Firebase 기본 지원이 없어서
> 백엔드(최민수)가 `POST /auth/kakao`, `POST /auth/naver` 엔드포인트를 완성해야 연동 가능.
> **백엔드 완료 전까지는 UI만 먼저 구현하고, API 연동은 EPIC 4와 함께 진행.**

**카카오 · 네이버 로그인 전체 흐름 (5단계)**

```
① 사용자가 "카카오로 로그인" 버튼 클릭
      ↓
② Flutter가 카카오 OAuth 페이지로 이동
   (url_launcher로 브라우저 오픈)
      ↓
③ 카카오 로그인 완료 → 우리 앱으로 리다이렉트
   /auth/kakao/callback?code=AUTHORIZATION_CODE
      ↓
④ go_router가 콜백 경로 감지 → AuthCallbackPage 진입
   → authorization_code를 백엔드에 전달
   → 백엔드가 카카오 서버에서 사용자 정보 확인 후 Firebase Custom Token 발급
   → Custom Token을 프론트에 반환
      ↓
⑤ FirebaseAuth.signInWithCustomToken(token) → 로그인 완료
   → go_router redirect → /step1 이동
```

**사전 준비 (최초 1회)**

```
① 카카오 Developers 앱 등록
   https://developers.kakao.com
   → 내 애플리케이션 → 앱 추가
   → 플랫폼: Web → 사이트 도메인 입력
   → Redirect URI: https://{우리도메인}/auth/kakao/callback
   → REST API 키 복사 → .env 파일에 저장

② 네이버 Developers 앱 등록
   https://developers.naver.com
   → Application → 애플리케이션 등록
   → 서비스 URL, Callback URL 입력
   → Client ID · Client Secret 복사 → .env 파일에 저장
```

**pubspec.yaml에 추가**

```yaml
dependencies:
  url_launcher: ^6.2.5          # 카카오·네이버 OAuth 페이지 열기
```

**services/auth_service.dart**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';      // 백엔드 API 호출용

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _api = ApiService();

  // ① 카카오 OAuth 페이지로 이동 (버튼 클릭 시 호출)
  Future<void> launchKakaoLogin() async {
    final uri = Uri.parse(
      'https://kauth.kakao.com/oauth/authorize'
      '?client_id=${Env.kakaoClientId}'          // .env에서 읽어옴
      '&redirect_uri=${Env.kakaoRedirectUri}'    // /auth/kakao/callback
      '&response_type=code',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ② 네이버 OAuth 페이지로 이동
  Future<void> launchNaverLogin() async {
    final uri = Uri.parse(
      'https://nid.naver.com/oauth2.0/authorize'
      '?client_id=${Env.naverClientId}'
      '&redirect_uri=${Env.naverRedirectUri}'    // /auth/naver/callback
      '&response_type=code'
      '&state=RANDOM_STATE',                     // CSRF 방지용
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ③ 백엔드에서 받은 Custom Token으로 Firebase 로그인 완료
  Future<UserCredential> signInWithCustomToken(String customToken) async {
    return await _auth.signInWithCustomToken(customToken);
  }

  // ④ 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

**views/auth_callback_page.dart (OAuth 콜백 처리 전담)**

```dart
// OAuth 콜백 전담 페이지
// 카카오·네이버에서 authorization code를 받아
// 백엔드에 전달 → Custom Token 수신 → Firebase 로그인 완료
class AuthCallbackPage extends ConsumerWidget {
  final String provider;   // 'kakao' 또는 'naver'
  final String? code;      // authorization_code (URL 파라미터에서 추출)

  const AuthCallbackPage({required this.provider, this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 로그인 처리 중 화면 표시
    return const SurbiLoading(message: '로그인 처리 중...');
    // 실제 로직은 authCallbackProvider에서 처리:
    // 1. code를 POST /auth/{provider}에 전달
    // 2. Custom Token 수신
    // 3. FirebaseAuth.signInWithCustomToken(token)
    // 4. go_router redirect → /step1
  }
}
```

> ⚠️ **백엔드 연동 전 임시 처리**
> 백엔드 `/auth/kakao`, `/auth/naver` 완성 전까지는
> `AuthCallbackPage`에서 로딩 화면만 보여주고 실제 로그인은 건너뜀.
> 화면 개발(EPIC 3)은 Mock 데이터로 먼저 진행하고
> API 연동(EPIC 4) 단계에서 실제 로그인을 연결함.

**Firebase Console 설정**

```
Firebase Console → Authentication → 로그인 방법
→ 맞춤 (Custom) 제공업체 활성화 (Custom Token용)
→ 허용된 도메인에 우리 도메인 추가
```

- [ ]  카카오 Developers 앱 등록 및 Redirect URI 설정
- [ ]  네이버 Developers 앱 등록 및 Callback URL 설정
- [ ]  `url_launcher` 패키지 추가
- [ ]  `services/auth_service.dart` 작성 (OAuth 페이지 이동 + Custom Token 로그인 메서드)
- [ ]  `views/auth_callback_page.dart` 작성 (콜백 처리 UI)
- [ ]  Firebase Console Custom 제공업체 활성화
- [ ]  백엔드 `POST /auth/kakao`, `POST /auth/naver` 완성 후 → 실제 연동 (EPIC 4에서)

---

### ⏳ Task 2-3 · 로그인 상태 기반 라우팅 처리

> 💡 **이 Task에서 router.dart를 최종 완성시킴**
> Task 1-4에서는 PlaceholderPage 뼈대만 잡아뒀고,
> 여기서 `authStateProvider` 구독 + `redirect` 로직 + OAuth 콜백 경로 + 실제 화면 임포트를 전부 추가함

- [ ]  `providers/auth_provider.dart` 작성 — `authState` Provider 구현
- [ ]  `router.dart`에 `ref.watch(authStateProvider)` 추가
- [ ]  `router.dart`에 `redirect` 로직 추가 (로그인 전 → `/login`, 로그인 후 → `/step1`)
- [ ]  `router.dart`에 `/auth/kakao/callback`, `/auth/naver/callback` 경로 추가
- [ ]  OAuth 콜백 경로(`/auth/*`)는 redirect에서 제외 처리
- [ ]  `PlaceholderPage` → 실제 임포트 경로로 교체 (`LoginPage` 등)

```dart
// providers/auth_provider.dart
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
  // authStateChanges()는 로그인/로그아웃 시 자동으로 User 또는 null 반환
  // Custom Token 로그인도 동일하게 작동함
}
```

---

### ⏳ Task 2-4 · FastAPI 요청 시 Firebase ID 토큰 자동 첨부

> 💡 **카카오·네이버 Custom Token으로 Firebase 로그인을 완료했어도
> 이후 API 요청에는 Firebase가 발급한 ID 토큰을 쓰면 됨 — 방식은 구글 로그인과 동일**

> ⚠️ **Flutter Web에서 토큰 저장 주의사항**
> `flutter_secure_storage`는 Web에서 내부적으로 `localStorage`를 사용해 XSS에 취약.
> 권장 방법: Firebase가 토큰을 관리하고, 매 요청마다 `getIdToken()`으로 최신 토큰을 가져올 것.

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

- [ ]  `services/api_service.dart` 작성
- [ ]  `GET`, `POST` 메서드 구현 및 토큰 첨부 테스트
- [ ]  401 응답 시 자동 로그아웃 처리 확인

---

### ⏳ Task 2-5 · Firestore — 관심 상권 스크랩 / AI 리포트 내역 저장

```
// Firestore 구조
users/{uid}/
  ├── scraps/{scrapId}    → 관심 상권 스크랩
  └── reports/{reportId}  → AI 분석 리포트 내역

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

> 💡 **PostgreSQL favorites 테이블과의 관계**
> DB 설계(김성환)에 `favorites` 테이블이 있음 (백엔드 관리).
> Firestore는 앱에서 빠르게 읽어야 하는 스크랩·리포트 목록용 (프론트 관리).
> 두 저장소가 다른 목적으로 공존하는 구조.

- [ ]  Firestore 컬렉션 구조 설계 및 생성
- [ ]  Security Rules 적용
- [ ]  스크랩 저장 / 불러오기 기능 구현
- [ ]  리포트 내역 저장 / 불러오기 기능 구현

---

## 🔵 EPIC 3. Step 1~4 핵심 화면 개발

> 💡 **이 EPIC의 목표**
> 사용자가 실제로 보고 사용하는 화면 개발 단계 > EPIC 1의 와이어프레임(Task 1-7) 참고

> ⚠️ **개발 순서 주의**
> API가 없는 상태에서 EPIC 4의 Mock 데이터를 먼저 정의 → 그 구조에 맞춰 UI 개발 → API가 나오면 Mock만 교체

> 🌿 **브랜치**: 화면별로 `feature/frontend-step{N}-ui` 분리 운영

---

### ✅ Task 3-1 · [Step 1] 지역 및 카테고리 선택 UI

- [x]  시 / 구 / 동 검색창 또는 드롭다운 구현
- [x]  창업 카테고리 선택 버튼 (카페 / 치킨 / 한식 / 분식 등)
- [x]  선택 완료 시 `/step2/{regionCode}`로 이동
- [x]  선택 상태 Riverpod `RegionNotifier`로 관리
- [x]  하단 히트맵 영역 UI 구현 (행정동별 창업 점수를 색상 진하기로 표시, Figma 참고)
       → ⚠️ 실제 색상 데이터는 DB `geom` 컬럼 미적재 상태 → 지금은 회색 placeholder 박스로 구현
       → 데이터 연동은 Task 4-3에서 진행 예정

---

### ⏳ Task 3-2 · [Step 2] 상권 분석 대시보드 UI

- [ ]  행정동별 창업 점수 지도 오버레이 또는 리스트 표시
- [ ]  유동인구 / 경쟁도 / 소비 패턴 차트 위젯 구현
- [ ]  `fl_chart` 패키지 활용
- [ ]  상권 카드 클릭 시 Step 3으로 이동

```yaml
dependencies:
  fl_chart: ^0.68.0
```

---

### ⏳ Task 3-3 · [Step 3] 건물 탐색 UI — 지도 모드

- [ ]  지도 위에 건물 마커 표시 (카카오 지도 API 연동)
- [ ]  건물 마커 탭 시 건물 정보 BottomSheet 표시
- [ ]  BottomSheet에 건물명 / 주소 / 거리 / 미리보기 점수 표시
- [ ]  `/step4/{buildingId}`로 이동 버튼

---

### ⏳ Task 3-4 · [Step 4] AI 창업 점수 + SHAP 시각화 UI

- [ ]  점수 게이지 (0~100점 원형 또는 반원형 차트)
- [ ]  SHAP 항목별 기여도 수평 막대 차트
    - 양수 기여 → 파란색, 음수 기여 → 빨간색
- [ ]  예상 월 매출 표시 (천 단위 콤마)
- [ ]  폐업 위험도 % 표시
- [ ]  "AI 보고서 생성하기" 버튼

---

### ⏳ Task 3-5 · [Step 4] LLM 보고서 출력 화면 UI ⭐ 핵심 기능

> 💡 **보고서 생성은 10~30초 소요 → 단순 스피너 대신 단계별 메시지 필요**

```dart
// 단계별 로딩 메시지 예시
final messages = [
  '상권 데이터 분석 중...',
  'AI 모델 추론 중...',
  '보고서 작성 중...',
  '거의 다 됐어요!',
];
```

- [ ]  단계별 로딩 메시지 위젯 구현 (3초마다 메시지 교체)
- [ ]  보고서 출력 화면 (문서형 레이아웃)
    - 상권 요약 / 리스크 요인 / 정책 추천 / 체크리스트 섹션
- [ ]  PDF 다운로드 버튼 (추후 구현, 우선 공유 링크로 대체 가능)
- [ ]  보고서 Firestore 저장 → Task 2-5 연동

---

### ⏳ Task 3-6 · 정부 지원사업 추천 카드 리스트 UI

- [ ]  카드 구성: 사업명 / 지원 기관 / 신청 기간 / 외부 링크
- [ ]  스크랩 버튼 → Firestore 저장 연동 (Task 2-5)
- [ ]  카드 리스트 빈 결과 시 `SurbiEmpty` 위젯 표시

---

### ⏳ Task 3-7 · 창업 행동 유도 체크리스트 UI

- [ ]  체크리스트 항목 표시 및 체크 기능
- [ ]  완료 항목 Firestore 저장
- [ ]  진행률 표시 (완료 N / 전체 N)

---

## 🔵 EPIC 4. 백엔드 API 연동

> 💡 **이 EPIC의 목표**
> EPIC 3에서 Mock 데이터로 만들어둔 화면에 실제 백엔드 데이터 연결

> ⚠️ **API 연동 전 백엔드 API 명세 확정(Task 4-2) 필요 — With. BE**

---

### ❌ Task 4-1 · Mock 데이터 구조 정의 — **정책 변경으로 폐기**

> ⚠️ **2026-06-29 회의 이후 방침 변경**
> 최초엔 `services/mock_data.dart`에 가짜 데이터 뭉치를 만들어두는 방식으로 시작했으나,
> 팀 방침이 "Mock 데이터 사용 안 함"으로 확정되면서 **이 Task 자체가 폐기**됨.
> 대신 Task 3-1에서 **B안 원칙**(화면에 데이터 하드코딩 금지, Provider 계층에 격리)으로
> 각 Provider(`districtListProvider`, `categoryListProvider` 등)가 임시 데이터를
> 직접 반환하는 방식으로 대체함. 나중에 API 연동 시 Provider 내부 반환값만 교체하면
> 화면 코드는 무수정으로 대응 가능.

- [x]  ~~`services/mock_data.dart` 작성~~ → 작성 후 **삭제 완료** (Mock 미사용 방침 확정)
- [x]  `models/` 하위 모델 파일(7개)은 유지 → API 연동 시 재사용
- [x]  각 화면별 Provider가 직접 임시 데이터 반환하는 방식으로 대체 (Task 3-1 참고)
- [ ]  API 연동 완료 시 각 Provider 내부만 실제 API 호출로 교체 (Task 4-3 이후)

---

### ⏳ Task 4-2 · 백엔드 API 명세 확정 (With. 백엔드)

| 메서드 / 경로 | 인증 | 설명 | 프론트 사용처 |
| --- | --- | --- | --- |
| `POST /auth/kakao` | ❌ | 카카오 code → Firebase Custom Token 발급 | 카카오 로그인 콜백 |
| `POST /auth/naver` | ❌ | 네이버 code → Firebase Custom Token 발급 | 네이버 로그인 콜백 |
| `GET /regions?category={cat}` | ❌ | 지역 히트맵 데이터 | Step 1 |
| `GET /areas?region={code}&category={cat}` | ✅ | 상권 분석 결과 | Step 2 |
| `GET /buildings?lat={}&lng={}&r={}` | ❌ | 반경 내 건물 목록 | Step 3 |
| `GET /areas/{id}/score` | ✅ | AI 창업 점수 + SHAP | Step 4 |
| `POST /reports/generate` | ✅ | LLM 보고서 생성 요청 | Step 4 |
| `GET /reports/{id}` | ✅ | 생성된 보고서 조회 | Step 4 폴링 |
| `GET /policies?category={cat}&region={code}` | ❌ | 정부 지원사업 목록 | Step 4 |
| `POST /favorites` | ✅ | 관심 상권 즐겨찾기 저장 | Step 2·3 |

**`GET /areas/{id}/score` 응답 예시**

```json
{
  "total_score": 78.5,
  "predicted_sales": 4200000,
  "closure_risk_pct": 23.1,
  "shap_factors": [
    { "name": "유동인구 지수",    "value": 18.2, "max_score": 20 },
    { "name": "업종 소비력",      "value": 15.1, "max_score": 20 },
    { "name": "경쟁 강도",        "value": -4.5, "max_score": 15 },
    { "name": "접근성",           "value":  8.3, "max_score": 10 },
    { "name": "운영 안정성",      "value": 12.0, "max_score": 15 },
    { "name": "정책 지원 적합도", "value": 16.0, "max_score": 20 }
  ]
}
```

**`POST /auth/kakao` 요청·응답 예시**

```json
// 요청
{ "code": "AUTHORIZATION_CODE_FROM_KAKAO" }

// 응답
{ "custom_token": "Firebase Custom Token 문자열" }
```

- [ ]  위 명세표를 백엔드 팀(최민수, 김성환)에게 공유
- [ ]  인증 엔드포인트 2개 (`/auth/kakao`, `/auth/naver`) 구현 일정 최민수와 합의
- [ ]  필드명 및 응답 형식 최종 합의
- [ ]  합의된 명세 기반으로 `models/` 코드 확정

---

### ⏳ Task 4-3 · [Step 1] 지역 히트맵 API 연동

- [ ]  `GET /regions?category={cat}` 호출 구현
- [ ]  Mock 데이터 → 실제 API로 교체
- [ ]  로딩 / 에러 / 빈 결과 상태 처리

---

### ⏳ Task 4-4 · [Step 2] 상권 분석 API 연동

- [ ]  `GET /areas?region={code}&category={cat}` 호출 구현
- [ ]  Mock 데이터 → 실제 API로 교체
- [ ]  로딩 / 에러 / 빈 결과 상태 처리

---

### ⏳ Task 4-5 · [Step 3] 건물 목록 API 연동

- [ ]  `GET /buildings?lat={}&lng={}&r={}` 호출 구현
- [ ]  지도 마커에 실제 건물 데이터 바인딩
- [ ]  GPS 좌표 기반 동적 조회 (이동 시 재조회)

---

### ⏳ Task 4-6 · [Step 4] AI 점수 + LLM 보고서 API 연동

- [ ]  `GET /areas/{id}/score` 호출 → 점수/SHAP 화면 바인딩
- [ ]  `POST /reports/generate` 호출 → 비동기 보고서 생성 요청
- [ ]  `GET /reports/{id}` 폴링 (3초 간격) → 완료 시 보고서 표시
- [ ]  타임아웃(60초) 처리 및 실패 안내

```dart
// 폴링 패턴 예시
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

### ⏳ Task 4-7 · 카카오 · 네이버 로그인 백엔드 연동

> ⚠️ **백엔드 `/auth/kakao`, `/auth/naver` 완성 후 진행**

- [ ]  `POST /auth/kakao` 호출 → Custom Token 수신 → Firebase 로그인 완료 구현
- [ ]  `POST /auth/naver` 호출 → Custom Token 수신 → Firebase 로그인 완료 구현
- [ ]  `AuthCallbackPage`에 실제 로직 연결
- [ ]  로그인 성공 시 `/step1` 자동 이동 확인
- [ ]  로그인 실패 시 에러 안내 및 `/login` 복귀 처리

---

## 🔵 EPIC 5. 품질 검증 & 배포

> 💡 **이 EPIC의 목표**
> 완성된 앱을 실제 사용자가 쓸 수 있도록 마무리하는 단계

---

### ⏳ Task 5-1 · CanvasKit 초기 로딩 스플래시 구현

> ⚠️ **Flutter Web(CanvasKit)은 첫 방문 시 약 5~8MB Wasm 파일 다운로드**
> 사용자에게 흰 화면이 보이면 이탈 확률이 높아질 것으로 판단

**web/index.html에 추가**

```html
<style>
  .loading-overlay {
    position: fixed; inset: 0;
    background: #1565C0;
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

- [ ]  `icons/surbi_logo.png` 파일 준비 (192×192px)
- [ ]  `web/index.html` 로딩 오버레이 추가
- [ ]  실제 기기에서 로딩 → 앱 전환 확인

---

### ⏳ Task 5-2 · 전체 화면 에러 케이스 점검

- [ ]  네트워크 연결 없음 시 에러 화면 표시 확인
- [ ]  API 500 에러 시 `SurbiError` + 재시도 버튼 확인
- [ ]  검색 결과 없음 시 `SurbiEmpty` 확인
- [ ]  로그인 만료 시 자동 로그아웃 → 로그인 화면 이동 확인
- [ ]  LLM 보고서 타임아웃(60초) 시 에러 안내 화면 확인

---

### ⏳ Task 5-3 · Flutter Web 빌드 최적화

```bash
# 릴리즈 빌드
flutter build web --web-renderer canvaskit --release

# 빌드 결과 확인
ls -lh build/web/

# 로컬에서 빌드 결과 미리보기
cd build/web && python3 -m http.server 8080
```

- [ ]  릴리즈 빌드 성공 확인
- [ ]  빌드 결과물 용량 확인 (목표: 15MB 이하)
- [ ]  로컬 미리보기로 전체 화면 최종 점검

---

### ⏳ Task 5-4 · Firebase Hosting 배포 및 URL 공유

```bash
# Firebase CLI 설치 (최초 1회)
npm install -g firebase-tools

# 로그인
firebase login

# 초기화 (최초 1회)
firebase init hosting
# → Public directory: build/web
# → Single-page app: Yes

# 배포
firebase deploy --only hosting
```

- [ ]  Firebase Hosting 프로젝트 연결
- [ ]  `firebase.json` 설정 확인
- [ ]  배포 완료 후 URL 확인
- [ ]  **배포 URL 팀 Notion 자료실에 공유**
- [ ]  모바일 기기 실제 접속 및 전체 플로우 테스트

---

## 📋 전체 Task 요약 일정

| Task | 내용 | EPIC | 우선순위 | 상태 |
| --- | --- | --- | --- | --- |
| 1-1 | Flutter Web 프로젝트 생성 및 폴더 구조 | 환경 | P1 | ✅ 완료 |
| 1-2 | 반응형 레이아웃 기본 틀 | 환경 | P1 | ✅ 완료 |
| 1-3 | Riverpod 세팅 (기반 완료 / Notifier는 EPIC 2~3에서) | 환경 | 🔥 P1 | ✅ 완료 |
| 1-4 | go_router 네비게이션 구조 | 환경 | 🔥 P1 | ✅ 완료 |
| 1-5 | 공통 에러 / 로딩 / 빈 화면 위젯 | 환경 | 🔥 P1 | ✅ 완료 |
| 1-6 | GitHub 브랜치 전략 확정 | 환경 | P2 | ✅ 완료 |
| 1-7 | Figma 와이어프레임 제작 | 환경 | P1 | ✅ 완료 |
| 2-1 | Firebase 프로젝트 생성 및 연동 | 인증 | P1 | ⏳ 예정 |
| 2-2 | 카카오·네이버 소셜 로그인 UI | 인증 | P1 | ⏳ 예정 |
| 2-3 | 로그인 상태 라우팅 처리 | 인증 | P1 | ⏳ 예정 |
| 2-4 | Firebase ID 토큰 API 헤더 자동 첨부 | 인증 | P1 | ⏳ 예정 |
| 2-5 | Firestore 스크랩 / 리포트 저장 | 인증 | P2 | ⏳ 예정 |
| 3-1 | [Step 1] 지역 / 카테고리 선택 UI | 화면 | P1 | ✅ 완료 |
| 3-2 | [Step 2] 상권 분석 대시보드 UI | 화면 | P1 | ⏳ 예정 |
| 3-3 | [Step 3] 건물 탐색 — 지도 모드 UI | 화면 | P1 | ⏳ 예정 |
| 3-4 | [Step 4] AI 창업 점수 + SHAP UI | 화면 | P1 | ⏳ 예정 |
| 3-5 | [Step 4] LLM 보고서 출력 화면 UI ⭐ | 화면 | 🔥 P1 | ⏳ 예정 |
| 3-6 | 정부 지원사업 추천 카드 UI | 화면 | P2 | ⏳ 예정 |
| 3-7 | 창업 행동 체크리스트 UI | 화면 | P2 | ⏳ 예정 |
| 4-1 | Mock 데이터 구조 정의 | 연동 | 🔥 P1 | ❌ 폐기 (Provider 직접 관리로 대체) |
| 4-2 | 백엔드 API 명세 확정 (팀 협의) | 연동 | 🔥 P1 | ⏳ 예정 |
| 4-3 | [Step 1] 지역 히트맵 API 연동 | 연동 | P1 | ⏳ 예정 |
| 4-4 | [Step 2] 상권 분석 API 연동 | 연동 | P1 | ⏳ 예정 |
| 4-5 | [Step 3] 건물 목록 API 연동 | 연동 | P1 | ⏳ 예정 |
| 4-6 | [Step 4] AI 점수 + LLM 보고서 API 연동 | 연동 | P1 | ⏳ 예정 |
| 4-7 | 카카오·네이버 로그인 백엔드 연동 | 연동 | P1 | ⏳ 예정 |
| 5-1 | CanvasKit 초기 로딩 스플래시 | 배포 | P2 | ⏳ 예정 |
| 5-2 | 전체 화면 에러 케이스 점검 | 배포 | P1 | ⏳ 예정 |
| 5-3 | Flutter Web 빌드 최적화 | 배포 | P2 | ⏳ 예정 |
| 5-4 | Firebase Hosting 배포 및 URL 공유 | 배포 | P1 | ⏳ 예정 |

---

## 🔥 다음 진행 순서 (우선순위)

```
① ✅ EPIC 1 전체 완료

② ❌ Task 4-1 Mock 데이터 정의 → 폐기 (2026-06-29 방침 변경)
   → Provider가 직접 임시 데이터 반환하는 방식으로 대체, Task 3-1에 흡수됨

③ ✅ Task 3-1 [Step 1] 지역·카테고리 선택 UI 완료 (2026-07-06 main 병합)
   → 검색창(자동완성)/카테고리 버튼/히트맵 placeholder/분석시작 버튼 전체 구현
   → 브랜드 컬러도 팀 회의 거쳐 최종 확정(은백색+네이비) 후 main 병합 완료

④ Task 2-1 Firebase 프로젝트 생성 (백엔드 의존 없이 혼자 진행 가능) ← 다음 순서

⑤ Task 4-2 API 명세 백엔드와 합의
   → 인증 엔드포인트 일정 포함 (/auth/kakao, /auth/naver)
   → models/ 코드 확정

⑥ EPIC 3 나머지 화면 개발 (Step 2부터, Provider 직접 관리 방식 동일 적용)

⑦ Task 2-2 카카오·네이버 로그인 UI 구현
   → 백엔드 없이도 UI·버튼 먼저 만들기 가능
   → 실제 연동은 Task 4-7에서

⑧ EPIC 4 API 연동 (백엔드 완성 후)
   → 4-7 (인증 연동) 포함
```

---

## 📝 메모

- Frontend 개발은 1인 개발 구조로 분리됨 → 팀장 추천

- 팀장 지침: 개별 개발 후 주간 정기회의에서 진행상황만 공유

- 브랜치 전략: EPIC 1 → main 직접 작업 / EPIC 2~5 → feature 브랜치 (BRANCH_STRATEGY.md 기준)

- 로그인 방식: **카카오 · 네이버만** (구글 제외 / 자체 로그인 없음)

- 카카오·네이버 로그인은 백엔드 Custom Token 방식 → 백엔드와 일정 합의 필요

- 국내 서비스 타겟 → 카카오·네이버 선택 (국내 주요 소셜 로그인)

- 정부지원 타겟 => 유료기능(Step 4) → 무료기능으로 전환(step 1~3과 동일)

- scores 테이블 스키마 확정(0707 DB팀 문서 확인): total_score, population_score,
  sales_score, age_target_score, competitor_score, ml_sales_score,
  transport_score, rent_score, model_version, score_reason 컬럼으로 구성됨.
  score_reason이 LLM 보고서 생성 핵심 입력값 → Task 3-4 score_result.dart 모델 설계 시 이 스키마 그대로 참고

- Step 4 접근 조건 미확정 (A: 로그인 필수 / B: 비로그인 가능)
  → Task 2-3 시작 전까지 확인 필요 + 유료기능을 아예 빼버리는건지

- Task 3-1 히트맵 UI는 Figma 디자인엔 포함돼 있으나 최초 문서엔 누락 
  → 0704 확인 후 추가. 실데이터는 DB geom 컬럼 적재 이후(히트맵 기능 정식 착수 시) 연동

- Mock 데이터 방침 폐기(2026-06-29 회의) → Task 4-1 자체가 무의미해짐. 대신 Provider가
  직접 임시 데이터를 반환하는 방식(B안)으로 대체, `models/`는 유지·`mock_data.dart`는 삭제

- Task 3-1 완료(2026-07-06): 검색창(자동완성 드롭다운) · 카테고리 버튼 · 히트맵 placeholder ·
  분석시작 버튼(조건부 활성화) 전체 구현, `RegionNotifier`로 선택 상태 관리
    government_policy.dart fromJson 필드명 불일치 해결(0707 DB팀 문서 확인):
    id → pblanc_id, organization → agency(실행기관)/jrsd_instt_nm(주관기관)로 확정. 
    summary(bsnsSumryCn, LLM 입력값), start_date/end_date(reqstBeginEndDe 파싱) 컬럼도 함께 확정됨 
    → Task 3-6 착수 전 모델 필드명 수정 필요

- 브랜드 컬러 결정 과정: 최초 Figma 하늘색은 임의 선택이었음을 확인 후 전면 재검토
  → A안(딥틸+앰버) 제안 → 실구현 후 앰버가 원색적이라 번트시에나로 재조정
  → B안(네이비+골드) 대안 검토 → 정기회의(0706)에서 팀 피드백 "깔끔한 게 낫다" 반영
  → 최종 은백색(#F8FAFA)+네이비(#1E3A5F) 확정. 근거 문서는 Notion
  "Surbi 브랜드 컬러 결정 근거(A안/B안)" 참고

- PR #2(Task 3-1 전체 구현), PR #3(브랜드 컬러 최종 반영) 모두 main 병합 완료(0706)

- 브랜치 정리 완료: `feature/frontend-mock-data`, `feature/frontend-step1-ui`,
  `feature/frontend-step1-ui-colorfinal`은 병합 후 삭제. `feature/frontend-step1-ui-navygold`는
  B안 실험 기록 보존 목적으로 의도적으로 남겨둠

---

## 🔧 트러블슈팅

> 개발 중 발생한 오류·실수와 해결 과정을 별도로 기록. 같은 실수 반복 방지 및
> 포트폴리오 면접 대비("어려웠던 점과 해결 과정") 자료로 활용.

- **Hot Reload와 Hot Restart 혼동**: `main()` 안에 넣은 임시 테스트 코드(`print`문)가
  Hot Reload로는 재실행되지 않아 콘솔에 안 찍히는 문제 발생
  → `main()`은 앱을 처음 켤 때 딱 한 번만 실행되므로, 코드 변경 후에는 완전 재시작(정지 → F5)
  필요하다는 걸 학습

- **B안 원칙 위반 실수**: Step 1 검색창 자동완성 후보 목록을 화면(View) 파일에
  직접 하드코딩(`_tempDistricts` 상수)한 채로 "B안 지켰다"고 착각
  → `districtListProvider`를 만들어 Provider 계층으로 이동시켜 수정. "말은 원칙대로,
  코드는 다르게" 짜는 패턴을 스스로도 계속 경계하기로 함

- **주석 위치 오류**: `region_provider.dart`에서 `districtListProvider`를 설명하는 주석이
  엉뚱하게 `regionNotifierProvider` 위에 붙어있던 것 발견 → 위치 수정

- **TODO 주석 Task 번호 오기재**: `districtListProvider`의 TODO 주석에 "Task 4-2 연동
  예정"이라고 썼으나, 실제 API 연동 작업은 Task 4-3이 맞음 → 번호 수정

- **브랜치를 잘못된 기준으로 분기**: `feature/frontend-step1-ui`를 `main`이 아니라
  `feature/frontend-mock-data`에서 분기해서, PR을 열었을 때 관련 없는 파일(models/,
  다른 provider들)까지 전부 "새로 추가된 것"으로 표시되는 문제 발생
  → 교훈: 새 브랜치는 항상 최신화된 `main`에서 파야 함. 이후 색상 최종본 브랜치는
  main 병합 완료 후 새로 깨끗하게 분기해서 재발 방지

- **로컬/원격 브랜치 삭제 혼동**: `git branch -d`(로컬 삭제)만 실행하고 GitHub 원격
  저장소의 "Delete branch" 버튼(또는 `git push origin --delete`)을 누락 → `git branch -a`로
  확인했을 때 원격에 삭제된 브랜치가 여전히 남아있는 걸 발견하고 재삭제
  
- **색상 실험 중 촌스러움 문제**: 앰버(#D97706) 강조색이 딥틸 배경과 결합했을 때
  "당근 같다"는 피드백 → 채도를 낮춘 브라운 계열(번트시에나 #A0522D)로 교체.
  JCR(2025) 논문의 "저채도=고급 인식" 결과와 방향이 일치함을 사후 확인

---

## 🔗 링크

**GitHub**
https://github.com/sagming40/surbi_web

**Figma 와이어프레임**
https://www.figma.com/design/EN5re8TzbBLQcQLznIOjmJ/Surbi---Figma-와이어프레임?node-id=0-1&t=mvClrMC6i4bGmxKV-1

---

*FRONT-END WORKFLOW v3.3 · 사공민규 · 최종 수정: 2026.07.06*
