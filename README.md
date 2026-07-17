# Surbi — AI 기반 공공형 창업 의사결정 지원 플랫폼

> "당신의 창업, 데이터가 먼저 말합니다."

[![Flutter](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-0175C2)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📌 프로젝트 소개

**Surbi**는 예비 외식업 창업자가 복잡한 공공 상권 데이터를 쉽게 이해하고,  
실제 창업 의사결정으로 이어질 수 있도록 지원하는 **AI 기반 공공형 웹 플랫폼**입니다.

공공 상권 빅데이터 분석 결과와 정부 지원 혜택 정보를 통합하여,  
초보 창업자도 이해할 수 있는 **맞춤형 창업 의사결정 보고서**를 자동으로 생성합니다.

- 서비스명: **Surbi** (**S**tart yo**ur** **b**usiness **i**ntelligence)
- 개발 기간: 2026.06 ~
- 소속: 한국폴리텍II대학 인천캠퍼스 컴퓨터공학과(하이테크과정) 캡스톤 프로젝트

---

## 🎯 핵심 기능

| 단계 | 기능 | 설명 |
|------|------|------|
| Step 1 | 지역 · 업종 선택 | 희망 지역(시/구/동)과 외식업 업종 선택 → 행정동별 창업 점수 히트맵 |
| Step 2 | 상권 분석 대시보드 | 유동인구, 소비 패턴, 경쟁업소 분포, 접근성 시각화 |
| Step 3 | 건물 단위 탐색 | 지도 모드로 건물별 상세 정보 탐색 |
| Step 4 | AI 창업 점수 + 보고서 | ML 기반 0~100점 창업 점수 + LLM 자연어 보고서 자동 생성 |

---

## 🛠️ 기술 스택

### Frontend (담당: 사공민규)
- **Flutter Web** — 단일 코드베이스 웹 앱
- **Riverpod** — 전역 상태 관리
- **go_router** — 웹 네비게이션 (URL 라우팅)
- **Firebase Auth** — 카카오 · 네이버 소셜 로그인 (Custom Token 방식)
- **Cloud Firestore** — 사용자 데이터 저장
- **fl_chart** — 상권 데이터 시각화
- **Kakao Maps SDK** — `dart:js_interop` 기반 직접 연동

### Backend (담당: 최민수)
- **FastAPI** (Python 3.12) — REST API 서버
- **PostgreSQL 17 + PostGIS 3.4** — 공간 데이터베이스
- **Redis 7** — 캐싱 + ARQ 비동기 큐
- **Docker Compose** — 컨테이너 기반 개발/배포 환경
- **Nginx + Cloudflare** — 리버스 프록시 + CDN

### ML (담당: 곽현우)
- **XGBoost / RandomForest / LightGBM** — 창업 점수 예측
- **SHAP** — 점수 요인 기여도 시각화
- **LLM API** — 자연어 보고서 자동 생성

### DB (담당: 김성환/김기범)
- **PostgreSQL + PostGIS** — ERD 설계 및 공간 데이터 관리

---

## 📁 프로젝트 구조 (Frontend)

```
surbi_web/
├── docs/             # 프로젝트 문서 (아래 '문서' 섹션 참고)
└── lib/
    ├── app/          # 라우팅, 테마
    ├── models/       # 데이터 모델
    ├── services/     # API 통신, Firebase Auth, 카카오맵 interop
    ├── providers/    # Riverpod 상태 관리
    ├── views/        # 화면 (페이지 단위)
    └── widgets/      # 재사용 컴포넌트
        └── common/   # 로딩 / 에러 / 빈화면 / 공용 AppBar · Card
```

---

## 📚 문서

| 문서 | 내용 |
|------|------|
| [FE_WORKFLOW.md](docs/FE_WORKFLOW.md) | **현재 진행 상황 + 다음 할 일** — EPIC · Task 단위 개발 계획 |
| [FE_DEVLOG.md](docs/FE_DEVLOG.md) | **개발 일지** — 날짜별 작업 기록, 트러블슈팅, 프로젝트 상시 규칙 |
| [API_명세_협의_요청사항.md](docs/API_명세_협의_요청사항.md) | 백엔드 API 명세 협의 요청 목록 (FE → BE) |
| [BRANCH_STRATEGY.md](docs/BRANCH_STRATEGY.md) | Git 브랜치 운영 전략 |
| [DESIGN.md](docs/DESIGN.md) | 디자인 가이드 (브랜드 컬러, 컴포넌트 규칙) |

> 💡 문서는 **시제(時制)** 기준으로 나눠 관리합니다.
> `FE_WORKFLOW` = 현재·미래(덮어씀) / `FE_DEVLOG` = 과거(append만)

---

## 🚀 로컬 실행 방법

### 사전 요구사항
- Flutter 3.0 이상
- Chrome 브라우저

### 실행

```bash
# 의존성 설치
flutter pub get

# 웹 실행 (포트 고정 — 카카오맵 SDK 도메인 등록 때문)
flutter run -d chrome --web-port=5000
```

> ⚠️ 카카오맵 JavaScript SDK는 **등록된 도메인에서만 동작**하므로 포트를 고정해야 합니다.

---

## 📊 데이터 소스

| 분류 | 데이터 | 출처 |
|------|--------|------|
| 상권정보 | 소상공인시장진흥공단 상가(상권)정보 | data.go.kr |
| 거주인구 | 지역별(행정동) 인구수 | data.go.kr |
| 상권매출 | 서울-상권분석서비스(상권-추정매출) | data.go.kr |
| 폐업률 | 서울-상권분석서비스(상권-상권변화지표) | data.go.kr |
| 지하철 | 서울-역별 승하차 인구 | data.seoul.go.kr |
| 임대료 | 지역별 임대료(소규모 상가) | data.go.kr |
| 정책 지원 | 정부·공공기관 지원사업 정보 | 각 기관 공개 API |

---

## 👥 팀원

| 이름 | 역할 |
|------|------|
| 최민수 | Backend · DevOps · 총괄 |
| 김성환/김기범 | Backend · DB |
| 곽현우 | ML · Machine Learning |
| 사공민규 | Frontend |

---

## 📝 개발 현황

> 상세 진행 상황은 **[FE_WORKFLOW.md](docs/FE_WORKFLOW.md)** 참고

| EPIC | 내용 | 진행 | 상태 |
|------|------|------|------|
| 1 | 환경 구축 & 기반 설계 | 7 / 7 | ✅ 완료 |
| 2 | 인증 & 사용자 관리 | 1 / 5 | 🔄 진행 중 |
| 3 | Step 1~4 핵심 화면 개발 | 7 / 7 | ✅ 완료 |
| 4 | 백엔드 API 연동 | 0 / 6 | 🔄 명세 협의 중 |
| 5 | 품질 검증 & 배포 | 0 / 4 | ⏳ 대기 |

---

## 📄 라이선스
MIT License © 2026 Surbi Team
