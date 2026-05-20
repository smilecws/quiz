# Architecture Decision Records

## 철학
개인 토이 프로젝트 → 개인 서비스로 성장하는 중. 단일 개발자가 유지보수하므로 **의존성 최소화**, **학습 곡선 없는 기본기**, **로컬 퍼스트**를 우선한다. 서버·DB·상태관리 라이브러리 도입은 아직 불필요.

---

### ADR-001: Flutter 단일 코드베이스
**결정**: Android / iOS / Web / Windows / macOS 를 Flutter 하나로 빌드한다. React Native / 네이티브 분리 안 함.
**이유**: 문제 은행 1,000문항 + 이미지/동영상을 모든 플랫폼에 동일하게 뿌리는 게 목표. Streamlit/PWA 로는 모바일 UX 가 못 받치고, 네이티브 개별 개발은 비용이 비대.
**트레이드오프**: 웹 빌드 용량이 크고 초기 로딩 지연. WMV 같은 플랫폼 한정 포맷은 웹에서 폴백 처리가 필요.

### ADR-002: 상태 관리 라이브러리 미도입
**결정**: Provider / Riverpod / Bloc / GetX 도입 안 함. `StatefulWidget` + `setState` + `InheritedWidget`(`AppSettingsScope`) 만 사용.
**이유**: 현재 범위에서 공유 상태는 (locale, themeMode, authState) 뿐. 퀴즈 세션 상태는 한 스크린 안에서만 살아 있고, 도메인 상태는 SharedPreferences 가 소스 오브 트루스. 라이브러리 추가 비용이 가치를 초과.
**트레이드오프**: 화면 간 이동 후 카운트 재조회가 수동(`await _loadCounts()`). 실시간 반응형이 필요한 화면이 늘면 재평가.

### ADR-003: SharedPreferences 단일 저장소
**결정**: 모든 영속 데이터를 `shared_preferences` 에 저장한다. SQLite / Hive / Isar 미도입.
**이유**: 저장 대상은 (a) 정수 ID 집합, (b) 소규모 JSON(<80 건 이력, ~1,000 키 통계, PIPA 동의 기록 1건) 뿐. 쿼리가 필요 없고 앱 시작 시 일괄 로드 비용이 미미.
**트레이드오프**: 10MB 수준을 넘어가면 성능 저하 — 사용자별 누적 통계가 커지면 Hive/Isar 로 이전 필요. 복잡한 인덱싱/조인 불가.

### ADR-004: 문제 은행을 에셋 번들로 탑재
**결정**: `questions_*.json` 을 `assets/` 에 번들링해 `rootBundle.loadString` 으로 로드한다. 서버 / CDN 에서 다운로드하지 않음.
**이유**: 오프라인에서 100% 동작, 설치 직후 바로 풀이 가능, 서버 운영 비용 0. 문제 은행이 자주 바뀌지 않아 앱 업데이트 주기와 자연스럽게 맞음.
**트레이드오프**: 앱 번들이 크다 (이미지/동영상 포함). 문제 은행 업데이트 시 스토어 재심사 필요. 언어별로 전체 JSON 재번들.

### ADR-005: 문제 JSON 3가지 포맷 공존
**결정**: `Question` 에 `fromJson` / `fromPageExport` / `fromPdfProblemsExport` 3개 팩토리를 둬 레거시·page export·PDF problems export 를 전부 받는다.
**이유**: 문제 은행 생성 파이프라인이 시간이 지나며 진화했고, 과거 언어 파일을 재생성하는 비용이 크다. 파서가 포맷을 흡수하는 편이 저렴.
**트레이드오프**: 파싱 로직이 분기로 복잡해짐. 신규 문제 은행은 하나의 포맷으로 수렴시키는 것이 바람직하지만, 기존 파일 호환은 계속 유지.

### ADR-006: 자체 AppLocalizations (gen_l10n 미사용)
**결정**: Flutter 의 `gen_l10n` / `.arb` 대신 `lib/l10n/app_localizations.dart` 한 파일에 ko/en/zh/vi 맵을 직접 적는다.
**이유**: 문자열 규모가 작고(~100 키), 복수형/성별 규칙이 없음. 빌드 단계 추가를 피해 단순성 유지. 개발자가 타입 안전하게 접근 가능.
**트레이드오프**: 번역가 워크플로(.arb 업로드) 없음. 키가 1~200 규모를 넘으면 gen_l10n 으로 전환 검토.

### ADR-007: 정답을 항상 `List<int>` 로 표준화
**결정**: 단일 정답도 길이 1 리스트, 복수 정답도 동일 리스트. `isMultipleChoice` 는 `correctIndices.length > 1` 로 판별.
**이유**: 입력 JSON 이 `answer: int` / `answer: [int]` / `answer: ①②③④` 등 혼재. 내부에서 한 타입으로 고정하지 않으면 채점/저장 로직이 분기 지옥.
**트레이드오프**: 단일 선택 문항도 list 순회 비용 발생(무시 가능). 저장되는 오답 노트/통계에서 타입 전환 필요 없음.

### ADR-008: video_player + WMV 웹 폴백
**결정**: 동영상 문제는 `video_player` 로 재생, 웹에서 `.wmv` URI 는 재생 시도 없이 안내 카드로 폴백.
**이유**: 공식 문제 은행의 일부 동영상이 WMV. iOS/Android/Windows 네이티브는 재생 가능하지만 Chrome HTML5 는 미지원. 실패 후 에러를 띄우느니 사전 분기가 UX 적.
**트레이드오프**: 웹 사용자에게는 해당 문항 영상이 보이지 않음 — "Windows 앱" 권장 메시지로 유도. 장기적으로는 MP4 로 트랜스코딩이 답.

### ADR-009: GitHub Pages 로 웹 배포
**결정**: 데모/미리보기는 `flutter build web` → GitHub Pages 자동 배포 (`deploy_github_pages.yml`). 자체 서버/호스팅 미구축.
**이유**: 공개 데모 URL 이 필요하지만 인증/서버 로직이 없어 정적 호스팅으로 충분. 비용 0, 파이프라인 단순.
**트레이드오프**: base href 제약, 빌드 산출물 크기, WMV 미지원. 인증/결제를 붙이면 이전 필요.

### ADR-010: PIPA 동의 게이트 + Firebase 익명 인증
**결정**: 앱 첫 실행 시 이름 입력 + 개인정보 수집·이용 동의를 받아야 진입을 허용한다. 인증은 Firebase Anonymous Auth 를 사용하며, 동의 기록은 로컬(`SharedPreferences`)에 저장한다. 게이트 통과 여부는 동의 기록 유무로 판별한다.
**이유**: 글로벌 통계(ADR-011)를 Firestore 에 기록하려면 인증된 사용자가 필요. 익명 인증은 사용자 마찰 없이 UID 를 발급하고 Firestore 보안 규칙에서 write 권한을 제어할 수 있다. PIPA 요건(목적·항목·보존기간·거부 권리 고지) 준수.
**트레이드오프**: 데스크톱(Windows/macOS/Linux)은 Firebase 미지원이라 통계 수집이 비활성화된다. 동의 버전이 올라가면 기존 사용자가 재동의 필요.

### ADR-011: Firestore 로 글로벌 통계·풀이 이력 기록
**결정**: 문항별 글로벌 통계(`question_stats/{questionId}`)와 사용자별 풀이 이력(`user_answers/{uid}/sessions/{auto_id}`)을 Cloud Firestore 에 기록한다. 쓰기는 `GlobalAnswerStatsService` 와 `UserAnswerLogService` 만 담당한다.
**이유**: Firebase 무료 티어(Spark)로 운영 비용 0. 익명 인증 UID 기반 보안 규칙으로 write 를 제어하고, 운영자는 Firebase 콘솔에서 직접 조회한다. 클라이언트 read 는 보안 규칙으로 차단해 비용을 억제한다.
**트레이드오프**: Firestore 문서 1,000개를 클라이언트에서 직접 읽으면 무료 한도를 빠르게 소진 — ADR-013 의 외부 집계로 해결. App Check 미도입 상태라 write 검증이 약함(카운터 +1 검증은 dotted-path 문제로 제거됨).

### ADR-012: 학습 카드를 에셋 JSON 으로 관리
**결정**: 소카테고리별 핵심 개념·수치·법령 출처를 `assets/study/<subcategoryId>.json` 파일에 저장하고 `StudyCardService` 가 로드한다. 콘텐츠는 사람이 직접 작성; `tool/extract_study_seeds.dart` 는 초안 seed 만 생성.
**이유**: 문제 은행과 동일하게 오프라인·번들 접근 방식을 유지. 별도 CMS 없이 파일 편집만으로 콘텐츠 추가 가능. LocalizedText(`{ko, en, zh, vi}`) 맵으로 다국어 지원.
**트레이드오프**: 콘텐츠 업데이트마다 앱 재배포 필요. 카드 스키마 변경 시 `StudyCard` 모델과 `StudyCardScreen` 을 함께 갱신해야 함.

### ADR-013: 글로벌 통계 읽기를 GitHub Actions 외부 집계로 전환
**결정**: 클라이언트가 Firestore 의 `question_stats` 1,000문서를 직접 읽는 대신, GitHub Actions cron(4시간 주기)이 `tool/aggregate_stats.js` 로 서버사이드 집계해 `aggregates.json` 을 별도 `data-aggregates` 브랜치에 커밋한다. 클라이언트는 GitHub raw URL 로 HTTP fetch 하고, SharedPreferences 에 1시간 TTL 로 캐시한다.
**이유**: Firestore 무료 티어의 일일 read 한도(50,000)를 사용자 수 증가 시 빠르게 소진. 사전 집계로 클라이언트 read 를 0 으로 줄이고, GitHub raw URL 은 CDN 이라 추가 비용 없음.
**트레이드오프**: 통계 신선도가 최대 4시간 지연된다. GitHub Actions Secrets 에 Firebase 서비스 계정 키 등록이 필요. `data-aggregates` 브랜치를 별도로 사용하는 이유는 (1) Flutter 웹 service worker 가 `main` 브랜치의 파일을 공격적으로 캐싱해 집계 갱신이 반영되지 않는 문제 회피, (2) 자동 생성 파일로 `main` 커밋 이력을 오염시키지 않기 위함.
