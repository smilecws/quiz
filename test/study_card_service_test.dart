import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/study_card.dart';
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

        if (card.topics.isNotEmpty) {
          final totalSlides =
              card.topics.fold<int>(0, (a, t) => a + t.slides.length);
          expect(totalSlides, greaterThanOrEqualTo(3),
              reason: '$id 슬라이드 총 3개 미만');
        } else {
          expect(card.legacyKeyPoints.length, greaterThanOrEqualTo(3),
              reason: '$id key_points 3개 미만');
          expect(card.legacyNumbers.length, greaterThanOrEqualTo(2),
              reason: '$id numbers 2개 미만');
        }

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

    test('슬라이드 / key_points 본문이 비어있지 않다', () async {
      for (final id in SubcategoryIds.verbalSubcategoryIds) {
        final card = await StudyCardService.loadCard(id);
        if (card!.topics.isNotEmpty) {
          for (final t in card.topics) {
            expect(t.labelFor('ko'), isNotEmpty,
                reason: '$id topic ${t.id} label 비어있음');
            expect(t.slides, isNotEmpty,
                reason: '$id topic ${t.id} slides 비어있음');
            for (final s in t.slides) {
              switch (s) {
                case ContentSlide():
                  expect(s.titleFor('ko'), isNotEmpty,
                      reason: '$id ${t.id} content title 비어있음');
                  expect(s.bodyFor('ko'), isNotEmpty,
                      reason: '$id ${t.id} content body 비어있음');
                case SummarySlide():
                  expect(s.titleFor('ko'), isNotEmpty,
                      reason: '$id ${t.id} summary title 비어있음');
                  expect(s.items, isNotEmpty,
                      reason: '$id ${t.id} summary items 비어있음');
              }
            }
          }
        } else {
          for (final kp in card.legacyKeyPoints) {
            expect(kp.headingFor('ko'), isNotEmpty, reason: '$id heading 비어있음');
            expect(kp.bodyFor('ko'), isNotEmpty, reason: '$id body 비어있음');
          }
        }
      }
    });

    test('summary 슬라이드 / numbers 라벨·값이 비어있지 않다', () async {
      for (final id in SubcategoryIds.verbalSubcategoryIds) {
        final card = await StudyCardService.loadCard(id);
        if (card!.topics.isNotEmpty) {
          for (final t in card.topics) {
            for (final s in t.slides) {
              if (s is SummarySlide) {
                for (final it in s.items) {
                  expect(it.labelFor('ko'), isNotEmpty,
                      reason: '$id ${t.id} summary item label 비어있음');
                  expect(it.valueFor('ko'), isNotEmpty,
                      reason: '$id ${t.id} summary item value 비어있음');
                }
              }
            }
          }
        } else {
          for (final n in card.legacyNumbers) {
            expect(n.labelFor('ko'), isNotEmpty, reason: '$id number label 비어있음');
            expect(n.valueFor('ko'), isNotEmpty, reason: '$id number value 비어있음');
          }
        }
      }
    });

    test('존재하지 않는 태그는 null 반환', () async {
      final card = await StudyCardService.loadCard('nonexistent');
      expect(card, isNull);
    });
  });
}
