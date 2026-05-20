# 사용자 풀이 이력 CSV export

[tool/export_sessions.js](export_sessions.js) 는 Firestore 의 `user_answers/{uid}/sessions/{sid}` 전체를 평면화한 CSV 한 파일로 내보낸다. 본인 PC 의 엑셀/Sheets 에서 피벗테이블로 분석하는 용도.

## CSV 컬럼

한 행 = 한 사용자의 한 문제 답변. 한 세션이 40문제면 40행이 생긴다.

| 컬럼 | 의미 | 예 |
|---|---|---|
| `uid` | Firebase Auth 익명 사용자 ID | `eFnBqe313rN4...` |
| `display_name` | 동의 시 입력한 이름 | `원석` |
| `session_id` | 세션 문서 ID (한 풀이) | `yV0IvC6Rh9OQ...` |
| `finished_at` | 세션 종료 시각(ISO 8601 UTC) | `2026-05-19T05:16:57.000Z` |
| `license_kind` | 모의고사 면허 종류, 연습은 빈값 | `class1_large` 등 |
| `score` | 맞힌 문항 수 | `27` |
| `total` | 출제 문항 수 | `40` |
| `question_id` | 문제 ID | `621` |
| `selected` | 선택한 보기 인덱스(0-based, `\|` 구분) | `2` 또는 `0\|3` |
| `correct` | 정답 여부 | `TRUE` / `FALSE` |

## 실행 방법 A — Cloud Shell (권장, 인증 자동)

1. https://console.firebase.google.com/project/quiz-ace9a/firestore 접속 후 우측 상단 `>_` 아이콘으로 **Cloud Shell** 열기
2. 이 저장소를 clone (또는 스크립트를 그대로 붙여넣어도 됨):

   ```bash
   git clone https://github.com/smilecws/quiz.git
   cd quiz/tool
   ```

3. 의존성 설치 + 실행:

   ```bash
   npm install firebase-admin
   node export_sessions.js > sessions.csv
   ```

   - stdout 으로 CSV, stderr 로 진행 로그(`fetched N session docs`, `wrote N item rows`).
   - 인증은 Application Default Credentials 가 자동으로 잡힘(별도 키 발급 불필요).

4. 결과 파일 다운로드:

   ```bash
   cloudshell download sessions.csv
   ```

   브라우저에 다운로드 창이 뜬다.

## 실행 방법 B — 본인 PC (반복 실행 시 편리)

1. **서비스 계정 키 발급** (1회):
   - https://console.firebase.google.com/project/quiz-ace9a/settings/serviceaccounts/adminsdk
   - **"새 비공개 키 생성"** → JSON 파일 다운로드 → 본인 PC 의 안전한 곳에 저장 (예: `~/.gcp/quiz-ace9a-adminsdk.json`)
   - **이 파일은 절대 Git 에 커밋하지 말 것** (이 저장소 `.gitignore` 에 `*-adminsdk-*.json` 추가 권장)

2. PowerShell 에서:

   ```powershell
   cd C:\Users\smile\Desktop\quiz_app\tool
   npm install firebase-admin
   $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\quiz-ace9a-adminsdk.json"
   node export_sessions.js > sessions.csv
   ```

3. `sessions.csv` 가 같은 폴더에 생성된다.

## 엑셀에서 피벗테이블 분석

`sessions.csv` 를 엑셀로 열고 (`데이터 > 텍스트/CSV 가져오기` 권장, UTF-8 인코딩) → 표 영역 선택 → **삽입 > 피벗테이블**.

### 자주 쓰는 분석 예시

**1) 문제별 오답률**
- 행: `question_id`
- 값: `correct` → 값 필드 설정에서 "평균"
- 표시 형식: 백분율
- **오답률 = 1 − 평균(correct)**
- 정렬: 평균(correct) 오름차순 = 어려운 문제 순

**2) 한 문제의 보기별 선택 분포**
- 필터: `question_id` = 분석할 ID
- 행: `selected`
- 값: `session_id` → "개수"
- 결과: 보기 인덱스(0,1,2,3...)별 선택 횟수

**3) 사용자별 활동량 / 평균 점수**
- 행: `display_name`
- 값1: `session_id` → "고유 개수" → 세션 수
- 값2: `score` → "평균"

**4) 일자별 풀이 수**
- 행: `finished_at` → 그룹화로 "일" 단위 묶기
- 값: `session_id` → "고유 개수"

**5) 카테고리별 평균 점수** (선택)
- `question_id` 와 카테고리 매핑 시트(`assets/question_subcategory.json`) 를 VLOOKUP 으로 결합한 뒤 분석

## 성능 / 비용 메모

- `collectionGroup('sessions').get()` 은 **읽기 = 세션 doc 수**. 1만 세션이면 10K read.
- Firebase Spark 무료 한도: 50K reads / day. 매일 export 해도 무료 한도 안.
- 더 큰 양이면 다음 두 가지 검토:
  1. **점진적 export**: `finished_at > 마지막_export_시각` 으로 필터. 이 경우 collection group 인덱스 필요 (첫 실행 시 Firestore 가 "Create index" 링크를 stderr 에 띄움 — 한 번 클릭으로 생성).
  2. **BigQuery 연동**: Firebase Extensions "Stream Firestore to BigQuery" 로 자동 sync → SQL 로 임의 집계.

## 데이터 정리(테스트 데이터 삭제)는

[../RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md) 참고.
