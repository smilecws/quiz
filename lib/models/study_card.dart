/// 학습 카드 데이터 모델. `assets/study/<tag>.json` 스키마와 1:1 대응합니다.
///
/// 모든 표시 문자열은 `{ "ko": "...", "en": "...", ... }` 형태의 LocalizedText
/// 맵으로 저장되어, UI 언어에 맞춰 꺼내 씁니다. 특정 언어 번역이 없으면 ko 로 폴백.
///
/// schema_version
///  - 1: 평면 key_points / numbers. (구버전 — 화면에서 단일 "전체" 토픽으로 자동 변환)
///  - 2: topics[] 안에 slides[] (content/summary) — 카드뉴스 형태.
/// 두 버전 모두 같은 [StudyCard.fromJson] 으로 파싱되며, 신버전이 없으면
/// 화면 측이 구버전 필드를 슬라이드로 변환합니다.
library;

import 'package:flutter/material.dart';

typedef LocalizedText = Map<String, String>;

String _t(LocalizedText m, String languageCode) =>
    m[languageCode] ?? m['ko'] ?? '';

class StudyCard {
  const StudyCard({
    required this.subcategoryId,
    required this.title,
    required this.lead,
    required this.topics,
    required this.legacyKeyPoints,
    required this.legacyNumbers,
    required this.exampleQuestionIds,
  });

  final String subcategoryId;
  final LocalizedText title;
  final LocalizedText lead;

  /// 카드뉴스 토픽. schema v2 에서만 채워집니다.
  /// 비어 있으면 화면은 [legacyKeyPoints] / [legacyNumbers] 를
  /// 단일 토픽의 슬라이드 시퀀스로 자동 변환합니다.
  final List<StudyTopic> topics;

  /// schema v1 호환용 평면 핵심 포인트.
  final List<LegacyKeyPoint> legacyKeyPoints;

  /// schema v1 호환용 평면 수치 표.
  final List<LegacyNumber> legacyNumbers;

  final List<int> exampleQuestionIds;

  String titleFor(String lang) => _t(title, lang);
  String leadFor(String lang) => _t(lead, lang);

  factory StudyCard.fromJson(Map<String, dynamic> j) {
    return StudyCard(
      subcategoryId: j['subcategory_id'] as String,
      title: _asLocalized(j['title']),
      lead: _asLocalized(j['lead']),
      topics: (j['topics'] as List? ?? const [])
          .map((e) => StudyTopic.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      legacyKeyPoints: (j['key_points'] as List? ?? const [])
          .map((e) =>
              LegacyKeyPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      legacyNumbers: (j['numbers'] as List? ?? const [])
          .map((e) =>
              LegacyNumber.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      exampleQuestionIds: (j['example_question_ids'] as List? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}

class StudyTopic {
  const StudyTopic({
    required this.id,
    required this.label,
    required this.desc,
    required this.accent,
    required this.slides,
  });

  final String id;
  final LocalizedText label;
  final LocalizedText desc;

  /// 토픽 강조색. JSON 에는 `"#22c55e"` 같은 hex 문자열로 저장.
  /// 다크 모드에서도 동일 색을 그대로 사용 (모두 충분한 대비를 가진 채도).
  final Color accent;

  final List<StudySlide> slides;

  String labelFor(String lang) => _t(label, lang);
  String descFor(String lang) => _t(desc, lang);

  factory StudyTopic.fromJson(Map<String, dynamic> j) {
    return StudyTopic(
      id: j['id'] as String,
      label: _asLocalized(j['label']),
      desc: _asLocalized(j['desc']),
      accent: _parseHexColor(j['accent'] as String? ?? '#22c55e'),
      slides: (j['slides'] as List? ?? const [])
          .map((e) => StudySlide.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

sealed class StudySlide {
  const StudySlide();

  factory StudySlide.fromJson(Map<String, dynamic> j) {
    final type = (j['type'] as String? ?? 'content').toLowerCase();
    if (type == 'summary') return SummarySlide.fromJson(j);
    return ContentSlide.fromJson(j);
  }
}

class ContentSlide extends StudySlide {
  const ContentSlide({
    required this.tag,
    required this.title,
    required this.highlight,
    required this.body,
    required this.note,
  });

  final LocalizedText tag;
  final LocalizedText title;

  /// 강조 박스 텍스트. 비어 있으면 표시하지 않음.
  final LocalizedText highlight;
  final LocalizedText body;

  /// 슬라이드 하단 안내. 비어 있으면 표시하지 않음.
  final LocalizedText note;

  String tagFor(String lang) => _t(tag, lang);
  String titleFor(String lang) => _t(title, lang);
  String highlightFor(String lang) => _t(highlight, lang);
  String bodyFor(String lang) => _t(body, lang);
  String noteFor(String lang) => _t(note, lang);

  factory ContentSlide.fromJson(Map<String, dynamic> j) {
    return ContentSlide(
      tag: _asLocalized(j['tag']),
      title: _asLocalized(j['title']),
      highlight: _asLocalized(j['highlight']),
      body: _asLocalized(j['body']),
      note: _asLocalized(j['note']),
    );
  }
}

class SummarySlide extends StudySlide {
  const SummarySlide({
    required this.title,
    required this.items,
    required this.lawRefs,
  });

  final LocalizedText title;
  final List<SummaryItem> items;
  final List<String> lawRefs;

  String titleFor(String lang) => _t(title, lang);

  factory SummarySlide.fromJson(Map<String, dynamic> j) {
    return SummarySlide(
      title: _asLocalized(j['title']),
      items: (j['items'] as List? ?? const [])
          .map((e) => SummaryItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      lawRefs: (j['law_refs'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class SummaryItem {
  const SummaryItem({required this.label, required this.value});

  final LocalizedText label;
  final LocalizedText value;

  String labelFor(String lang) => _t(label, lang);
  String valueFor(String lang) => _t(value, lang);

  factory SummaryItem.fromJson(Map<String, dynamic> j) {
    return SummaryItem(
      label: _asLocalized(j['label']),
      value: _asLocalized(j['value']),
    );
  }
}

/// schema v1 호환: 평면 핵심 포인트. v2 토픽이 없으면 화면이 이를 슬라이드로 변환.
class LegacyKeyPoint {
  const LegacyKeyPoint({
    required this.heading,
    required this.body,
    required this.lawRefs,
  });

  final LocalizedText heading;
  final LocalizedText body;
  final List<String> lawRefs;

  String headingFor(String lang) => _t(heading, lang);
  String bodyFor(String lang) => _t(body, lang);

  factory LegacyKeyPoint.fromJson(Map<String, dynamic> j) {
    return LegacyKeyPoint(
      heading: _asLocalized(j['heading']),
      body: _asLocalized(j['body']),
      lawRefs: (j['law_refs'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class LegacyNumber {
  const LegacyNumber({required this.label, required this.value});

  final LocalizedText label;
  final LocalizedText value;

  String labelFor(String lang) => _t(label, lang);
  String valueFor(String lang) => _t(value, lang);

  factory LegacyNumber.fromJson(Map<String, dynamic> j) {
    return LegacyNumber(
      label: _asLocalized(j['label']),
      value: _asLocalized(j['value']),
    );
  }
}

LocalizedText _asLocalized(dynamic v) {
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val.toString()));
  }
  if (v == null) return const {'ko': ''};
  return {'ko': v.toString()};
}

Color _parseHexColor(String hex) {
  var s = hex.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  final v = int.tryParse(s, radix: 16);
  if (v == null) return const Color(0xFF22C55E);
  return Color(v);
}
