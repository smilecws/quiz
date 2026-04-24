import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/services/subcategory_classifier.dart';

void main() {
  group('classifySubcategory', () {
    test('표지 및 상황문제 상위 카테고리는 그대로 유지', () {
      final tag = classifySubcategory(
        rawCategory: '표지 및 상황문제',
        questionText: '다음 표지판의 의미로 맞는 것은?',
        explanationText: '황색 실선 표시',
      );
      expect(tag, SubcategoryIds.signSituation);
    });

    test('동영상 문제 상위 카테고리는 그대로 유지', () {
      final tag = classifySubcategory(
        rawCategory: '동영상 문제',
        questionText: '다음 영상에서 운전자가 취해야 할 행동은?',
        explanationText: '',
      );
      expect(tag, SubcategoryIds.video);
    });

    test('음주 키워드 → alcohol', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '혈중알코올농도 0.03% 이상으로 운전한 경우의 처벌은?',
        explanationText: '음주운전 단속 기준을 따른다.',
      );
      expect(tag, SubcategoryIds.alcohol);
    });

    test('어린이 보호구역 → child_zone', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '어린이보호구역에서 지켜야 할 제한속도는?',
        explanationText: '스쿨존 내 제한속도는 30km/h.',
      );
      expect(tag, SubcategoryIds.childZone);
    });

    test('응급처치 → emergency', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '교통사고 발생 시 부상자에 대한 응급처치 방법은?',
        explanationText: '심폐소생술 순서는 CAB 이다.',
      );
      expect(tag, SubcategoryIds.emergency);
    });

    test('벌점/과태료 → license', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '신호위반 시 부과되는 벌점과 범칙금은?',
        explanationText: '벌점 15점, 범칙금 6만원.',
      );
      expect(tag, SubcategoryIds.license);
    });

    test('신호등 → sign_signal', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '교차로에서 황색신호가 점등되었을 때 운전 요령은?',
        explanationText: '정지선 직전에 정지한다.',
      );
      expect(tag, SubcategoryIds.signSignal);
    });

    test('앞지르기 → speed_lane', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '앞지르기가 금지된 장소는?',
        explanationText: '터널 안, 교차로, 다리 위.',
      );
      // "터널" 이 highway 키워드라 highway 로 갈 수도 있다.
      // 규칙 우선순위: speed_lane(6) < highway(8). speed_lane 이 먼저.
      expect(tag, SubcategoryIds.speedLane);
    });

    test('주차·정차 → parking', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '주차금지 장소가 아닌 곳은?',
        explanationText: '소화전 5m 이내는 주정차 금지.',
      );
      expect(tag, SubcategoryIds.parking);
    });

    test('고속도로 → highway', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '고속도로에서 긴급자동차 통행 시 양보 방법은?',
        explanationText: '갓길로 진로를 양보한다.',
      );
      expect(tag, SubcategoryIds.highway);
    });

    test('친환경·차량장치 → vehicle_eco', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '전기자동차의 연비 효율을 높이는 운전 방법은?',
        explanationText: '급가속을 피하고 친환경 운전 습관을 들인다.',
      );
      expect(tag, SubcategoryIds.vehicleEco);
    });

    test('어떤 키워드에도 안 걸리면 → general', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '도로의 정의에 포함되지 않는 것은?',
        explanationText: '도로교통법 제2조.',
      );
      expect(tag, SubcategoryIds.general);
    });

    test('우선순위: 음주운전 + 고속도로 모두 포함 시 alcohol 가 이김', () {
      final tag = classifySubcategory(
        rawCategory: '말문제',
        questionText: '음주운전으로 고속도로에서 단속된 경우의 처벌은?',
        explanationText: '혈중알코올 기준 적용.',
      );
      expect(tag, SubcategoryIds.alcohol);
    });
  });
}
