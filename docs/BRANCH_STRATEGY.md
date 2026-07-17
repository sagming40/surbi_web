# 브랜치 전략 (Branch Strategy)

> Surbi Frontend 개발 시 따르는 Git 브랜치 운영 규칙입니다.

## 브랜치 구조

```
main                             배포 가능한 안정 버전
 └─ feature/frontend-{기능명}     개인 작업 브랜치
```

| 브랜치 | 용도 | 직접 작업 여부 |
|--------|------|----------------|
| `main` | 항상 정상 작동하는 상태 유지 | ❌ (Merge로만 반영) |
| `feature/frontend-*` | 실제 코드 작성 공간 | ✅ |

## 단계별 적용 시점

| 단계 | 방식 | 이유 |
|------|------|------|
| EPIC 1 (환경 구축) | `main` 직접 작업 | 초기 세팅 단계로 되돌릴 위험이 낮음 |
| EPIC 2~5 (Firebase, 화면, API, 배포) | `feature` 브랜치 작업 후 `main`에 Merge | 외부 서비스 연동, 화면 개발 시 시행착오가 많아 안전한 작업 공간 필요 |

## 브랜치 이름 규칙

```
feature/frontend-{기능 또는 EPIC 단위}
```

**예시**

| 브랜치명 | 작업 내용 |
|----------|-----------|
| `feature/frontend-epic2-auth` | Firebase 인증 (Task 2-1 ~ 2-5) |
| `feature/frontend-step1-ui` | Step 1 화면 (Task 3-1) |
| `feature/frontend-api-integration` | 백엔드 API 연동 (EPIC 4) |

## 작업 흐름

```
1. GitHub Desktop에서 main 기준으로 새 feature 브랜치 생성
2. feature 브랜치에서 코딩 → Commit → Push (여러 번 반복 가능)
3. 기능 단위 작업 완료 시 main으로 브랜치 전환 후 Merge
4. main Push
```

> 💡 본 프로젝트는 1인 Frontend 개발 체제로, Pull Request 및 팀 리뷰 절차 없이
> `main` ↔ `feature` 2단계 구조로 운영합니다.

## 커밋 메시지 컨벤션

```
<type>: <설명> (Task 번호)
```

| type | 의미 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 작업 |
| `refactor` | 코드 구조 개선 (기능 변화 없음) |
| `style` | 코드 포맷팅, 세미콜론 등 |

**예시**

```
feat: Riverpod 상태관리 세팅 (Task 1-3)
fix: ResponsiveLayout child 타입 에러 수정
docs: 브랜치 전략 문서 작성 (Task 1-6)
```

---

*최종 수정: 2026-06-20 · 작성자: 사공민규*
