import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/study_card.dart';

/// `assets/study/<tag>.json` 을 로드해 캐싱합니다. 태그와 파일명이 1:1 이어야 합니다.
class StudyCardService {
  StudyCardService._();

  static final Map<String, StudyCard> _cache = {};

  static Future<StudyCard?> loadCard(String subcategoryId) async {
    final cached = _cache[subcategoryId];
    if (cached != null) return cached;
    try {
      final raw = await rootBundle.loadString(
        'assets/study/$subcategoryId.json',
      );
      final card = StudyCard.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      _cache[subcategoryId] = card;
      return card;
    } catch (_) {
      return null;
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}
