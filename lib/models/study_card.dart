/// 학습 카드 데이터 모델. `assets/study/<tag>.json` 스키마와 1:1 대응합니다.
///
/// 모든 표시 문자열은 `{ "ko": "...", "en": "...", ... }` 형태의 LocalizedText
/// 맵으로 저장되어, UI 언어에 맞춰 꺼내 씁니다. 특정 언어 번역이 없으면 ko 로 폴백.
library;

typedef LocalizedText = Map<String, String>;

String _t(LocalizedText m, String languageCode) =>
    m[languageCode] ?? m['ko'] ?? '';

class StudyCard {
  const StudyCard({
    required this.subcategoryId,
    required this.title,
    required this.lead,
    required this.keyPoints,
    required this.numbers,
    required this.exampleQuestionIds,
  });

  final String subcategoryId;
  final LocalizedText title;
  final LocalizedText lead;
  final List<KeyPoint> keyPoints;
  final List<NumberEntry> numbers;
  final List<int> exampleQuestionIds;

  String titleFor(String lang) => _t(title, lang);
  String leadFor(String lang) => _t(lead, lang);

  factory StudyCard.fromJson(Map<String, dynamic> j) {
    return StudyCard(
      subcategoryId: j['subcategory_id'] as String,
      title: _asLocalized(j['title']),
      lead: _asLocalized(j['lead']),
      keyPoints: (j['key_points'] as List? ?? const [])
          .map((e) => KeyPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      numbers: (j['numbers'] as List? ?? const [])
          .map((e) => NumberEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      exampleQuestionIds: (j['example_question_ids'] as List? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}

class KeyPoint {
  const KeyPoint({
    required this.heading,
    required this.body,
    required this.lawRefs,
  });

  final LocalizedText heading;
  final LocalizedText body;
  final List<String> lawRefs;

  String headingFor(String lang) => _t(heading, lang);
  String bodyFor(String lang) => _t(body, lang);

  factory KeyPoint.fromJson(Map<String, dynamic> j) {
    return KeyPoint(
      heading: _asLocalized(j['heading']),
      body: _asLocalized(j['body']),
      lawRefs: (j['law_refs'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class NumberEntry {
  const NumberEntry({required this.label, required this.value});

  final LocalizedText label;
  final LocalizedText value;

  String labelFor(String lang) => _t(label, lang);
  String valueFor(String lang) => _t(value, lang);

  factory NumberEntry.fromJson(Map<String, dynamic> j) {
    return NumberEntry(
      label: _asLocalized(j['label']),
      value: _asLocalized(j['value']),
    );
  }
}

LocalizedText _asLocalized(dynamic v) {
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val.toString()));
  }
  return {'ko': (v ?? '').toString()};
}
