import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 개별 문항 통계 (aggregates.json 의 all_questions 에서 조회)
// ─────────────────────────────────────────────────────────────────────────────

/// 한 문항의 익명 집계 통계.
class GlobalQuestionStat {
  final int questionId;
  final int attempts;
  final int correct;

  /// 보기별 선택 횟수. key = 0-based 인덱스.
  final Map<int, int> optionCounts;

  const GlobalQuestionStat({
    required this.questionId,
    required this.attempts,
    required this.correct,
    required this.optionCounts,
  });

  double get accuracyRate => attempts > 0 ? correct / attempts : 0;
  int get wrongCount => attempts - correct;
}

// ─────────────────────────────────────────────────────────────────────────────
// 사전 집계 결과 (aggregates.json)
// ─────────────────────────────────────────────────────────────────────────────

/// `hardest_top10[]` 한 항목.
class AggregateHardestEntry {
  final int questionId;
  final int attempts;
  final int correct;
  final double wrongRate;

  const AggregateHardestEntry({
    required this.questionId,
    required this.attempts,
    required this.correct,
    required this.wrongRate,
  });

  int get wrongCount => attempts - correct;
}

/// `subcategory.{tag}` 한 항목.
class SubcategoryAggregate {
  final String tag;
  final int attempts;
  final int correct;

  const SubcategoryAggregate({
    required this.tag,
    required this.attempts,
    required this.correct,
  });

  double get accuracyRate => attempts > 0 ? correct / attempts : 0;
  int get wrongCount => attempts - correct;
}

/// `all_questions` 한 항목.
class AllQuestionAggregate {
  final int questionId;
  final int attempts;
  final int correct;
  final double wrongRate;

  /// 보기별 선택 횟수. key = 0-based 인덱스.
  final Map<int, int> optionCounts;

  const AllQuestionAggregate({
    required this.questionId,
    required this.attempts,
    required this.correct,
    required this.wrongRate,
    this.optionCounts = const {},
  });
}

/// GitHub Actions 가 생성한 `aggregates.json` 파싱 결과.
class GlobalAggregateStats {
  final DateTime? updatedAt;
  final List<AggregateHardestEntry> hardestTop10;
  final List<SubcategoryAggregate> subcategory;
  final Map<int, AllQuestionAggregate> allQuestions;

  const GlobalAggregateStats({
    this.updatedAt,
    this.hardestTop10 = const [],
    this.subcategory = const [],
    this.allQuestions = const {},
  });

  static const empty = GlobalAggregateStats();

  factory GlobalAggregateStats.fromJson(Map<String, dynamic> json) {
    DateTime? updatedAt;
    final rawDate = json['updated_at'];
    if (rawDate is String && rawDate.isNotEmpty) {
      updatedAt = DateTime.tryParse(rawDate);
    }

    final hardest = <AggregateHardestEntry>[];
    final rawList = json['hardest_top10'];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is! Map) continue;
        hardest.add(AggregateHardestEntry(
          questionId: (item['question_id'] as num?)?.toInt() ?? 0,
          attempts: (item['attempts'] as num?)?.toInt() ?? 0,
          correct: (item['correct'] as num?)?.toInt() ?? 0,
          wrongRate: (item['wrong_rate'] as num?)?.toDouble() ?? 0,
        ));
      }
    }

    final subcats = <SubcategoryAggregate>[];
    final rawSubcat = json['subcategory'];
    if (rawSubcat is Map) {
      rawSubcat.forEach((tag, val) {
        if (val is! Map) return;
        subcats.add(SubcategoryAggregate(
          tag: tag.toString(),
          attempts: (val['attempts'] as num?)?.toInt() ?? 0,
          correct: (val['correct'] as num?)?.toInt() ?? 0,
        ));
      });
      // 오답률 높은 순 정렬
      subcats.sort((a, b) => a.accuracyRate.compareTo(b.accuracyRate));
    }

    final allQs = <int, AllQuestionAggregate>{};
    final rawAllQ = json['all_questions'];
    if (rawAllQ is Map) {
      rawAllQ.forEach((key, val) {
        if (val is! Map) return;
        final id = int.tryParse(key.toString());
        if (id == null) return;
        final rawCounts = val['option_counts'];
        final optionCounts = <int, int>{};
        if (rawCounts is Map) {
          rawCounts.forEach((k, v) {
            final idx = int.tryParse(k.toString());
            if (idx != null && v is num) optionCounts[idx] = v.toInt();
          });
        }
        allQs[id] = AllQuestionAggregate(
          questionId: id,
          attempts: (val['attempts'] as num?)?.toInt() ?? 0,
          correct: (val['correct'] as num?)?.toInt() ?? 0,
          wrongRate: (val['wrong_rate'] as num?)?.toDouble() ?? 0,
          optionCounts: optionCounts,
        );
      });
    }

    return GlobalAggregateStats(
      updatedAt: updatedAt,
      hardestTop10: hardest,
      subcategory: subcats,
      allQuestions: allQs,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 서비스
// ─────────────────────────────────────────────────────────────────────────────

/// 전체 사용자 익명 집계 통계 서비스.
///
/// - 읽기(집계): [loadAggregateStats] 가 GitHub raw URL 의 `aggregates.json` 을
///   가져온다. 메모리 캐시 → SharedPreferences 캐시(1시간) → HTTP fetch 순.
/// - 읽기(단건): [loadStat] 는 집계의 `allQuestions` 에서 개별 문항을 조회한다.
class GlobalAnswerStatsService {
  GlobalAnswerStatsService._();

  /// Web/Android/iOS 에서만 true. Windows/macOS/Linux 데스크톱은 Firebase
  /// 미지원이므로 false.
  static bool get isSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static const _aggregateUrl =
      'https://raw.githubusercontent.com/smilecws/quiz/data-aggregates/aggregates.json';

  static const _spKeyBody = 'global_aggregate_stats_body';
  static const _spKeyFetchedAt = 'global_aggregate_stats_fetched_at';
  static const Duration _cacheTtl = Duration(hours: 1);

  // 메모리 캐시
  static GlobalAggregateStats? _aggCache;
  static DateTime? _aggCacheLoadedAt;
  static Future<GlobalAggregateStats>? _aggInFlight;

  // ─────────────────────────────────────────────────────────────────────────
  // 읽기 — 집계 (aggregates.json)
  // ─────────────────────────────────────────────────────────────────────────

  /// 사전 집계된 글로벌 통계를 반환한다.
  /// 메모리 캐시 → SharedPreferences(1시간) → HTTP fetch → 만료 SP 폴백 → empty.
  static Future<GlobalAggregateStats> loadAggregateStats({
    bool forceRefresh = false,
  }) async {
    // 1) 메모리 캐시
    if (!forceRefresh && _aggCache != null && _aggCacheLoadedAt != null) {
      if (DateTime.now().difference(_aggCacheLoadedAt!) < _cacheTtl) {
        return _aggCache!;
      }
    }

    // 중복 요청 방지
    final inFlight = _aggInFlight;
    if (inFlight != null) return inFlight;

    final future = _loadAggregateWithFallback(forceRefresh);
    _aggInFlight = future;
    try {
      final result = await future;
      _aggCache = result;
      _aggCacheLoadedAt = DateTime.now();
      return result;
    } finally {
      _aggInFlight = null;
    }
  }

  /// 마지막으로 캐시된 수신 시각. 화면에서 "N시간 전" 표시용.
  static DateTime? get lastFetchedAt => _aggCacheLoadedAt;

  static Future<GlobalAggregateStats> _loadAggregateWithFallback(
    bool forceRefresh,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // 2) SharedPreferences 캐시 (1시간 이내)
    if (!forceRefresh) {
      final spResult = _tryLoadFromPrefs(prefs);
      if (spResult != null) return spResult;
    }

    // 3) 네트워크 fetch
    try {
      final response = await http
          .get(Uri.parse(_aggregateUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = response.body;
        final json = jsonDecode(body) as Map<String, dynamic>;
        final stats = GlobalAggregateStats.fromJson(json);

        // SP 에 저장
        await prefs.setString(_spKeyBody, body);
        await prefs.setString(
          _spKeyFetchedAt,
          DateTime.now().toIso8601String(),
        );

        return stats;
      }
    } catch (e) {
      debugPrint('GlobalAnswerStatsService._fetchAggregate failed: $e');
    }

    // 4) 만료된 SP 캐시라도 폴백
    final spBody = prefs.getString(_spKeyBody);
    if (spBody != null) {
      try {
        final json = jsonDecode(spBody) as Map<String, dynamic>;
        return GlobalAggregateStats.fromJson(json);
      } catch (_) {}
    }

    // 5) 아무것도 없으면 빈 결과
    return GlobalAggregateStats.empty;
  }

  static GlobalAggregateStats? _tryLoadFromPrefs(SharedPreferences prefs) {
    final fetchedAtStr = prefs.getString(_spKeyFetchedAt);
    if (fetchedAtStr == null) return null;
    final fetchedAt = DateTime.tryParse(fetchedAtStr);
    if (fetchedAt == null) return null;
    if (DateTime.now().difference(fetchedAt) >= _cacheTtl) return null;

    final body = prefs.getString(_spKeyBody);
    if (body == null) return null;
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return GlobalAggregateStats.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 읽기 — 단건 (aggregates.json 의 all_questions)
  // ─────────────────────────────────────────────────────────────────────────

  /// 단일 문항 통계. 집계의 `allQuestions` 에서 조회한다.
  static Future<GlobalQuestionStat?> loadStat(int questionId) async {
    final agg = await loadAggregateStats();
    final entry = agg.allQuestions[questionId];
    if (entry == null) return null;
    return GlobalQuestionStat(
      questionId: questionId,
      attempts: entry.attempts,
      correct: entry.correct,
      optionCounts: entry.optionCounts,
    );
  }

  static void _invalidateAggregateCache() {
    _aggCache = null;
    _aggCacheLoadedAt = null;
  }

  @visibleForTesting
  static void debugReset() => _invalidateAggregateCache();
}
