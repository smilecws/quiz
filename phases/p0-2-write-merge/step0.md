# Step 0: aggregate-script-rewrite

## 읽어야 할 파일

- `/CLAUDE.md` — 프로젝트 개요, Firebase 구조
- `/RELEASE_CHECKLIST.md` — "P0-2" 섹션 (옵션 C: write 통합 설계)
- `/tool/aggregate_stats.js` — 현재 집계 스크립트 (`question_stats` 기반)
- `/lib/services/user_answer_log_service.dart` — `user_answers` 세션 문서 스키마 (`items` 구조)
- `/lib/services/global_answer_stats_service.dart` — `aggregates.json` 스키마

## 배경

P0-2 write 통합. 현재 클라이언트는 세션 종료 시 `question_stats` 1,000문서에 직접 write 한다(세션당 40 write). 이를 없애고, 통계 집계를 GitHub Actions 가 `user_answers` 세션 로그로부터 수행하도록 바꾼다.

`user_answers/{uid}/sessions/{sid}` 문서에는 이미 세션의 모든 답안이 `items` 배열로 들어 있다 — 각 항목은 `{ q: 문제ID(정수), sel: 선택 인덱스 배열(정수[]), correct: 정답 여부(불리언) }`. 즉 `user_answers` 가 원천 데이터이고 `question_stats` 는 거기서 계산 가능한 파생물이다.

이 step 은 `aggregate_stats.js` 의 집계 소스를 `question_stats` → `user_answers` 로 바꾼다. (클라이언트 코드 변경은 Step 1.)

## 작업

`tool/aggregate_stats.js` 를 수정한다.

- 현재 `fetchQuestionStats()` 는 `question_stats` 컬렉션을 읽는다. 이를 `user_answers` 의 **모든 `uid`의 모든 `sessions` 문서**를 읽어 집계하도록 바꾼다.
- 집계 로직: 모든 세션의 모든 `items` 를 순회하며, 문항 `q` 별로 — `attempts += 1`, `correct === true` 면 `correct += 1`, `sel` 의 각 인덱스에 대해 `option_counts[idx] += 1`.
- 그 결과로 문항별 `{ attempts, correct, option_counts }` 맵을 만든다 (기존 `question_stats` 와 동일한 형태).
- `aggregates.json` 에 **`all_questions`** 필드를 추가한다 — `{ "문제ID": { attempts, correct, wrong_rate } }` 전체 문항. (Step 1 의 클라이언트 `loadStat` 이 이 데이터를 쓴다.)
- `hardest_top10` · `subcategory` 는 위 집계 맵을 기반으로 기존과 동일하게 생성한다.
- `full_report.json` · `report.md` 의 형식은 그대로 둔다. `total_users` · `total_sessions` 를 구하는 `fetchUserCounts()` 도 그대로 둔다.

**주의**: `user_answers` 의 모든 `sessions` 문서를 read 하므로 GitHub Actions 의 read 비용이 늘어난다(기존엔 `count()` aggregation 만 사용). 이는 RELEASE_CHECKLIST.md P0-2 에 명시된 의도된 트레이드오프다 — 사용자가 많아지면 cron 주기를 늘려 대응한다.

## Acceptance Criteria

```bash
node --check tool/aggregate_stats.js
```

- `node --check` 가 문법 오류 없이 통과해야 한다.
- 실제 Firestore 접속 실행은 서비스 계정 키가 필요하므로 AC 에 포함하지 않는다.

## 검증 절차

1. `node --check tool/aggregate_stats.js` 실행.
2. 집계 소스가 `user_answers` 로 바뀌었고 `aggregates.json` 에 `all_questions` 가 추가됐는지 확인.
3. 결과에 따라 `phases/p0-2-write-merge/index.json` 의 step 0 을 업데이트한다 (completed + summary / error).

## 금지사항

- 앱 코드(`lib/`)를 수정하지 마라. 이유: 클라이언트 변경은 Step 1 의 작업이다.
- `.github/workflows/` 를 수정하지 마라. 이유: 워크플로는 P0-4 에서 이미 완성됐고 이 phase 범위가 아니다.
- `full_report.json` · `report.md` 의 출력 형식을 바꾸지 마라. 이유: 외부 공유용으로 이미 확정된 포맷이다.
- 기존 테스트를 깨뜨리지 마라.
