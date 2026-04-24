// 앱 전 화면의 골든 PNG 를 test/golden/goldens/ 에 생성합니다.
//
//   flutter test --update-goldens test/golden/screens_golden_test.dart
//
// 주의사항:
// - Google Fonts 런타임 페칭이 꺼져 있어 Jua 대신 시스템 기본 폰트로 렌더됩니다.
//   실기기 스크린샷과 100% 동일하지 않습니다(레이아웃 검증용).
// - video_player / url_launcher 를 건드리지 않도록 비디오 없는 테스트 문항을 사용합니다.
// - Home 은 3.5s 주기 Tip 타이머가 있어 캡처 후 빈 위젯으로 교체해 dispose 합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/disqualification_catalog.dart';
import 'package:quiz_app/models/mock_exam_license_kind.dart';
import 'package:quiz_app/models/session_result.dart';
import 'package:quiz_app/screens/disqualification_detail_screen.dart';
import 'package:quiz_app/screens/exam_guide_screen.dart';
import 'package:quiz_app/screens/home_screen.dart';
import 'package:quiz_app/screens/mock_exam_history_screen.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import 'package:quiz_app/screens/result_screen.dart';
import 'package:quiz_app/screens/stats_screen.dart';
import 'package:quiz_app/screens/study_card_screen.dart';
import 'package:quiz_app/screens/study_screen.dart';
import 'package:quiz_app/screens/written_exam_menu_screen.dart';

import '_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadAppFonts();
  });

  // ─── 랜딩 홈 (HomeScreen) ─────────────────────────────────────────────────
  group('landing', () {
    testWidgets('ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester.pumpWidget(wrapForGolden(const HomeScreen()));
      await settleAsync(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/landing_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('ko_dark', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester.pumpWidget(
        wrapForGolden(const HomeScreen(), themeMode: ThemeMode.dark),
      );
      await settleAsync(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/landing_ko_dark.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ─── 학습하기 인덱스 + 학습 카드 ────────────────────────────────────────
  group('study', () {
    testWidgets('index_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await primeQuestionBankCache(tester);
      await tester.pumpWidget(wrapForGolden(const StudyScreen()));
      await settleAsync(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/study_index_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('card_child_zone_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await primeQuestionBankCache(tester);
      await tester.pumpWidget(
        wrapForGolden(
          const StudyCardScreen(subcategoryId: 'child_zone'),
        ),
      );
      await settleAsync(tester,
          wait: const Duration(milliseconds: 800));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/study_card_child_zone_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('card_alcohol_ko_dark', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await primeQuestionBankCache(tester);
      await tester.pumpWidget(
        wrapForGolden(
          const StudyCardScreen(subcategoryId: 'alcohol'),
          themeMode: ThemeMode.dark,
        ),
      );
      await settleAsync(tester,
          wait: const Duration(milliseconds: 800));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/study_card_alcohol_ko_dark.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ─── "문제 풀기" 메인 메뉴 (WrittenExamMenuScreen) ───────────────────────
  group('home', () {
    testWidgets('ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs(
        attemptedCount: 180,
        favoritesCount: 12,
        wrongCount: 27,
        mockExamHistory: [
          {
            'at': DateTime(2026, 4, 23, 14, 30).millisecondsSinceEpoch,
            'kind': 'type1Normal',
            'score': 32,
            'total': 40,
            'wrong_ids': [1, 5, 12, 22, 30, 31, 39, 40],
          },
        ],
      );
      await primeQuestionBankCache(tester);
      await tester
          .pumpWidget(wrapForGolden(const WrittenExamMenuScreen()));
      await settleAsync(tester, wait: const Duration(milliseconds: 800));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('ko_dark', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs(
        attemptedCount: 180,
        favoritesCount: 12,
        wrongCount: 27,
        mockExamHistory: [
          {
            'at': DateTime(2026, 4, 23, 14, 30).millisecondsSinceEpoch,
            'kind': 'type1Normal',
            'score': 32,
            'total': 40,
          },
        ],
      );
      await primeQuestionBankCache(tester);
      await tester.pumpWidget(
        wrapForGolden(
          const WrittenExamMenuScreen(),
          themeMode: ThemeMode.dark,
        ),
      );
      await settleAsync(tester, wait: const Duration(milliseconds: 800));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_ko_dark.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('en_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs(
        attemptedCount: 72,
        favoritesCount: 5,
        wrongCount: 14,
        localeCode: 'en',
      );
      await primeQuestionBankCache(tester);
      await tester.pumpWidget(
        wrapForGolden(
          const WrittenExamMenuScreen(),
          locale: const Locale('en'),
        ),
      );
      await settleAsync(tester, wait: const Duration(milliseconds: 800));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_en_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ─── 홈에서 여는 바텀시트들 ──────────────────────────────────────────────
  group('bottom_sheets', () {
    testWidgets('practice_sheet_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester
          .pumpWidget(wrapForGolden(const WrittenExamMenuScreen()));
      await settleAsync(tester);
      // "문제 풀기" 타일 탭 → 연습 모드 1차 시트
      await tester.tap(find.text('문제 풀기'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/practice_sheet_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('subcategory_sheet_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester
          .pumpWidget(wrapForGolden(const WrittenExamMenuScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('문제 풀기'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // 1차 시트에서 "말문제" 타일 → 2차 소카테고리 시트
      await tester.tap(find.text('말문제'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/subcategory_sheet_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('mock_license_sheet_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester
          .pumpWidget(wrapForGolden(const WrittenExamMenuScreen()));
      await settleAsync(tester);
      await tester.tap(find.text('모의고사 응시'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mock_license_sheet_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ─── 통계 / 모의고사 이력 ────────────────────────────────────────────────
  group('stats_and_history', () {
    testWidgets('stats_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs(
        attemptedCount: 482,
        wrongCount: 53,
        mockExamHistory: [
          for (var i = 0; i < 6; i++)
            {
              'at': DateTime(2026, 4, 20 + (i ~/ 2), 10 + i)
                  .millisecondsSinceEpoch,
              'kind': i.isEven ? 'type1Normal' : 'type2Normal',
              'score': 28 + i,
              'total': 40,
              'wrong_ids': [for (var j = 0; j < 40 - (28 + i); j++) i * 10 + j],
            },
        ],
        userAnswerStats: {
          for (var i = 1; i <= 14; i++)
            '$i': {
              'a': 4 + (i % 3),
              'c': (i % 4),
              'oc': [i % 2, 1, 0, (i + 1) % 2],
            },
        },
      );
      await tester.pumpWidget(wrapForGolden(const StatsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/stats_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('mock_history_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs(
        mockExamHistory: [
          for (var i = 0; i < 5; i++)
            {
              'at': DateTime(2026, 4, 20 + (i ~/ 2), 10 + i)
                  .millisecondsSinceEpoch,
              'kind': ['type1Large', 'type1Special', 'type1Normal', 'type2Normal'][i % 4],
              'score': 25 + i,
              'total': 40,
              'wrong_ids': [for (var j = 0; j < 40 - (25 + i); j++) j],
            },
        ],
      );
      await tester.pumpWidget(wrapForGolden(const MockExamHistoryScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mock_history_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ─── 가이드 / 실격 기준 ─────────────────────────────────────────────────
  group('guides', () {
    testWidgets('exam_guide_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester.pumpWidget(wrapForGolden(const ExamGuideScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/exam_guide_ko_light.png'),
      );
    });

    testWidgets('disqualification_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      final catalog = _fakeDisqualificationCatalog();
      await tester.pumpWidget(
        wrapForGolden(DisqualificationDetailScreen(catalog: catalog)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/disqualification_ko_light.png'),
      );
    });
  });

  // ─── 퀴즈 화면 ──────────────────────────────────────────────────────────
  group('quiz', () {
    testWidgets('practice_single_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester.pumpWidget(
        wrapForGolden(
          QuizScreen(
            questions: [makeSingleChoiceQuestion()],
            title: '어린이·노인·장애인 보호',
            showTimerAndScore: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/quiz_practice_single_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('practice_answered_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester.pumpWidget(
        wrapForGolden(
          QuizScreen(
            questions: [makeSingleChoiceQuestion()],
            title: '어린이·노인·장애인 보호',
            showTimerAndScore: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // 첫 번째 보기("시속 30킬로미터 이하") = 정답 탭 → 해설 노출
      await tester.tap(find.text('시속 30킬로미터 이하'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/quiz_practice_answered_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('mock_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      await tester.pumpWidget(
        wrapForGolden(
          QuizScreen(
            questions: [makeSingleChoiceQuestion()],
            showTimerAndScore: true,
            mockExamLicenseKind: MockExamLicenseKind.type1Normal,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/quiz_mock_ko_light.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ─── 결과 화면 ──────────────────────────────────────────────────────────
  group('result', () {
    testWidgets('practice_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      final results = _fakeResults(correct: 7, totalMisses: 3);
      await tester.pumpWidget(
        wrapForGolden(
          ResultScreen(
            score: 7,
            total: 10,
            results: results,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/result_practice_ko_light.png'),
      );
    });

    testWidgets('mock_pass_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      final results = _fakeResults(correct: 32, totalMisses: 8);
      await tester.pumpWidget(
        wrapForGolden(
          ResultScreen(
            score: 32,
            total: 40,
            results: results,
            mockExamLicenseKind: MockExamLicenseKind.type1Normal,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/result_mock_pass_ko_light.png'),
      );
    });

    testWidgets('mock_fail_ko_light', (tester) async {
      await setGoldenDefaults(tester);
      seedPrefs();
      final results = _fakeResults(correct: 24, totalMisses: 16);
      await tester.pumpWidget(
        wrapForGolden(
          ResultScreen(
            score: 24,
            total: 40,
            results: results,
            mockExamLicenseKind: MockExamLicenseKind.type1Normal,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/result_mock_fail_ko_light.png'),
      );
    });
  });
}

// ─── 헬퍼 ───────────────────────────────────────────────────────────────

DisqualificationCatalog _fakeDisqualificationCatalog() {
  return DisqualificationCatalog(
    drivingTitle: '기능시험 실격기준',
    drivingSource: 'https://www.safedriving.or.kr',
    drivingCategories: [
      DrivingDisqualCategory(
        licenseType: '1종 대형·1종 보통·1종 특수',
        criteria: const [
          DisqualCriterion(
            number: 1,
            text: '운전 조작 미숙으로 안전사고를 일으킬 우려가 있는 경우',
          ),
          DisqualCriterion(
            number: 2,
            text: '시험 중 2회 이상 출발 불능이거나 운전 미숙으로 종료 지점까지 이르지 못한 경우',
          ),
          DisqualCriterion(
            number: 3,
            text: '특별한 사유 없이 지시된 시험 항목을 수행하지 않거나 임의로 시험 진로를 이탈한 경우',
          ),
        ],
      ),
      DrivingDisqualCategory(
        licenseType: '2종 보통·2종 소형',
        criteria: const [
          DisqualCriterion(
            number: 1,
            text: '시험 시작 전 지시 사항을 따르지 않거나 검지선 위로 주차 상태를 유지하지 못한 경우',
          ),
          DisqualCriterion(
            number: 2,
            text: '경사로·가속구간에서 차량이 뒤로 1m 이상 밀리는 경우',
          ),
        ],
      ),
    ],
    roadTitle: '도로주행시험 실격기준',
    roadSource: 'https://www.safedriving.or.kr',
    roadApplicableTypes: const ['1종 보통', '2종 보통'],
    roadItems: const [
      DisqualCriterion(
        number: 1,
        text: '3회 이상 출발이 지체되어 시험에 지장을 주는 경우',
      ),
      DisqualCriterion(
        number: 2,
        text: '안전벨트를 착용하지 않고 시험에 응시하거나 시험 중 벗는 경우',
      ),
      DisqualCriterion(
        number: 3,
        text: '신호를 위반하거나 중앙선 침범, 보도 침범을 한 경우',
      ),
    ],
  );
}

List<SessionResult> _fakeResults({
  required int correct,
  required int totalMisses,
}) {
  final results = <SessionResult>[];
  for (var i = 0; i < correct; i++) {
    final q = makeSingleChoiceQuestion(
      id: 1000 + i,
      question: '정답 맞힌 문항 예시 ${i + 1}',
    );
    results.add(
      SessionResult(
        questionId: q.id,
        question: q,
        selectedIndices: const [0],
        isCorrect: true,
      ),
    );
  }
  for (var i = 0; i < totalMisses; i++) {
    final q = makeSingleChoiceQuestion(
      id: 2000 + i,
      question:
          '어린이보호구역에서 시속 40킬로미터로 주행한 운전자의 과태료와 벌점은?',
      options: const [
        '과태료 7만원, 벌점 15점',
        '과태료 9만원, 벌점 15점',
        '과태료 13만원, 벌점 30점',
        '과태료 16만원, 벌점 30점',
      ],
      answerIndex: 2,
      explanation:
          '어린이 보호구역에서 시속 20km 초과 40km 이하로 과속한 경우 승용 기준 과태료 13만원·벌점 30점이 부과됩니다.',
    );
    results.add(
      SessionResult(
        questionId: q.id,
        question: q,
        selectedIndices: i.isEven ? const [1] : const <int>[],
        isCorrect: false,
      ),
    );
  }
  return results;
}
