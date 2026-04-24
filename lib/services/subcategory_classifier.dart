/// 말문제 소카테고리 자동 분류 규칙.
///
/// - 원본 category 가 "표지 및 상황문제" / "동영상 문제" 이면 해당 상위 태그 반환.
/// - 그 외(= 말문제)는 [_rules] 를 우선순위 순으로 순회하며 질문·해설·보기에
///   키워드가 하나라도 포함되면 해당 태그로 확정한다 (첫 매치 승).
/// - 어느 규칙에도 걸리지 않으면 [SubcategoryIds.general].
///
/// 분류기는 순수 Dart 라이브러리로 유지해 `tool/classify_subcategory.dart` CLI
/// 와 단위 테스트 양쪽에서 재사용한다.
library;

class SubcategoryIds {
  SubcategoryIds._();

  static const alcohol = 'alcohol';
  static const childZone = 'child_zone';
  static const emergency = 'emergency';
  static const license = 'license';
  static const signSignal = 'sign_signal';
  static const speedLane = 'speed_lane';
  static const parking = 'parking';
  static const highway = 'highway';
  static const vehicleEco = 'vehicle_eco';
  static const general = 'general';

  /// 상위 카테고리 그대로 유지되는 태그
  static const signSituation = 'sign_situation';
  static const video = 'video';

  /// 연습 메뉴 '말문제' 하위에 노출할 소카테고리 (우선순위 순)
  static const verbalSubcategoryIds = <String>[
    alcohol,
    childZone,
    emergency,
    license,
    signSignal,
    speedLane,
    parking,
    highway,
    vehicleEco,
    general,
  ];
}

/// (태그 ID, 키워드 리스트) 쌍을 우선순위 순서대로 나열한다.
/// 키워드 하나라도 텍스트에 포함되면 해당 태그로 매칭된다.
const List<(String, List<String>)> _rules = [
  (SubcategoryIds.alcohol, [
    '음주',
    '혈중알코올',
    '대마',
    '마약',
    '약물운전',
    '약물 운전',
  ]),
  (SubcategoryIds.childZone, [
    '어린이보호구역',
    '어린이 보호구역',
    '스쿨존',
    '노인보호구역',
    '노인 보호구역',
    '장애인보호구역',
    '장애인 보호구역',
    '어린이통학버스',
    '어린이 통학버스',
  ]),
  (SubcategoryIds.emergency, [
    '응급처치',
    '심폐소생',
    '2차 사고',
    '이차 사고',
    '구호조치',
    '구호 조치',
    '사상자',
    '부상자',
    '응급환자',
    '지혈',
    '기도 확보',
    '골절',
    '사고 발생',
    '사고 시',
    '사고가 발생',
    '사고 현장',
    '인명 보호',
    '긴급구난',
  ]),
  (SubcategoryIds.license, [
    '벌점',
    '과태료',
    '범칙금',
    '면허정지',
    '면허 정지',
    '면허취소',
    '면허 취소',
    '행정처분',
    '운전면허증',
    '운전면허',
  ]),
  (SubcategoryIds.signSignal, [
    '신호등',
    '교통신호',
    '신호기',
    '노면표시',
    '노면 표시',
    '교통안전표지',
    '안전표지',
    '점선',
    '실선',
    '황색',
    '적색',
    '녹색 등화',
    '녹색등화',
  ]),
  (SubcategoryIds.speedLane, [
    '제한속도',
    '제한 속도',
    '최고속도',
    '최저속도',
    '앞지르기',
    '진로변경',
    '진로 변경',
    '차로',
    '차선',
    '추월',
  ]),
  (SubcategoryIds.parking, [
    '주차금지',
    '정차금지',
    '주·정차',
    '주정차',
    '주차장',
    '주차할',
    '주차한',
    '정차할',
    '정차한',
    '견인',
  ]),
  (SubcategoryIds.highway, [
    '고속도로',
    '자동차전용도로',
    '자동차 전용도로',
    '긴급자동차',
    '긴급 자동차',
    '소방차',
    '구급차',
    '갓길',
    '톨게이트',
    '요금소',
    '하이패스',
    '휴게소',
    '터널',
  ]),
  (SubcategoryIds.vehicleEco, [
    '친환경',
    '연비',
    '전기자동차',
    '전기차',
    '하이브리드',
    '차량점검',
    '차량 점검',
    '엔진',
    '브레이크',
    '타이어',
  ]),
];

/// 한 문항의 소카테고리를 결정한다. 상위 카테고리가 "말문제" 가 아닌 경우는
/// 원본 카테고리 그대로 반환한다.
///
/// [rawCategory] 는 문항 JSON 의 `category` 값 (말문제 / 표지 및 상황문제 / 동영상 문제).
/// [questionText] + [explanationText] + [choices] 를 합친 텍스트에 대해 규칙 매칭을 수행한다.
String classifySubcategory({
  required String rawCategory,
  required String questionText,
  required String explanationText,
  List<String> choices = const [],
}) {
  final normalized = rawCategory.trim();
  if (normalized == '표지 및 상황문제') return SubcategoryIds.signSituation;
  if (normalized == '동영상 문제') return SubcategoryIds.video;

  final combined = StringBuffer()
    ..writeln(questionText)
    ..writeln(explanationText);
  for (final c in choices) {
    combined.writeln(c);
  }
  final text = combined.toString();

  for (final rule in _rules) {
    final tag = rule.$1;
    final keywords = rule.$2;
    for (final kw in keywords) {
      if (text.contains(kw)) return tag;
    }
  }
  return SubcategoryIds.general;
}
