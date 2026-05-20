# 배포 전 체크리스트

테스트 단계에서 쌓인 Firestore 데이터와 익명 사용자를 정리한 뒤 실제 사용자에게 공개하기 위한 절차.

## 1. 테스트 통계 데이터 삭제 (Firestore)

PowerShell 에서 한 번에:

```powershell
firebase firestore:delete question_stats --recursive --project quiz-ace9a
firebase firestore:delete user_answers --recursive --project quiz-ace9a
```

- `--recursive` 가 핵심. `user_answers/{uid}/sessions/...` 같은 서브컬렉션까지 삭제된다.
- 보안 규칙은 `allow delete: if false` 이지만 CLI/콘솔은 owner 권한이라 우회된다.
- 자동화하려면 `--force` 추가. 안 붙이면 `Are you sure? (y/N)` 프롬프트가 뜬다.

## 2. 테스트용 익명 사용자 삭제 (Firebase Auth)

https://console.firebase.google.com/project/quiz-ace9a/authentication/users

- 각 사용자 행 우측 `⋮` → **"사용자 삭제"**.
- 인원이 적을 땐 손으로. 많아지면 Admin SDK 스크립트 필요.

## 3. (선택) 본인 브라우저 사이트 데이터 삭제

테스터 본인 기기에 `shared_preferences` 로 남은 동의·오답노트·즐겨찾기·모의고사 기록을 깨끗이 비우고 "처음 켜는 사용자" 시점을 재현하고 싶을 때.

- 크롬: 자물쇠 아이콘 → "사이트 정보" → "쿠키 및 사이트 데이터" → 삭제
- 또는 시크릿창으로 새로 진입

## 4. 최신 코드 배포

```powershell
git push origin main
```

- `main` 푸시 → `.github/workflows/deploy_github_pages.yml` 자동 실행 → 약 2-3분 후 https://smilecws.github.io/quiz/ 에 반영.
- Firestore 보안 규칙(`firestore.rules`)을 수정했다면 별도로:

  ```powershell
  firebase deploy --only firestore:rules
  ```

## 5. 배포 직후 검증

1. https://smilecws.github.io/quiz/ 에서 시크릿창으로 새 사용자처럼 진입
2. 동의 화면 → 이름 입력 → 모의고사 1세션 끝까지 풀이
3. Firebase 콘솔 확인:
   - Authentication > Users — 새 익명 사용자 1명 생성, displayName 에 입력 이름 반영
   - Firestore > `user_answers/{uid}/sessions/...` — 세션 문서 생성, `items` 정상
   - Firestore > `question_stats/{문제ID}` — 풀이한 문제마다 카운터 1씩 증가
4. F12 Console 에 빨간 에러 없는지

## 6. 첫 진짜 사용자 받기

알림 보내기 전 마지막 확인:
- [ ] question_stats 비어있음 (테스트 데이터 0)
- [ ] user_answers 비어있음
- [ ] Auth Users 에 testers 없음
- [ ] 시크릿창 검증 통과

---

## 대규모 배포 대비 점검 (월 500~5,000명 시나리오)

블로그/커뮤니티 공유로 사용자가 늘기 전에 점검할 항목. 우선순위 순.

### 🔴 P0-1. Firestore 보안 규칙 강화 + App Check

**현재 상태**
- `firestore.rules:23` `question_stats` write 검증이 `request.auth != null` 한 줄뿐. 필드/값 검증 없음.
- 익명 사용자가 `option_counts.999`처럼 임의 키를 쓰거나 `increment(-1000000)` 같은 음수 카운터 조작 가능.
- App Check 미적용 → 봇이 REST API로 직접 익명 로그인 + write 가능.

**조치**
- [ ] Firebase Console → App Check → Web 앱에 reCAPTCHA v3 등록
- [ ] Android/iOS는 Play Integrity / DeviceCheck 등록
- [ ] `pubspec.yaml`에 `firebase_app_check` 추가
- [ ] `lib/main.dart` 초기화부에 `FirebaseAppCheck.instance.activate(...)` 추가
- [ ] `firestore.rules`에 `request.resource.data.keys().hasOnly([...])` 필드 화이트리스트 추가
- [ ] `firebase deploy --only firestore:rules`로 재배포
- [ ] Emulator로 악성 페이로드 거부 단위 테스트

### 🔴 P0-2. Firestore write 한도 (세션당 41 write)

**현재 상태**
- 세션 종료 시: `question_stats/{qid}` × 40 + `user_answers/{uid}/sessions/{auto_id}` × 1 = 41 write
- Spark 일일 한도 20,000 → **하루 활동 사용자 488명에서 한도 도달**
- 월 5,000명 시나리오에서 일일 활동 500명 가정하면 한도 초과

**옵션 A: Blaze 전환 (권장)**
- [ ] Firebase 콘솔에서 결제 계정 연결
- [ ] 월 예산 알림 $5/$10 설정
- 예상 비용: 5,000명/월 × 41 write = 205,000 write → 약 $0.37/월
- 코드 변경 불필요

**옵션 B: Spark 유지 + write 절감**
- [ ] `lib/services/global_answer_stats_service.dart:61-99`에서 샘플링 게이트 추가 (`Random().nextDouble() < 0.3`)
- 정확도는 떨어지지만 한도 내 운영 가능

### 🔴 P0-3. 저작권/라이선스 정비

**현재 상태**
- ✅ 도로교통공단에 학과시험 자료 사용 문의 → **재배포 허락 받음 (2026-05-20)**. 핵심 리스크(무단 재배포) 해소.
- `LICENSE` 파일 없음
- `README.md` Flutter 템플릿 그대로
- 출처는 `lib/screens/exam_guide_screen.dart:250,384`의 UI 일부에만 표기
- 1,000문항·296개 이미지·35개 동영상·실격사항 데이터가 도로교통공단 자료

**조치**
- [x] ~~한국도로교통공단에 학과시험 자료 재배포 가능 여부 문의~~ → 사용 허락 받음 (2026-05-20)
- [ ] 공단 허락 내역(허락 일자·범위·담당부서/근거)을 `LICENSE_DATA.md`에 기록 — 추후 저작권 문의 대응 근거
- [x] `LICENSE` 추가 (MIT, Copyright 2026 josh)
- [x] `README.md` 갱신: 프로젝트 소개, 데이터 출처(공단 허락 명시), 라이선스 분리 명시
- [ ] `assets/question_*.json` 루트에 `_source`, `_license` 필드 추가

### 🔴 P0-4. Firestore read 한도 대응 (통계 화면 진입당 1,000 read)

**현재 상태**
- `StatsScreen` 진입 시 `GlobalAnswerStatsService.loadAllStats()` 호출 (`stats_screen.dart:53`)
- 내부에서 `collection('question_stats').get()` 실행 → **1,000 문서 = 1,000 read** (`global_answer_stats_service.dart:155-156`)
- 5분 메모리 캐시 있으나 앱 재시작 시 증발
- write보다 read 부담이 훨씬 큼

**예상 부하**

| 시나리오 | 일일 read |
|---------|----------|
| 월 500명, 1인 3회 진입 | **50,000** ⚠️ Spark 한도 도달 |
| 월 5,000명, 1인 3회 진입 | **500,000** (Spark 10배 초과) |
| 월 5,000명 + 열심 사용 (10회/월) | **1,600,000** |

Blaze 비용 ($0.06/100K read): 월 $0.90 ~ $30. write 비용보다 10~80배 큼.

**해결: 영구 캐시 + 외부 집계 (GitHub Actions)**

#### Step 1. SharedPreferences 영구 캐시 (단기 효과)
- [ ] `lib/services/global_answer_stats_service.dart`에 SharedPreferences TTL 캐시 추가 (1시간)
- [ ] 우선 캐시 표시 → 백그라운드 fetch → 성공 시 갱신 패턴
- [ ] UI에 "최근 업데이트: N시간 전" 표시
- 효과: 사용자당 일일 1~2회 read만 발생, **빈도 80~90% 절감**

#### Step 2. 외부 집계 도입 — GitHub Actions cron + 별도 브랜치 (근본 해결)

**아키텍처**
```
GitHub Actions (매 4시간 cron)
  ↓ Firebase Admin SDK
question_stats 전체 fetch (1,000 read/일 × 6회 = 6,000 read/일)
  ↓ 집계 (Top 10 + 소카테고리)
data-aggregates 브랜치에 aggregates.json force commit
  ↓
클라이언트가 raw.githubusercontent.com에서 HTTP fetch
  ↓
SharedPreferences 영구 캐시 갱신
```

**구체적 조치**
- [ ] Firebase Console → 프로젝트 설정 → 서비스 계정 → 새 비공개 키 생성 (JSON)
- [ ] GitHub 저장소 Settings → Secrets → `FIREBASE_SERVICE_ACCOUNT` 추가
- [ ] `.github/workflows/aggregate_stats.yml` 작성:
  - `cron: '0 */4 * * *'` (매 4시간)
  - Node.js + `firebase-admin` 패키지로 `question_stats` 전체 fetch
  - Top 10 hardest + 소카테고리별 합계 집계
  - `data-aggregates` 브랜치에 `aggregates.json` force push (단일 commit 유지)
- [ ] `tool/aggregate_stats.js` (또는 `.dart`) 집계 스크립트 작성
- [ ] `data-aggregates` 브랜치 초기화 (`git checkout --orphan data-aggregates`)
- [ ] Flutter 클라이언트 변경:
  - [ ] `pubspec.yaml`에 `http` 패키지 추가 (이미 있을 수 있음)
  - [ ] `lib/services/global_answer_stats_service.dart`의 `_fetchAll()` 수정:
    - 1차: `https://raw.githubusercontent.com/smilecws/quiz/data-aggregates/aggregates.json` HTTP GET
    - 2차 (폴백): SharedPreferences 캐시 사용
    - 실패 시 빈 맵 반환 (현재 동작 유지)
  - [ ] aggregates.json 스키마: `{ "updated_at": "...", "hardest_top10": [...], "subcategory": {...} }`
  - [ ] StatsScreen이 새 스키마에 맞춰 작동하는지 확인

**효과**: 클라이언트 Firebase read **0**, GitHub Actions이 일 6,000 read만 발생 (Spark 한도의 12%, 안전).

**신선도**: 4시간 (실시간 불필요, 전체 사용자 통계는 추세만 보면 됨)

**왜 `assets/` commit 방식이 아닌 별도 브랜치인가**
- Flutter Web의 `flutter_service_worker.js`가 정적 자산을 precache → assets에 넣으면 사용자가 service worker 갱신 전까지 옛 데이터를 봄 (실제 신선도 며칠~몇주)
- 별도 브랜치는 클라이언트가 직접 HTTP fetch → service worker 안 타고 즉시 반영
- main 브랜치 history 청결 유지, Flutter 재빌드 0회

**영향받는 파일**: `lib/services/global_answer_stats_service.dart`, `lib/screens/stats_screen.dart` (UI 표시), `.github/workflows/aggregate_stats.yml` (신규), `tool/aggregate_stats.js` (신규)

**검증**:
- GitHub Actions 수동 트리거 → `data-aggregates` 브랜치에 aggregates.json 생성 확인
- 브라우저에서 `https://raw.githubusercontent.com/.../data-aggregates/aggregates.json` 직접 열어 응답 확인
- Flutter 앱에서 통계 화면 진입 → DevTools Network 탭에서 Firestore 요청 0건, raw.githubusercontent.com 요청 1건 확인

#### Step 3. 마케팅/공유용 리포트 동시 생성

같은 GitHub Actions 워크플로우에서 통계 화면용 `aggregates.json` 외에 외부 공유용 리포트 2개를 추가로 생성한다. Firestore 추가 fetch 없이 같은 데이터로 산출물만 다르게 출력.

**산출물** (모두 `data-aggregates` 브랜치)
- `aggregates.json` — 클라이언트 통계 화면용 (가벼움, Step 2와 동일)
- `full_report.json` — 외부 가공용 (전체 1,000문제 통계 + 사용자/세션 수)
- `report.md` — 사람이 즉시 읽을 수 있는 마크다운 리포트 (블로그/커뮤니티에 링크 공유 가능)

**`full_report.json` 스키마 예시**
```json
{
  "updated_at": "2026-05-20T12:00:00Z",
  "total_users": 1234,
  "total_sessions": 5678,
  "hardest_top20": [
    {"question_id": 123, "attempts": 500, "correct": 100, "wrong_rate": 0.80},
    ...
  ],
  "all_questions": {
    "1": {"attempts": 100, "correct": 80, "wrong_rate": 0.20},
    "2": {...}
  }
}
```

**`report.md` 템플릿 예시**
```markdown
# 운전면허 학과시험 1000제 통계 리포트

> 최근 업데이트: 2026-05-20 12:00 (UTC)

## 사용자 현황
- 누적 사용자: **1,234명**
- 누적 풀이 세션: **5,678회**

## 가장 많이 틀리는 문제 TOP 20

| 순위 | 문제 ID | 응시 | 오답률 |
|------|---------|------|--------|
| 1 | #123 | 500 | 80% |
| 2 | #456 | 423 | 75% |
| ... | ... | ... | ... |
```

**구체적 조치**
- [ ] `tool/aggregate_stats.js`에 사용자 수 집계 추가:
  - `firestore.collection('user_answers').get()` 으로 uid 문서 수 카운트 (= `total_users`)
  - 각 uid의 `sessions` 서브컬렉션은 `.count()` aggregation query로 합산 (`total_sessions`)
  - count() aggregation은 문서당 1 read만 발생 → 비용 최소화
- [ ] TOP 20 추출 로직 (현재 Top 10 + 10개 더)
- [ ] Markdown 템플릿 렌더링 (간단한 string template로 충분)
- [ ] 3개 파일 모두 `data-aggregates` 브랜치에 force commit
- [ ] `report.md` 공유 링크 확인:
  - `https://github.com/smilecws/quiz/blob/data-aggregates/report.md` — GitHub이 마크다운 렌더링해서 보여줌
  - 클릭 가능한 문제 ID는 quiz 앱의 question_detail 화면으로 연결되는 deep link 추가 검토

**예상 GitHub Actions read 비용** (Spark 한도 50K/일)
- question_stats 전체: 1,000 read
- user_answers 문서 수: 1,000 read (사용자 1,000명 가정)
- sessions count: 1,000명 × 1 (count aggregation) = 1,000 read
- **합계: 약 3,000 read/회 × 6회/일 = 18,000 read/일** (Spark 한도의 36%)

> 사용자 10,000명까지는 Spark 무료 한도 내에서 운영 가능. 그 이상은 cron 간격을 4시간 → 8시간으로 조정하면 부담 절반.

**활용 예시**
- 블로그: `report.md`의 표를 캡처해서 게시 ("이 앱으로 1,000명이 공부 중!")
- 커뮤니티: GitHub의 마크다운 렌더링 URL을 그대로 링크 공유
- 자체 가공: `full_report.json`을 다운로드해서 Excel/Sheets로 가공

---

### 🟠 P1-1. 에셋 최적화 / GitHub Pages 대역폭

**현재 상태**
- `assets/` 총 ~99MB (이미지 57MB + 동영상 38MB + JSON 4.8MB)
- 첫 방문 ~5MB, 활동적 사용자 누적 50~100MB
- GitHub Pages 소프트 한도 100GB/월 → **월 1,000명 활동 사용자에서 근접**

**조치**
- [ ] `assets/page_*.jpeg` 296개를 WebP/AVIF로 재인코딩 (품질 80, 30~50% 절감)
- [ ] `tool/compress_assets.dart` 배치 스크립트 작성
- [ ] `assets/questions_videos/` 35개 MP4를 H.264 baseline + 480p로 재인코딩
  - `ffmpeg -i in.mp4 -vf scale=480:-2 -c:v libx264 -crf 28 -preset slow -movflags +faststart out.mp4`
- [ ] (옵션, 5,000명 초과 시) 동영상을 Cloudinary/Firebase Storage CDN으로 이동, `quiz_screen.dart`의 `_VideoCard`를 URL 기반으로 변경
- [ ] `flutter build web --release` 후 `build/web/` 크기 측정

### 🟠 P1-2. 에러 모니터링 (Sentry 또는 Crashlytics)

**현재 상태**
- 에러 처리는 `debugPrint`만 (`global_answer_stats_service.dart:97`, `user_answer_log_service.dart:64` 등)
- Firestore 저장 실패, 동영상 재생 실패, 외부 URL 404 등 모두 사일런트
- Crashlytics는 Web 미지원 → **Sentry 권장**

**조치**
- [ ] `pubspec.yaml`에 `sentry_flutter` 추가
- [ ] `lib/main.dart`의 `runApp` 전 `SentryFlutter.init(...)` 호출
- [ ] uid/IP 마스킹 설정
- [ ] `lib/screens/consent_screen.dart` 동의 문구에 "오류 발생 시 익명 디버그 정보 전송" 추가
- [ ] 테스트: 의도적 `throw Exception('test')` → Sentry 수신 확인 → 제거

### 🟡 P2-1. 개인정보 처리 (한국 개인정보보호법)

**현재 상태**
- 이름 수집 → Firebase `displayName` + `user_answers/{uid}/sessions/{sid}.display_name` (`user_answer_log_service.dart:53`)
- `consent_screen.dart`에 보유기간/처리자 연락처/삭제권 미명시
- 동의 철회는 로컬만 삭제, Firebase 측 데이터 잔존 (`main.dart:114-119`)

**조치**
- [ ] `lib/screens/consent_screen.dart`에 보유기간 명시 ("응시 이력은 1년 후 자동 삭제")
- [ ] 개인정보처리자 연락 이메일 명시
- [ ] 권리 안내 추가 ("설정 → 동의 철회 및 삭제 요청")
- [ ] 설정 화면에 "내 데이터 삭제하기" 버튼 추가
- [ ] `user_answer_log_service.dart`에 `deleteAllSessions(uid)` 메서드 추가
- [ ] `firestore.rules`에 `user_answers/{uid}/sessions/{sid}` delete 규칙 추가 (`request.auth.uid == uid`)
- [ ] 개인정보처리방침 정적 페이지 작성

### 🟡 P2-2. 앱스토어/플레이스토어 배포 준비

**현재 상태**
- Android/iOS 앱 ID가 `com.example.quizApp` (스토어 거절)
- 앱 용량 99MB → iOS 200MB 한도 이하, Android는 App Bundle 분할 필수

**조치**
- [ ] `android/app/build.gradle.kts`의 `applicationId` + `namespace` 변경 (예: `com.smilecws.driverlicensequiz`)
- [ ] `ios/Runner.xcodeproj`의 `PRODUCT_BUNDLE_IDENTIFIER` 변경
- [ ] `flutterfire configure`로 `firebase_options.dart` 재생성
- [ ] 스토어 자산 준비 (아이콘 완료, 스크린샷·설명·개인정보처리방침 URL 필요)
- [ ] `flutter build appbundle --release` (Android)
- [ ] Apple Developer 계정 + signing 설정 (iOS)

### 권장 실행 순서

| 단계 | 작업 | 소요 | 선결 조건 |
|------|------|------|----------|
| 1 | P0-1 App Check + 보안 규칙 | 1~2시간 | - |
| 2 | P0-4 Step 1 영구 캐시(SharedPreferences) | 1~2시간 | - |
| 3 | P0-4 Step 2 GitHub Actions 외부 집계 | 3~5시간 | - |
| 4 | P0-2 Blaze 전환 결정 (P0-4 적용 후 재평가) | 30분~2시간 | P0-4 |
| 5 | P0-3 라이선스 정비 (LICENSE/README/출처표기) | 1~2시간 | - |
| 6 | P1-2 Sentry 도입 | 2~3시간 | - |
| 7 | P2-1 개인정보 삭제권 | 4~6시간 | - |
| 8 | P1-1 에셋 압축 | 4~8시간 | - |
| 9 | P2-2 앱스토어 ID 변경 | 1~2일 | 스토어 배포 시 |

**1~4번은 사용자 증가 전 반드시 선행**. P0-4 적용 시 read 비용이 거의 0이 되므로 P0-2(Blaze) 필요성을 재평가 가능. 7번(개인정보)은 법적 리스크라 가능한 빨리, 5번(P0-3)은 공단 허락 확보로 긴급도가 낮아져 위생 작업 수준, 8·9번은 트래픽/배포 확장 단계에서 진행.

---

## 참고

- **장기적 분리**: 사용자 수가 늘어 테스트와 운영을 영영 섞을 수 없게 되면, Firebase 프로젝트를 dev/prod 2개로 분리하고 `flutterfire configure --project=...` 로 환경별 빌드.
- **데이터 영구 보존**: 일정 시점의 통계를 백업하고 싶다면 `gcloud firestore export gs://<bucket>` 으로 GCS 에 export.
