import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Main home shows landing with 학습하기 / 문제 풀기', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const QuizApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('초심찾기 도로교통법'), findsOneWidget);
    expect(find.text('학습하기'), findsOneWidget);
    expect(find.text('문제 풀기'), findsOneWidget);
  });
}
