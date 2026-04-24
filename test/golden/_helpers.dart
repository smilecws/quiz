import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/app_settings_scope.dart';
import 'package:quiz_app/l10n/app_localizations.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/services/locale_service.dart';
import 'package:quiz_app/services/question_service.dart';
import 'package:quiz_app/services/question_subcategory_service.dart';
import 'package:quiz_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 골든 뷰포트 크기 (iPhone 13 근사값). DPR 1 → 동일 크기 PNG 가 나옵니다.
const Size goldenSurface = Size(390, 844);

/// 매 테스트 setUp 에 호출해 뷰포트·캐시 기본값을 세팅합니다.
/// Jua 폰트는 `google_fonts/Jua-Regular.ttf` 로컬 에셋을 씁니다 (네트워크 불필요).
Future<void> setGoldenDefaults(WidgetTester tester) async {
  GoogleFonts.config.allowRuntimeFetching = true;

  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = goldenSurface;
  await tester.binding.setSurfaceSize(goldenSurface);

  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    QuestionService.clearCache();
    QuestionSubcategoryService.clearCache();
  });
}

/// FontManifest.json 의 모든 폰트 패밀리를 FontLoader 로 등록합니다.
/// Flutter 위젯 테스트는 MaterialIcons 를 자동 등록하지 않아 아이콘이
/// 사각형으로 나오는 문제가 있어, 수동 로드로 해결합니다.
///
/// `setUpAll` 에 한 번만 호출하면 됩니다.
Future<void> loadAppFonts() async {
  final fontManifest = await rootBundle.loadStructuredData<Iterable<dynamic>>(
    'FontManifest.json',
    (string) async => json.decode(string) as Iterable<dynamic>,
  );

  for (final entry in fontManifest) {
    final font = Map<String, dynamic>.from(entry as Map);
    final loader = FontLoader(_derivedFamily(font));
    final fonts = (font['fonts'] as List).cast<Map>();
    for (final asset in fonts) {
      final path = asset['asset'] as String;
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }
}

/// FontManifest 가 packages/... 프리픽스로 들어오면 패밀리명을 조정.
String _derivedFamily(Map<String, dynamic> font) {
  final family = font['family'] as String;
  if (family.startsWith('packages/')) {
    final parts = family.split('/');
    return parts.length > 2 ? parts.sublist(2).join('/') : family;
  }
  return family;
}

/// 위젯이 rootBundle.loadString 등 비동기 I/O 를 끝낼 때까지
/// 실제 시간으로 기다립니다. 그 후 pump 로 프레임 갱신.
///
/// `tester.pump(duration)` 은 가짜 시계만 돌리고 실제 IO 는 안 기다리므로
/// asset 파싱 같은 작업에는 `runAsync` 가 필요합니다.
Future<void> settleAsync(
  WidgetTester tester, {
  Duration wait = const Duration(milliseconds: 600),
}) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(wait);
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Home 의 `_loadCounts` 가 1.5MB 문제 은행 JSON 을 파싱하므로 통계 카드가
/// 뜨기 전에 캡처되면 CircularProgressIndicator 가 남습니다. 테스트 pumpWidget
/// 전에 캐시를 미리 채워 Future.wait 가 즉시 resolve 되게 합니다.
Future<void> primeQuestionBankCache(WidgetTester tester) async {
  await tester.runAsync(() async {
    await QuestionService.loadAllQuestions();
    await QuestionSubcategoryService.loadMap();
  });
}

/// 스크린을 MaterialApp + 로컬라이저 + AppSettingsScope 로 감쌉니다. main.dart 와 동일 구조.
///
/// Jua 폰트에 없는 기호(`·` 가운뎃점 등)는 fontFamilyFallback 으로 시스템 폰트가
/// 담당하도록 기본 텍스트 테마에 폴백을 주입합니다.
Widget wrapForGolden(
  Widget child, {
  Locale locale = const Locale('ko'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  const fallback = <String>['Noto Sans CJK KR', 'Malgun Gothic', 'Arial'];
  final light = buildLightTheme();
  final dark = buildDarkTheme();
  return AppSettingsScope(
    setLocale: (_) {},
    themeMode: themeMode,
    setThemeMode: (_) {},
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      themeMode: themeMode,
      theme: light.copyWith(
        textTheme: _applyFallback(light.textTheme, fallback),
      ),
      darkTheme: dark.copyWith(
        textTheme: _applyFallback(dark.textTheme, fallback),
      ),
      supportedLocales: LocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

TextTheme _applyFallback(TextTheme base, List<String> fallback) {
  TextStyle? withFallback(TextStyle? s) =>
      s?.copyWith(fontFamilyFallback: fallback);
  return base.copyWith(
    displayLarge: withFallback(base.displayLarge),
    displayMedium: withFallback(base.displayMedium),
    displaySmall: withFallback(base.displaySmall),
    headlineLarge: withFallback(base.headlineLarge),
    headlineMedium: withFallback(base.headlineMedium),
    headlineSmall: withFallback(base.headlineSmall),
    titleLarge: withFallback(base.titleLarge),
    titleMedium: withFallback(base.titleMedium),
    titleSmall: withFallback(base.titleSmall),
    bodyLarge: withFallback(base.bodyLarge),
    bodyMedium: withFallback(base.bodyMedium),
    bodySmall: withFallback(base.bodySmall),
    labelLarge: withFallback(base.labelLarge),
    labelMedium: withFallback(base.labelMedium),
    labelSmall: withFallback(base.labelSmall),
  );
}

/// SharedPreferences 를 미리 seeding 합니다. 테스트 별로 호출.
void seedPrefs({
  int attemptedCount = 0,
  int favoritesCount = 0,
  int wrongCount = 0,
  String localeCode = 'ko',
  List<Map<String, dynamic>> mockExamHistory = const [],
  Map<String, Map<String, dynamic>> userAnswerStats = const {},
}) {
  final values = <String, Object>{
    'attempted_question_ids':
        List<String>.generate(attemptedCount, (i) => '$i'),
    'favorite_question_ids':
        List<String>.generate(favoritesCount, (i) => '$i'),
    'wrong_question_ids': List<String>.generate(wrongCount, (i) => '$i'),
    'app_locale_language_code': localeCode,
  };
  if (mockExamHistory.isNotEmpty) {
    values['mock_exam_history_json_v1'] = jsonEncode(mockExamHistory);
  }
  if (userAnswerStats.isNotEmpty) {
    values['user_answer_stats_v1'] = jsonEncode(userAnswerStats);
  }
  SharedPreferences.setMockInitialValues(values);
}

/// 테스트용 단일 선택 문항. 비디오·이미지 없이 안전하게 렌더 가능.
Question makeSingleChoiceQuestion({
  int id = 101,
  String question = '어린이 보호구역에서 제한속도는 얼마인가?',
  List<String> options = const [
    '시속 30킬로미터 이하',
    '시속 40킬로미터 이하',
    '시속 50킬로미터 이하',
    '시속 60킬로미터 이하',
  ],
  int answerIndex = 0,
  String explanation = '어린이 보호구역에서는 시속 30km 이하로 운행해야 하며, 위반 시 벌점과 과태료가 부과됩니다.',
  String? category = '말문제',
}) {
  return Question(
    id: id,
    question: question,
    options: options,
    correctIndices: [answerIndex],
    explanation: explanation,
    category: category,
  );
}

/// 테스트용 복수 선택 문항.
Question makeMultipleChoiceQuestion({
  int id = 202,
  String question = '교통사고 발생 시 운전자가 해야 하는 조치를 모두 고르시오.',
  List<String> options = const [
    '즉시 정차하여 사상자를 구호한다',
    '신속히 현장을 벗어나 경찰에 자진 출석한다',
    '경찰공무원에게 사고 내용을 신고한다',
    '피해자 신원과 연락처를 확인해 교환한다',
  ],
  List<int> answerIndices = const [0, 2, 3],
  String explanation = '도로교통법 제54조에 따라 사상자 구호·신고·연락처 교환 의무가 있으며, 도주는 금지됩니다.',
}) {
  return Question(
    id: id,
    question: question,
    options: options,
    correctIndices: answerIndices,
    explanation: explanation,
    category: '말문제',
  );
}
