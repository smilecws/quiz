import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/services/study_card_service.dart';
import 'package:quiz_app/services/subcategory_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(StudyCardService.clearCache);

  group('StudyCardService', () {
    test('10개 태그 전부 로드 성공, 필수 필드 존재', () async {
      for (final id in SubcategoryIds.verbalSubcategoryIds) {
        final card = await StudyCardService.loadCard(id);
        expect(card, isNotNull, reason: '$id 로드 실패');
        expect(card!.subcategoryId, id);
        expect(card.titleFor('ko'), isNotEmpty, reason: '$id title ko 비어있음');
        expect(card.leadFor('ko'), isNotEmpty, reason: '$id lead ko 비어있음');
        expect(card.keyPoints.length, greaterThanOrEqualTo(3),
            reason: '$id key_points 3개 미만');
        expect(card.numbers.length, greaterThanOrEqualTo(2),
            reason: '$id numbers 2개 미만');
        expect(card.exampleQuestionIds.length, greaterThanOrEqualTo(1),
            reason: '$id example_question_ids 비어있음');
      }
    });

    test('example_question_ids 가 1..1000 범위 내', () async {
      for (final id in SubcategoryIds.verbalSubcategoryIds) {
        final card = await StudyCardService.loadCard(id);
        for (final qn in card!.exampleQuestionIds) {
          expect(qn, inInclusiveRange(1, 1000),
              reason: '$id 의 Q$qn 이 유효 범위 밖');
        }
      }
    });

    test('key_points 각 항목에 heading / body 가 비어있지 않다', () async {
      for (final id in SubcategoryIds.verbalSubcategoryIds) {
        final card = await StudyCardService.loadCard(id);
        for (final kp in card!.keyPoints) {
          expect(kp.headingFor('ko'), isNotEmpty, reason: '$id heading 비어있음');
          expect(kp.bodyFor('ko'), isNotEmpty, reason: '$id body 비어있음');
        }
      }
    });

    test('numbers 각 항목에 label / value 가 비어있지 않다', () async {
      for (final id in SubcategoryIds.verbalSubcategoryIds) {
        final card = await StudyCardService.loadCard(id);
        for (final n in card!.numbers) {
          expect(n.labelFor('ko'), isNotEmpty, reason: '$id number label 비어있음');
          expect(n.valueFor('ko'), isNotEmpty, reason: '$id number value 비어있음');
        }
      }
    });

    test('존재하지 않는 태그는 null 반환', () async {
      final card = await StudyCardService.loadCard('nonexistent');
      expect(card, isNull);
    });
  });
}
