# Step 0: license-files

## 읽어야 할 파일

먼저 아래 파일을 읽고 프로젝트의 성격과 자산 구성을 파악하라:

- `/CLAUDE.md` — 프로젝트 개요, 기술 스택, 자산 구성
- `/docs/PRD.md` — 제품 목표와 사용자

## 배경

quiz_app 은 한국 운전면허 학과시험 대비 퀴즈 앱이다. 문제 데이터·이미지·동영상은
한국도로교통공단의 학과시험 자료에서 가져왔으며, 프로젝트 소유자가 도로교통공단에
문의하여 사용(재배포) 허락을 받았다 (2026-05-20).

이 step 의 목적은 코드와 데이터의 라이선스를 분리해 명시하는 라이선스 문서 2개를
프로젝트 루트에 추가하는 것이다.

## 작업

프로젝트 루트에 아래 두 파일을 생성한다.

### 1. `LICENSE`

MIT License 표준 전문을 작성한다. 저작권 표기 첫 줄은 정확히 다음과 같이 한다:

```
Copyright (c) 2026 josh
```

### 2. `LICENSE_DATA.md`

코드(MIT)와 데이터의 라이선스가 다름을 설명하는 마크다운 문서. 아래 내용을 담는다:

- 이 저장소의 **코드**는 루트 `LICENSE` 파일의 MIT 라이선스를 따른다.
- 아래 **데이터·미디어 자산**은 한국도로교통공단의 학과시험 자료이며 코드 라이선스와 별개다:
  - 문제 1,000제 (`assets/questions_kor.json`, `questions_eng.json`, `questions_chi.json`, `questions_vi.json`)
  - 문제 관련 이미지 (`assets/` 내 문제 이미지)
  - 동영상 문제 (`assets/questions_videos/`)
  - 운전면허 실격사항 데이터 (`assets/driving_disqualification_merged.json`)
- 출처: 한국도로교통공단
- 사용 허락: 프로젝트 소유자가 도로교통공단에 문의하여 사용 허락을 받음 (2026-05-20).
  - 허락 경로 / 담당 부서 / 허락 범위: _(추후 기입 — 프로젝트 소유자가 공단 회신 내역으로 채운다)_
- `assets/study/*.json` 학습 카드는 공단 자료가 아니라 프로젝트에서 자체 제작한
  콘텐츠이며, 코드와 동일하게 MIT 라이선스를 따른다는 점을 명시한다.

## Acceptance Criteria

```bash
flutter analyze
```

- `flutter analyze` 가 통과해야 한다 (문서 파일만 추가하므로 기존 코드에 영향이 없어야 한다).
- 루트에 `LICENSE` 와 `LICENSE_DATA.md` 두 파일이 존재해야 한다.

## 검증 절차

1. 위 AC 커맨드를 실행한다.
2. `LICENSE` 와 `LICENSE_DATA.md` 가 생성되었고 내용이 위 작업 명세와 일치하는지 확인한다.
3. 결과에 따라 `phases/p0-3-license/index.json` 의 step 0 을 업데이트한다:
   - 성공 → `"status": "completed"`, `"summary"` 에 산출물 한 줄 요약
   - 3회 시도 후에도 실패 → `"status": "error"`, `"error_message"` 에 구체적 에러 기록

## 금지사항

- `assets/questions_*.json` 등 데이터 파일을 수정하지 마라. 이유: 이번 작업은 라이선스 문서만 추가하며, 데이터 파일에 메타데이터를 넣지 않기로 결정했다.
- `README.md` 를 수정하지 마라. 이유: README 갱신은 Step 1 의 작업이다.
- 앱 코드(`lib/`)를 수정하지 마라. 이유: 이번 작업은 루트 문서 파일 추가에 한정한다.
- 기존 테스트를 깨뜨리지 마라.
