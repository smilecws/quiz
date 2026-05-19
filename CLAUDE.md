# 프로젝트: quiz_app (운전면허 학과시험 1000제)

한국 운전면허 학과시험 대비 퀴즈 앱. 1,000문제 풀 중 랜덤 40문제를 뽑아 40분 모의고사로 응시하거나, 카테고리/즐겨찾기/오답 위주로 연습한다. Flutter 단일 코드베이스로 Android / iOS / Web / Windows / macOS 를 빌드한다.

## 기술 스택
- Flutter 3.x, Dart 3 (SDK `>=3.0.0 <4.0.0`)
- `shared_preferences` — 로컬 영속 저장 (ID 목록 / JSON 문자열)
- `google_fonts` — Jua 폰트
- `video_player` — 동영상 문제 재생 (iOS/Android/macOS/Windows 네이티브, 웹은 HTML5 video)
- `url_launcher` — 도로교통공단 외부 링크
- `flutter_localizations` + 자체 `AppLocalizations` (gen-l10n 미사용)
- `flutter_launcher_icons` — 멀티 플랫폼 아이콘 생성
- `firebase_core` / `firebase_auth` (익명 로그인) / `cloud_firestore` — 익명 학습 통계 집계용. Web/Android/iOS 만 지원하며 Windows/macOS 데스크톱에서는 기능이 자동 비활성화된다. Firebase 프로젝트는 `quiz-ace9a`, 설정은 `lib/firebase_options.dart` (flutterfire CLI 자동 생성), 보안 규칙은 `firestore.rules` (`firebase deploy --only firestore:rules` 로 배포).

## 아키텍처 규칙
- CRITICAL: 레이어 경계 — `lib/models/` ← `lib/services/` ← `lib/screens/`. 역방향 import 금지. `services/` 는 `models/` 와 플러그인(`shared_preferences`, `flutter/services` rootBundle)에만 의존한다. `screens/` 만 Flutter `material.dart` 에 의존한다.
- CRITICAL: 영속 데이터는 전부 `services/*_service.dart` 에 static 메서드로 격리한다. 스크린 위젯에서 `SharedPreferences.getInstance()` 를 직접 호출하지 않는다 (테스트/마이그레이션 지점이 한 곳이어야 함).
- CRITICAL: 문제 은행 JSON 은 3가지 포맷이 공존한다 (`questions[]` 레거시 / `pages[].questions[]` page export / `pages[].problems[]` PDF problems export). 이 파싱은 전부 `models/question.dart` 의 `Question.fromJson` / `fromPageExport` / `fromPdfProblemsExport` 3개 팩토리에만 둔다. 스크린/서비스는 `Question` 만 다룬다.
- CRITICAL: 정답 인덱스는 항상 `List<int> correctIndices` (0-based). 단일 정답도 길이 1 리스트. `isMultipleChoice` 는 길이로 판별. 저장/비교 시 `int` 와 `List<int>` 를 섞지 않는다.
- 언어 전환 시 `QuestionService.setLanguageCode()` 로 캐시를 비운다 (`clearCache()` 호출). 스크린에서 직접 캐시를 건드리지 않는다.
- 테마 색은 `theme/app_theme_colors.dart` 의 `AppThemeColors` ThemeExtension 만 사용한다. 위젯에서 `context.appColors.xxx` 로 접근 — `Theme.of(context).colorScheme` 을 직접 읽지 않는다 (다크 모드 색이 분기되어 있음).
- 외부 URL 을 `url_launcher` 로 열기 전 반드시 `utils/safe_external_url.dart` 의 검증을 거친다 (https + 허용 호스트만).
- 소카테고리 매핑(`assets/question_subcategory.json`) 은 `tool/classify_subcategory.dart` 로만 재생성한다. 수동 편집 금지. 규칙은 `lib/services/subcategory_classifier.dart` 에 두고 CLI·테스트·런타임 모두 거기서 참조한다.
- 학습 카드(`assets/study/<tag>.json`) 는 사람이 직접 작성한다. `tool/extract_study_seeds.dart` 가 만든 `assets/study/_seeds/` 는 작성 보조용 중간 산출물이며 git ignore 처리. 카드 스키마 변경 시 `lib/models/study_card.dart` 와 `lib/screens/study_card_screen.dart` 를 함께 갱신한다.
- CRITICAL: 익명 글로벌 통계의 모든 Firestore I/O 는 `lib/services/global_answer_stats_service.dart` 만 한다. 스크린·다른 서비스에서 `FirebaseFirestore.instance` 를 직접 호출 금지. 동의 거부·미지원 플랫폼은 같은 서비스 내부에서 no-op 처리되므로 호출부 가드 불필요. 데이터 모델은 `question_stats/{questionId}` 문서의 `attempts` / `correct` / `option_counts` (Map) / `last_updated_at` 필드이며, 보안 규칙(`firestore.rules`) 은 현재 익명 로그인 사용자의 write 만 허용한다(카운터 +1 검증은 dotted-path 처리 문제로 제거됨, App Check 도입 시 보완 예정). 스키마 변경 시 규칙도 같이 갱신해 재배포한다.
- CRITICAL: 사용자별 풀이 이력(`user_answers/{uid}/sessions/{auto_id}`) 의 모든 Firestore I/O 는 `lib/services/user_answer_log_service.dart` 만 한다. 운영자(=프로젝트 소유자)가 Firebase 콘솔에서 uid 단위로 직접 조회하는 용도이며, 클라이언트 read 는 보안 규칙으로 차단되어 있다. 동의 시 입력받은 이름은 익명 사용자의 `displayName` 에 세팅되어 콘솔에서 식별자로 사용된다.

## 개발 프로세스
- 새 스크린을 추가할 때는 `MaterialPageRoute` 로 `Navigator.push` 하는 패턴을 따른다 (라우트 테이블 / go_router 미도입).
- 텍스트는 전부 `AppLocalizations.of(context).xxx` 로 참조한다. 새 문자열은 `lib/l10n/app_localizations.dart` 의 4개 언어 맵에 동시에 추가한다. ko 키는 필수 (폴백).
- 동영상 컨트롤러는 웹/핫리스타트에서 dispose 타이밍이 까다롭다. 새 비디오 위젯을 만들 경우 `quiz_screen.dart` 의 `_prepareVideoForQuestion` / `_disposeVideoLater` 패턴(다음 프레임에 dispose)을 그대로 따른다.
- 커밋 메시지는 짧은 제목 한 줄. (현 히스토리 예: `dark mode and typepo fix` / `test1` / `Initial commit: Flutter quiz app + GitHub Pages workflow`)

## 명령어
```
flutter pub get                          # 의존성
flutter run                              # 기본 디바이스 실행
flutter run -d chrome                    # 웹 (dev)
flutter run -d windows                   # Windows 데스크톱 (WMV 재생 가능)
flutter build web                        # GitHub Pages 배포 빌드
flutter build apk --release              # Android 릴리즈
flutter test                             # 전체 위젯 테스트
flutter analyze                          # 린트
dart run flutter_launcher_icons          # 앱 아이콘 재생성 (assets/app_icon.png 수정 후)
python tool/generate_app_icon_png.py     # assets/app_icon.png 원본 재생성
```

## 배포
- `main` 브랜치에 push 하면 `.github/workflows/deploy_github_pages.yml` 이 `flutter build web` → GitHub Pages 에 배포.
- 웹 빌드에서는 WMV 동영상이 재생 불가 (HTML5 video 미지원). `quiz_screen.dart` 의 `_VideoCard` 가 자동으로 "Windows 앱으로 실행" 안내 카드로 폴백한다.
