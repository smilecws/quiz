# Step 1: client-write-removal

## 읽어야 할 파일

- `/CLAUDE.md` — 레이어 규칙, 글로벌 통계 I/O 규칙
- `/lib/services/global_answer_stats_service.dart` — 현재 `applySessionResults`(write) / `loadStat`(단건 read) / `loadAggregateStats`(집계 read)
- `/lib/screens/quiz_screen.dart` — `applySessionResults` 호출처
- `/lib/screens/question_detail_screen.dart`, `/lib/screens/result_screen.dart` — `loadStat` 호출처

## 배경

P0-2 write 통합. 클라이언트가 `question_stats` 에 직접 write 하던 것을 제거한다. Step 0 에서 `aggregate_stats.js` 가 `user_answers` 로부터 통계를 집계하므로, 클라이언트는 `question_stats` 를 더 이상 읽지도 쓰지도 않는다.

`aggregates.json` 에는 Step 0 에서 `all_questions`(`{ "문제ID": { attempts, correct, wrong_rate } }`) 가 추가됐다.

## 작업

### 1. `lib/services/global_answer_stats_service.dart`

- `applySessionResults` 메서드를 제거한다 (`question_stats` batch write).
- `GlobalAggregateStats` 에 `allQuestions` 필드를 추가한다 — `aggregates.json` 의 `all_questions` 를 파싱해 담는다 (문항 ID → 통계 맵).
- `loadStat(int questionId)` 를 Firestore 단건 조회 대신 `loadAggregateStats()` 의 `allQuestions` 에서 조회하도록 바꾼다.
  - 시그니처(`Future<GlobalQuestionStat?> loadStat(int)`)는 **유지**한다 — 호출부(`question_detail_screen`, `result_screen`)를 깨지 않기 위해서다.
  - `all_questions` 에 해당 ID가 없으면 `null` 을 반환한다.
- `question_stats` 단건 조회에만 쓰이던 코드(`_collection` 상수, `_parseDoc`, 관련 `cloud_firestore` 사용)를 정리한다. `loadAggregateStats` 의 HTTP fetch 경로는 그대로 유지한다.

### 2. `lib/screens/quiz_screen.dart`

- `GlobalAnswerStatsService.applySessionResults(...)` 호출 2곳(약 142행·392행)을 제거한다.
- `UserAnswerStatsService.applySessionResults` 와 `WrongNoteService.applySessionResults` 는 **로컬 통계**이므로 그대로 둔다. 혼동하지 마라.
- `UserAnswerLogService.saveSession` 호출은 **반드시 유지**한다 — `user_answers` 에 세션당 1 write 하는 이 기록이 P0-2 의 핵심 데이터원이다.

레이어 규칙(`CLAUDE.md`): `services/` 는 `material.dart` import 금지.

## Acceptance Criteria

```bash
flutter analyze
flutter test
```

- 둘 다 통과해야 한다.

## 검증 절차

1. `flutter analyze` 와 `flutter test` 를 실행한다.
2. `aggregates.json` 의 `all_questions` 는 워크플로 재실행 전이라 아직 없을 수 있다. 그 경우 `loadStat` 이 `null` 을 반환하는 게 정상이다.
3. 결과에 따라 `phases/p0-2-write-merge/index.json` 의 step 1 을 업데이트한다.

## 금지사항

- `lib/services/user_answer_log_service.dart` 를 수정하지 마라. 이유: `user_answers` write 는 P0-2 이후에도 유지되는 핵심 동작이다.
- `tool/`, `.github/workflows/` 를 수정하지 마라. 이유: Step 0 의 산출물이며 이 step 범위가 아니다.
- `loadStat` 의 시그니처를 바꾸지 마라. 이유: 호출부를 깨뜨린다.
- 기존 테스트를 깨뜨리지 마라.
