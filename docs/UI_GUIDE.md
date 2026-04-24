# UI 디자인 가이드

## 디자인 원칙
1. **공부 도구처럼 보여야 한다** — 마케팅 랜딩이 아니라 시험 전날에도 편히 쓸 수 있는 학습 앱. 꾸밈보다 가독성.
2. **한 손 엄지 조작 우선** — 주 대상이 모바일. 바닥 고정 CTA 버튼, 상단 앱바의 필수 액션(즐겨찾기·타이머) 외에는 본문에 배치.
3. **결과는 즉시, 원상 복귀도 즉시** — 채점/해설은 선택 즉시 공개(연습 모드), 모의고사는 시험 형태 유지. 홈 복귀는 언제나 한 번의 탭.
4. **라이트 & 다크 동급 지원** — 다크 모드를 2순위로 두지 않는다. `AppThemeColors` 의 두 프리셋이 각각 완결된 팔레트.

## AI 슬롭 안티패턴 — 하지 마라
| 금지 사항 | 이유 |
|-----------|------|
| `backdrop-filter: blur()` / glassmorphism | AI 템플릿의 1번 징후, Flutter 에서 성능도 나쁨 |
| 그라디언트 텍스트 | SaaS 랜딩 클리셰, 접근성 저해 |
| "AI 학습 코치" 같은 장식 배지 | 기능이 아니면 붙이지 않는다 |
| 네온 glow / 외곽선 애니메이션 | 공부 중 산만함 유발 |
| 보라/인디고 브랜드 컬러 | "AI = 보라" 클리셰. 이 앱은 초록(합격=go) |
| 모든 카드 `rounded-2xl`(24px) | 계층이 뭉개져 템플릿 느낌. 카드 16px, 작은 배지 12px 로 구분 |
| 홈 배경 grain / orb blur | 정보 밀도가 높은 화면에 노이즈 |
| 보기마다 색이 다른 무지개 하이라이트 | 정답(초록)·오답(빨강)·선택(테마) 3색으로 충분 |
| `SystemUiOverlay` 강제 고정으로 사용자 제스처 가로막기 | `PopScope` 로 정상 귀환 처리 |

## 색상 (AppThemeColors)
### 라이트
| 용도 | 값 |
|------|------|
| 페이지 배경 | `#F0FDF4` (emerald-50) |
| 카드(상호작용) | `#FFFFFF` |
| 카드(서브/해설) | `#ECFDF5` (emerald-100) |
| Primary | `#22C55E` (green-500) |
| Primary Dark(아이콘/강조) | `#16A34A` (green-600) |
| Chip 배경 | `#DCFCE7` (green-100) |
| 보더 | `#D1FAE5` (emerald-200) |
| 주 텍스트 | `#1E293B` (slate-800) |
| 보조 텍스트 | `#64748B` (slate-500) |

### 다크
| 용도 | 값 |
|------|------|
| 페이지 배경 | `#0C1210` |
| 카드(상호작용) | `#1A2E22` |
| 카드(서브/해설) | `#142318` |
| Primary | `#4ADE80` (green-400) |
| Primary Dark | `#22C55E` (green-500) |
| Chip 배경 | `#166534` (green-800) |
| 보더 | `#2D4A38` |
| 주 텍스트 | `#F1F5F9` |
| 보조 텍스트 | `#94A3B8` |

### 시맨틱(하드코드, 라이트/다크 공용)
| 용도 | 값 |
|------|------|
| 정답 배경(채점 후) | `#DCFCE7` |
| 정답 테두리 | `Colors.green` |
| 오답 배경 | `#FEE2E2` |
| 오답 테두리 | `Colors.red` |
| 타이머 경고(≤60초) | `#FEE2E2` / `red.shade700` |
| 합격 뱃지 | `#15803D` (green-700) |
| 불합격 뱃지 | `red.shade700` |

접근 규칙: 위젯은 반드시 `context.appColors.xxx` 로 읽는다. `Theme.of(context).colorScheme` 을 직접 참조하지 말 것 (다크 분기가 ThemeExtension 에 있어서 컬러스킴만 보면 틀림).

## 타이포그래피
- **전체 폰트**: `google_fonts` 의 **Jua** (`GoogleFonts.juaTextTheme`). `main.dart` 의 `_lightTheme` / `_darkTheme` 에서 일괄 적용.
- 앱바 제목 18pt W600
- 섹션 제목 16pt W800
- 본문(문항 텍스트) 18pt W600 height 1.5
- 카드 제목 15pt W800
- 보조/설명 12–13pt height 1.4, `textSecondary`
- 결과 점수 34~36pt W700 (시맨틱 컬러)

## 레이아웃
- **SafeArea** 감싸기. 하단 CTA 는 `EdgeInsets.fromLTRB(20, 0, 20, 32)` 로 홈 인디케이터 회피.
- **카드 radius**: 메인 카드 16px, 보조/해설 12px, 원형 배지 999 (pill).
- **간격**: 섹션 간 18–20, 카드 간 10–12, 카드 내부 14.
- **홈 상단 통계 행**: 텍스트 스케일에 따라 176×0.8 ~ 248×0.8 범위로 확장 (`_homeStatsRowHeight`).
- **퀴즈 화면 진행 바**: `LinearProgressIndicator` 6px, `primary` 색.

## 컴포넌트 패턴
- **홈 타일(`_MenuTile`)**: 좌측 40×40 아이콘 배지(iconBg + primaryDark 아이콘) → 타이틀/서브 → 오른쪽 `chevron_right`. 뱃지는 우측 빨간 카운트.
- **옵션 버튼(퀴즈)**: 숫자 원형 배지(primary.withAlpha 0.12) + 보기 텍스트. 선택 시 테두리 primary, 채점 후 배경·테두리 시맨틱 색으로 전환. `AnimatedContainer` 200ms.
- **정답 공개 배너**: 전구 아이콘 + chipBg 카드에 해설 텍스트. 모의고사 모드에서는 숨김.
- **바텀시트(시트·메뉴)**: `showModalBottomSheet` + `RoundedRectangleBorder.vertical(top: Radius.circular(20))`. 내부는 `SafeArea` + `_PracticeTypeTile` 리스트.
- **비디오 카드(`_VideoCard`)**: 로딩(스피너) / 재생 / 재생 불가(폴백 텍스트) 3상태. 웹+wmv 는 초기부터 폴백.

## 아이콘
- Material icon만 사용. 커스텀 SVG 미도입.
- 아이콘 배지: 항상 `40×40` + `radius 14` + pastel 배경 + `primaryDark` 전경.
- 국기 이모지는 현재 사용하지 않음(언어는 텍스트 라벨). 필요 시 한 화면(언어 선택 시트)에서만 허용.

## 애니메이션
- 옵션 선택 후 색 전환: `AnimatedContainer` 200ms
- 실격 기준 팁 롤링: `AnimatedSwitcher` 280ms
- 그 외 커스텀 애니메이션 도입 금지. 새 모션이 필요하면 위 2가지와 일관성 유지.

## 접근성
- 모든 IconButton 에 `tooltip` 지정.
- 텍스트 스케일 대응: 홈 통계 행은 `MediaQuery.textScalerOf(context)` 를 보고 높이 확장. 새 고정 높이 카드를 만들 때 동일 패턴 적용.
- 탭 타깃 최소 48×48 유지 (`IconButton` 기본).

## 다국어 텍스트 원칙
- 하드코드 문자열 금지. 새 문자열은 `AppLocalizations` 의 4개 언어 맵에 동시에 추가한다.
- 숫자/날짜 포맷은 로케일에 따라 분기 (`mock_exam_history_screen` 의 `_formatWhen` 참고).
- 번역이 도착하기 전에는 ko 폴백 사용 (기본 `_t` 구현이 자동 폴백).
