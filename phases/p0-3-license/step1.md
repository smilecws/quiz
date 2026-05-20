# Step 1: readme-update

## 읽어야 할 파일

먼저 아래 파일을 읽어라:

- `/CLAUDE.md` — 프로젝트 개요, 기술 스택, 명령어
- `/docs/PRD.md` — 제품 목표와 핵심 기능
- `/LICENSE` — Step 0 에서 생성한 MIT 라이선스 파일
- `/LICENSE_DATA.md` — Step 0 에서 생성한 데이터 라이선스 문서
- 기존 `/README.md` — 현재 Flutter 기본 템플릿 상태

## 배경

현재 `README.md` 는 `flutter create` 가 생성한 기본 템플릿("A new Flutter project")
그대로다. 프로젝트의 실체를 설명하고, Step 0 에서 만든 라이선스 구조를 안내하도록
전면 재작성한다.

## 작업

`README.md` 를 아래 7개 구성 요소로 전면 재작성한다. 모든 내용은 `CLAUDE.md` 와
`docs/PRD.md` 에서 파악한 사실에 근거해야 하며, 확인되지 않은 내용을 추측으로
채우지 마라.

1. **프로젝트 제목과 한 줄 소개** — 한국 운전면허 학과시험 1000제 대비 퀴즈 앱.
2. **주요 기능** — 모의고사(랜덤 40문제·40분), 카테고리·즐겨찾기·오답 연습, 통계 등
   `CLAUDE.md` 와 `docs/PRD.md` 에 근거해 작성.
3. **지원 플랫폼** — Android / iOS / Web / Windows / macOS.
4. **기술 스택** — `CLAUDE.md` 의 기술 스택 절을 요약.
5. **빌드·실행 방법** — `CLAUDE.md` 의 명령어 절을 요약.
6. **데이터 출처** — 문제·이미지·동영상·실격사항 데이터는 한국도로교통공단 자료이며
   사용 허락을 받았음을 명시하고, 자세한 내용은 `LICENSE_DATA.md` 를 링크로 참조.
7. **라이선스** — 코드는 MIT(`LICENSE` 링크), 데이터는 별도(`LICENSE_DATA.md` 링크)
   임을 명시.

## Acceptance Criteria

```bash
flutter analyze
```

- `flutter analyze` 가 통과해야 한다 (README 만 변경하므로 기존 코드에 영향이 없어야 한다).
- `README.md` 가 위 7개 구성 요소를 모두 포함해야 한다.
- `README.md` 본문에서 `LICENSE` 와 `LICENSE_DATA.md` 를 마크다운 링크로 참조해야 한다.

## 검증 절차

1. 위 AC 커맨드를 실행한다.
2. `README.md` 가 7개 구성 요소를 포함하고, Step 0 의 `LICENSE`/`LICENSE_DATA.md` 를
   링크로 참조하는지 확인한다.
3. 결과에 따라 `phases/p0-3-license/index.json` 의 step 1 을 업데이트한다:
   - 성공 → `"status": "completed"`, `"summary"` 에 산출물 한 줄 요약
   - 3회 시도 후에도 실패 → `"status": "error"`, `"error_message"` 에 구체적 에러 기록

## 금지사항

- `LICENSE` 와 `LICENSE_DATA.md` 를 수정하지 마라. 이유: Step 0 에서 이미 확정한
  파일이며, README 는 이 파일들을 "참조"만 한다.
- 앱 코드(`lib/`)나 데이터 파일을 수정하지 마라. 이유: 이번 작업은 README 갱신에 한정한다.
- 기존 테스트를 깨뜨리지 마라.
