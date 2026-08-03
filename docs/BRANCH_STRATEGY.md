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

| 작업 성격 | 방식 | 이유 |
|------|------|------|
| 자잘한 수정 · 버그픽스 · 소규모 기능 추가 | `main` 직접 작업 | 1인 개발 체제 + 팀 회의에서 진행상황만 공유하는 구조로, 승인 절차 없이도 문제 없음 (2026-08-03 팀장 확인) |
| 화면 전체 리팩터링 · 외부 서비스 신규 연동 · 실험적 시도(디자인 A/B 등) | `feature` 브랜치 작업 후 `main`에 Merge | 시행착오가 많은 작업은 롤백 지점 확보 목적으로 여전히 브랜치 권장 |

> 💡 **2026-08-03 변경 이력**: 기존엔 "EPIC 1만 main 직접, EPIC 2~5는 무조건 브랜치" 기준이었으나,
> 실제로는 EPIC 2(Task 2-1 Firebase)조차 브랜치에 갇힌 채 2주 이상 병합이 밀리는 문제가 발생함.
> 협업 충돌 위험이 없는 1인 체제임을 감안해, **EPIC 단위가 아니라 작업 성격(규모·되돌릴 위험) 기준**으로
> 브랜치 여부를 판단하는 방식으로 전환.

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
| `feature/frontend-step1-ui-navygold` | 컬러 실험(폐기, 기록 보존용으로 유지) — 브랜치 자체가 하나의 의사결정 기록이 될 수 있음을 보여주는 사례 |

## 작업 흐름

```
1. GitHub Desktop에서 main 기준으로 새 feature 브랜치 생성
2. feature 브랜치에서 코딩 → Commit → Push (여러 번 반복 가능)
3. 기능 단위 작업 완료 시 main으로 브랜치 전환 후 Merge
4. main Push
```

> 💡 필요 시(히스토리 기록·포트폴리오 목적) 3번 대신 GitHub에서 PR 생성 후 즉시 merge 가능.
> 리뷰어 승인 대기 없이, 정상 작동만 확인되면 곧바로 진행.


> 💡 본 프로젝트는 1인 Frontend 개발 체제로, Pull Request 승인 절차 없이
> `main` ↔ `feature` 2단계 구조로 운영합니다.
> **PR 생성 자체도 필수가 아닌 선택** — 히스토리 가독성·포트폴리오 목적으로 필요하다고
> 판단될 때만 GitHub에서 PR을 열고, 정상 작동 확인되면 리뷰 대기 없이 바로 merge합니다.
> (단순 작업은 GitHub Desktop 로컬 merge로 충분, PR 없이 진행 가능)

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

*최종 수정: 2026-08-03 · 작성자: 사공민규*
