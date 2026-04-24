import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';
import 'locale_service.dart';
import 'question_subcategory_service.dart';

/// `questions_kor.json` 등 모든 언어 JSON의 `category` 값과 동일해야 합니다.
class QuestionCategory {
  QuestionCategory._();

  static const verbal = '말문제';
  static const signAndSituation = '표지 및 상황문제';
  static const video = '동영상 문제';
}

class QuestionService {
  static List<Question>? _allQuestions;
  static String? _loadedAssetPath;

  /// 현재 로드할 문제 은행 UI 언어 (`ko` / `en` / `zh` / `vi`)
  static String _languageCode = 'ko';

  /// [LocaleService] 저장값과 맞추기 위해 앱 시작·언어 변경 시 호출합니다.
  static void setLanguageCode(String languageCode) {
    final normalized = switch (languageCode) {
      'en' => 'en',
      'zh' => 'zh',
      'vi' => 'vi',
      _ => 'ko',
    };
    if (_languageCode != normalized) {
      _languageCode = normalized;
      clearCache();
    }
  }

  static String get _assetPath =>
      LocaleService.questionsBankAssetPath(_languageCode);

  /// 에셋/플래그를 바꾼 뒤 캐시를 비울 때 사용 (핫 리스타트와 동일 효과).
  static void clearCache() {
    _allQuestions = null;
    _loadedAssetPath = null;
  }

  /// 전체 문항을 파싱하지 않고 개수만 구합니다(홈 카운트용).
  static Future<int> loadQuestionCountOnly() async {
    final path = _assetPath;
    if (_allQuestions != null && _loadedAssetPath == path) {
      return _allQuestions!.length;
    }

    final String jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> data = jsonDecode(jsonString);

    if (data['questions'] != null) {
      return (data['questions'] as List).length;
    }
    if (data['pages'] != null) {
      var n = 0;
      for (final page in data['pages'] as List) {
        final pageMap = page as Map<String, dynamic>;
        final qs = pageMap['questions'] as List?;
        if (qs != null) {
          n += qs.length;
          continue;
        }
        final problems = pageMap['problems'] as List? ?? const [];
        n += problems.length;
      }
      return n;
    }
    throw FormatException(
      '문제 JSON: 최상위에 "questions" 또는 "pages" 배열이 필요합니다.',
    );
  }

  static Future<List<Question>> loadAllQuestions() async {
    final path = _assetPath;
    if (_allQuestions != null && _loadedAssetPath == path) {
      return _allQuestions!;
    }

    final String jsonString = await rootBundle.loadString(path);
    _loadedAssetPath = path;
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<Question> list = [];

    if (data['questions'] != null) {
      var i = 0;
      for (final e in data['questions'] as List) {
        final m = Map<String, dynamic>.from(e as Map);
        if (!m.containsKey('id')) m['id'] = i;
        list.add(Question.fromJson(m));
        i++;
      }
    } else if (data['pages'] != null) {
      var id = 0;
      for (final page in data['pages'] as List) {
        final pageMap = page as Map<String, dynamic>;
        final qs = pageMap['questions'] as List?;
        if (qs != null) {
          for (final q in qs) {
            list.add(Question.fromPageExport(q as Map<String, dynamic>, id));
            id++;
          }
          continue;
        }

        final problems = pageMap['problems'] as List? ?? const [];
        for (final p in problems) {
          final m = p as Map<String, dynamic>;
          final qn = (m['question_number'] as num?)?.toInt();
          list.add(Question.fromPdfProblemsExport(m, qn ?? id));
          id++;
        }
      }
    } else {
      throw FormatException(
        '문제 JSON: 최상위에 "questions" 또는 "pages" 배열이 필요합니다.',
      );
    }

    _allQuestions = list;
    return _allQuestions!;
  }

  /// [loadAllQuestions] 캐시를 재사용해 id → 문항 맵을 만듭니다.
  static Future<Map<int, Question>> loadAllQuestionsById() async {
    final all = await loadAllQuestions();
    return {for (final q in all) q.id: q};
  }

  static Future<List<Question>> getRandomQuestions({int count = 40}) async {
    final all = await loadAllQuestions();
    if (all.isEmpty) return const [];
    final shuffled = List<Question>.from(all)..shuffle(Random());
    final n = count.clamp(1, all.length);
    return shuffled.take(n).toList();
  }

  static Future<List<Question>> getRandomQuestionsByCategory({
    required String category,
    int count = 40,
  }) async {
    final all = await loadAllQuestions();
    final filtered =
        all.where((q) => (q.category ?? '').trim() == category).toList();
    if (filtered.isEmpty) return const [];
    filtered.shuffle(Random());
    final n = count.clamp(1, filtered.length);
    return filtered.take(n).toList();
  }

  /// 소카테고리 태그에 해당하는 문항을 최대 [count] 개 랜덤 반환합니다.
  /// 매핑은 [QuestionSubcategoryService] 가 로드하는 id → 태그 맵을 사용합니다.
  static Future<List<Question>> getRandomQuestionsBySubcategory({
    required String subcategoryId,
    int count = 40,
  }) async {
    final all = await loadAllQuestions();
    final map = await QuestionSubcategoryService.loadMap();
    final filtered =
        all.where((q) => map[q.id] == subcategoryId).toList();
    if (filtered.isEmpty) return const [];
    filtered.shuffle(Random());
    final n = count.clamp(1, filtered.length);
    return filtered.take(n).toList();
  }
}
