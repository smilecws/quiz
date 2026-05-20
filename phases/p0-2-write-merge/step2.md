# Step 2: firestore-rules

## 읽어야 할 파일

- `/CLAUDE.md` — Firestore 보안 규칙 관련 규칙
- `/firestore.rules` — 현재 보안 규칙

## 배경

P0-2 write 통합으로 클라이언트는 더 이상 `question_stats` 컬렉션을 읽거나 쓰지 않는다 (Step 0·1 완료). 따라서 `firestore.rules` 의 `question_stats` 규칙은 불필요하다.

## 작업

`firestore.rules` 를 수정한다.

- `question_stats` 에 대한 `match` 블록을 제거한다.
- `user_answers/{uid}/sessions/{sid}` 에 대한 `match` 블록은 **그대로 유지**한다 — 클라이언트가 세션 로그를 계속 write 하기 때문이다.
- 규칙 파일의 다른 구조(`rules_version`, `service cloud.firestore`, `match /databases/...`)는 건드리지 마라.

## Acceptance Criteria

- `firestore.rules` 에 `question_stats` 라는 문자열이 더 이상 존재하지 않아야 한다.
- `user_answers` 에 대한 `match` 블록은 그대로 남아 있어야 한다.

## 검증 절차

1. `firestore.rules` 를 열어 `question_stats` 블록이 제거됐고 `user_answers` 블록이 유지됐는지 확인한다.
2. 결과에 따라 `phases/p0-2-write-merge/index.json` 의 step 2 를 업데이트한다.

## 금지사항

- `user_answers` match 블록을 수정·삭제하지 마라. 이유: 클라이언트가 세션 로그를 계속 write 한다.
- 앱 코드(`lib/`), `tool/`, `.github/` 를 수정하지 마라. 이유: 이 step 은 `firestore.rules` 만 다룬다.
- `firebase deploy` 를 실행하지 마라. 이유: 규칙 배포는 사용자(운영자)가 배포 시점에 직접 한다.
