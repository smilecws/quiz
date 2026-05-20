# Step 3: docs-update

## 읽어야 할 파일

- `/CLAUDE.md` — 갱신 대상. `question_stats` 관련 서술이 P0-2 이후 부정확해진다.
- `/docs/ARCHITECTURE.md` — 갱신 대상.
- `/docs/ADR.md` — 갱신 대상.
- `/lib/services/global_answer_stats_service.dart` — Step 1 변경 후 상태 확인
- `/RELEASE_CHECKLIST.md` — "P0-2" 섹션 (write 통합 설계)

## 배경

P0-2 write 통합으로 `question_stats` 컬렉션이 폐기됐다. 클라이언트는 `user_answers` 에만 세션당 1 write 하고, 통계는 GitHub Actions 가 `user_answers` 로부터 집계한다. 이 변경을 문서에 반영한다.

## 작업

### 1. `docs/ARCHITECTURE.md`

- "데이터 흐름" 절에서 글로벌 통계 **write** 경로를 갱신한다: 세션 종료 시 `question_stats` 40 write 가 아니라 `user_answers` 세션 로그 1 write 만 한다.
- `question_stats` 폐기를 반영한다. `aggregate_stats.js` 의 집계 소스가 `user_answers` 임을 명시한다.
- `global_answer_stats_service` 설명에서 `applySessionResults`(제거됨) 관련 서술을 정정한다.

### 2. `docs/ADR.md`

- ADR-011(Firestore 로 글로벌 통계·풀이 이력 기록) 을 갱신하거나, write 통합에 대한 새 ADR 을 추가한다.
- 핵심: `question_stats` 직접 write 폐기 → `user_answers` 단일 write + 서버사이드 집계. 결정 이유(Firestore 무료 한도, 세션당 41→1 write), 트레이드오프(집계 시 `user_answers` 전체 read).

### 3. `CLAUDE.md`

- `question_stats` 관련 서술을 현재 상태에 맞게 정정한다. 특히 글로벌 통계 데이터 모델을 설명하는 CRITICAL 항목 — `question_stats/{questionId}` 문서 구조를 언급하는 부분 — 을 `question_stats` 폐기와 `user_answers` 기반 집계에 맞게 고친다.
- **다른 규칙·항목은 절대 건드리지 마라.** `question_stats` 와 직접 관련된 서술만 최소한으로 정정한다.

## Acceptance Criteria

```bash
python scripts/execute.py validate p0-2-write-merge
```

- placeholder 검사를 통과해야 한다. 환경변수 `PYTHONUTF8=1` 이 필요할 수 있다 (Windows).
- 문서에 `{한글...}` 형태의 미완성 placeholder 를 남기지 마라.

## 검증 절차

1. 위 `validate` 를 실행한다.
2. `ARCHITECTURE.md` · `ADR.md` · `CLAUDE.md` 에서 `question_stats` 관련 서술이 폐기 후 상태와 일치하는지 확인한다.
3. 결과에 따라 `phases/p0-2-write-merge/index.json` 의 step 3 을 업데이트한다.

## 금지사항

- 코드(`lib/`, `tool/`, `.github/`, `firestore.rules`)를 수정하지 마라. 이유: 이 step 은 문서 갱신만 한다.
- `CLAUDE.md` 에서 `question_stats` 와 무관한 규칙을 건드리지 마라. 이유: `CLAUDE.md` 는 harness 가드레일이며 다른 규칙 변경은 이 phase 범위 밖이다.
- 문서에 `{한글}` 형태의 placeholder 를 남기지 마라. 이유: harness 가드레일 검증이 막아 다음 실행이 중단된다.
