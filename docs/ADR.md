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
**이유**: 현재 범위에서 공유 상태는 (locale, themeMode) 뿐. 퀴즈 세션 상태는 한 스크린 안에서만 살아 있고, 도메인 상태는 SharedPreferences 가 소스 오브 트루스. 라이브러리 추가 비용이 가치를 초과.
**트레이드오프**: 화면 간 이동 후 카운트 재조회가 수동(`await _loadCounts()`). 실시간 반응형이 필요한 화면이 늘면 재평가.

### ADR-003: SharedPreferences 단일 저장소
**결정**: 모든 영속 데이터를 `shared_preferences` 에 저장한다. SQLite / Hive / Isar 미도입.
**이유**: 저장 대상은 (a) 정수 ID 집합, (b) 소규모 JSON(<80 건 이력, ~1,000 키 통계) 뿐. 쿼리가 필요 없고 앱 시작 시 일괄 로드 비용이 미미.
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
