import 'dart:convert';

import 'package:flutter/services.dart';

/// `assets/question_subcategory.json` (문항 ID → 소카테고리 태그) 를 로드해
/// 메모리에 캐싱합니다.
///
/// 매핑은 한국어 JSON 을 기준으로 사전 계산되어 있어 UI 언어와 무관하게
/// 동일한 문항 ID 가 동일한 태그를 갖습니다. 매핑 재생성은
/// `tool/classify_subcategory.dart` 로만 수행합니다.
class QuestionSubcategoryService {
  QuestionSubcategoryService._();

  static const _assetPath = 'assets/question_subcategory.json';

  static Map<int, String>? _cache;

  /// 문항 ID → 태그 맵을 반환합니다. 첫 호출 시 에셋을 로드합니다.
  static Future<Map<int, String>> loadMap() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    final map = <int, String>{};
    if (decoded is Map<String, dynamic>) {
      decoded.forEach((key, value) {
        final id = int.tryParse(key);
        if (id != null && value is String) {
          map[id] = value;
        }
      });
    }
    _cache = map;
    return map;
  }

  /// 태그별 문항 수 (UI 에 버킷 크기를 노출할 때 사용).
  static Future<Map<String, int>> loadCounts() async {
    final map = await loadMap();
    final counts = <String, int>{};
    for (final tag in map.values) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
    return counts;
  }

  /// 테스트·에셋 교체 시 캐시 초기화.
  static void clearCache() {
    _cache = null;
  }
}
