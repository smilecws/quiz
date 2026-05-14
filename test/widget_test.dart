import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Main home shows landing with 학습하기 / 문제 풀기', (tester) async {
    // 동의 게이트와 eco intro 를 우회하기 위해 미리 기록을 채워둔다.
    SharedPreferences.setMockInitialValues({
      'user_consent_v1': jsonEncode({
        'name': 'tester',
        'grantedAt': DateTime.now().toUtc().toIso8601String(),
        'version': 3,
      }),
      'eco_intro_shown_v1': true,
    });
    await tester.pumpWidget(const QuizApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('초심찾기 도로교통법'), findsOneWidget);
    expect(find.text('학습하기'), findsOneWidget);
    expect(find.text('문제 풀기'), findsOneWidget);
  });
}
