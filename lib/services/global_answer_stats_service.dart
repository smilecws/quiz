import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_result.dart';
import 'global_stats_consent_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 개별 문항 통계 (Firestore 단건 조회용 — loadStat)
// ─────────────────────────────────────────────────────────────────────────────

/// Firestore 한 문서(`question_stats/{questionId}`) 에 대응되는 익명 집계 통계.
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

/// GitHub Actions 가 생성한 `aggregates.json` 파싱 결과.
class GlobalAggregateStats {
  final DateTime? updatedAt;
  final List<AggregateHardestEntry> hardestTop10;
  final List<SubcategoryAggregate> subcategory;

  const GlobalAggregateStats({
    this.updatedAt,
    this.hardestTop10 = const [],
    this.subcategory = const [],
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

    return GlobalAggregateStats(
      updatedAt: updatedAt,
      hardestTop10: hardest,
      subcategory: subcats,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 서비스
// ─────────────────────────────────────────────────────────────────────────────

/// 전체 사용자 익명 집계 통계 서비스.
///
/// - 쓰기: 세션 종료 시 [applySessionResults] 1회. Firestore 에 +1 증가.
/// - 읽기(집계): [loadAggregateStats] 가 GitHub raw URL 의 `aggregates.json` 을
///   가져온다. 메모리 캐시 → SharedPreferences 캐시(1시간) → HTTP fetch 순.
/// - 읽기(단건): [loadStat] 는 Firestore 에서 개별 문서를 가져온다.
class GlobalAnswerStatsService {
  GlobalAnswerStatsService._();

  static const _collection = 'question_stats';

  static const _aggregateUrl =
      'https://raw.githubusercontent.com/smilecws/quiz/data-aggregates/aggregates.json';

  static const _spKeyBody = 'global_aggregate_stats_body';
  static const _spKeyFetchedAt = 'global_aggregate_stats_fetched_at';
  static const Duration _cacheTtl = Duration(hours: 1);

  // 메모리 캐시
  static GlobalAggregateStats? _aggCache;
  static DateTime? _aggCacheLoadedAt;
  static Future<GlobalAggregateStats>? _aggInFlight;

  /// Web/Android/iOS 에서만 true. Windows/macOS/Linux 데스크톱은 cloud_firestore
  /// 미지원이므로 false. 쓰기(applySessionResults) · 단건 읽기(loadStat) 에 사용.
  static bool get isSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 쓰기
  // ─────────────────────────────────────────────────────────────────────────

  /// 세션 결과를 Firestore 에 batch increment 로 반영한다.
  /// 실패해도 throw 하지 않는다(로컬 저장 흐름을 막지 않기 위해).
  static Future<void> applySessionResults(List<SessionResult> results) async {
    if (!isSupported || results.isEmpty) return;

    final consent = await GlobalStatsConsentService.load();
    if (!consent) return;

    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (_) {
        return;
      }
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      for (final r in results) {
        final ref = firestore.collection(_collection).doc(r.questionId.toString());
        final updates = <String, Object>{
          'attempts': FieldValue.increment(1),
          'correct': FieldValue.increment(r.isCorrect ? 1 : 0),
          'last_updated_at': FieldValue.serverTimestamp(),
        };
        for (final idx in r.selectedIndices) {
          updates['option_counts.$idx'] = FieldValue.increment(1);
        }
        batch.set(ref, updates, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('GlobalAnswerStatsService.applySessionResults failed: $e');
    }
  }

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
  // 읽기 — 단건 (Firestore)
  // ─────────────────────────────────────────────────────────────────────────

  /// 단일 문항 통계. Firestore 에서 개별 문서를 가져온다.
  static Future<GlobalQuestionStat?> loadStat(int questionId) async {
    if (!isSupported) return null;

    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(questionId.toString())
          .get();
      if (!snap.exists) return null;
      return _parseDoc(questionId, snap.data() ?? const {});
    } catch (e) {
      debugPrint('GlobalAnswerStatsService.loadStat failed: $e');
      return null;
    }
  }

  static GlobalQuestionStat _parseDoc(int id, Map<String, dynamic> data) {
    final attempts = (data['attempts'] as num?)?.toInt() ?? 0;
    final correct = (data['correct'] as num?)?.toInt() ?? 0;
    final rawCounts = data['option_counts'];
    final optionCounts = <int, int>{};
    if (rawCounts is Map) {
      rawCounts.forEach((key, value) {
        final idx = int.tryParse(key.toString());
        if (idx != null && value is num) {
          optionCounts[idx] = value.toInt();
        }
      });
    }
    return GlobalQuestionStat(
      questionId: id,
      attempts: attempts,
      correct: correct,
      optionCounts: optionCounts,
    );
  }

  static void _invalidateAggregateCache() {
    _aggCache = null;
    _aggCacheLoadedAt = null;
  }

  @visibleForTesting
  static void debugReset() => _invalidateAggregateCache();
}
