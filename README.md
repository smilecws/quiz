# 운전면허 학과시험 1000제

한국 운전면허 학과시험 공식 문제 은행 1,000문항을 풀고 복습할 수 있는 오프라인 퀴즈 앱입니다.

## 주요 기능

- **모의고사** — 랜덤 40문제 · 40분 타이머 · 면허 종류별 합격 판정 (1종 70점 / 2종 60점)
- **카테고리 연습** — 말문제 · 표지 및 상황문제 · 동영상 문제 · 소카테고리 선택
- **즐겨찾기 & 오답 노트** — 별표로 즐겨찾기, 틀린 문항 자동 누적 · 다시 맞히면 제거
- **문항별 누적 통계** — 시도 수 · 정답률 · 보기별 선택 횟수 · 최다 오답 10선
- **학습 카드** — 소카테고리별 핵심 개념 · 수치 · 법령 출처 정리
- **실격 기준 카탈로그** — 기능시험 · 도로주행 실격사항 안내
- **다국어 지원** — 한국어 · 영어 · 중국어 · 베트남어 UI 및 문제 은행
- **라이트 / 다크 테마** 전환

## 지원 플랫폼

| 플랫폼 | 비고 |
|--------|------|
| Android | |
| iOS | |
| Web | WMV 동영상 미지원 (폴백 안내 표시) |
| Windows | WMV 동영상 재생 가능 |
| macOS | |

## 기술 스택

- **Flutter 3.x / Dart 3** — 단일 코드베이스 멀티 플랫폼
- **shared_preferences** — 로컬 영속 저장
- **google_fonts** — Jua 폰트
- **video_player** — 동영상 문제 재생
- **url_launcher** — 도로교통공단 외부 링크
- **firebase_core / firebase_auth / cloud_firestore** — 익명 학습 통계 집계 (Web · Android · iOS)
- **flutter_launcher_icons** — 멀티 플랫폼 아이콘 생성

## 빌드 · 실행

```bash
flutter pub get                          # 의존성 설치
flutter run                              # 기본 디바이스 실행
flutter run -d chrome                    # 웹 (개발)
flutter run -d windows                   # Windows 데스크톱
flutter build web                        # GitHub Pages 배포 빌드
flutter build apk --release              # Android 릴리즈
flutter test                             # 전체 테스트
flutter analyze                          # 린트
```

## 데이터 출처

문제 1,000제(한국어 · 영어 · 중국어 · 베트남어), 문제 관련 이미지, 동영상, 실격사항 데이터는 **한국도로교통공단**의 학과시험 자료이며, 프로젝트 소유자가 사용 허락을 받았습니다. 자세한 내용은 [LICENSE_DATA.md](LICENSE_DATA.md)를 참조하세요.

## 라이선스

- **코드**: [MIT License](LICENSE)
- **데이터 · 미디어 자산**: 한국도로교통공단 자료 — 별도 라이선스 적용. [LICENSE_DATA.md](LICENSE_DATA.md) 참조.
