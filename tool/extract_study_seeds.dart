// 각 소카테고리의 학습 카드 초안 작성용 raw 데이터를 뽑습니다.
// 출력: assets/study/_seeds/<tag>.json (git ignore)
//
// 실행:
//   dart run tool/extract_study_seeds.dart
//
// 사용법:
//   1. 이 스크립트로 seeds/<tag>.json 생성
//   2. 사람이 각 seeds/*.json 을 열어 법령·숫자·해설을 보고
//      assets/study/<tag>.json 학습 카드를 수동 작성

import 'dart:convert';
import 'dart:io';

import 'package:quiz_app/services/subcategory_classifier.dart';

void main() {
  final problems = File('assets/questions_kor.json');
  final subcatFile = File('assets/question_subcategory.json');
  if (!problems.existsSync() || !subcatFile.existsSync()) {
    stderr.writeln('필수 입력 파일이 없습니다.');
    exit(1);
  }
  final data =
      jsonDecode(problems.readAsStringSync()) as Map<String, dynamic>;
  final subcat =
      jsonDecode(subcatFile.readAsStringSync()) as Map<String, dynamic>;

  final byTag = <String, List<_Problem>>{};
  for (final pageRaw in (data['pages'] as List)) {
    final page = pageRaw as Map<String, dynamic>;
    for (final probRaw in (page['problems'] as List? ?? const [])) {
      final p = probRaw as Map<String, dynamic>;
      final qn = (p['question_number'] as num?)?.toInt();
      if (qn == null) continue;
      final tag = subcat[qn.toString()] as String? ?? 'general';
      final problemArea = (p['problem_area'] as Map?) ?? const {};
      final explanationArea = (p['explanation_area'] as Map?) ?? const {};
      byTag.putIfAbsent(tag, () => []).add(
            _Problem(
              qn: qn,
              question: (problemArea['question'] ?? '').toString(),
              explanation: (explanationArea['explanation'] ?? '').toString(),
            ),
          );
    }
  }

  final outDir = Directory('assets/study/_seeds')
    ..createSync(recursive: true);

  final allTags = <String>[
    ...SubcategoryIds.verbalSubcategoryIds,
    SubcategoryIds.signSituation,
    SubcategoryIds.video,
  ];

  for (final tag in allTags) {
    final items = byTag[tag] ?? const <_Problem>[];
    final seed = _buildSeed(tag, items);
    final file = File('${outDir.path}/$tag.json');
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(seed),
    );
    stdout.writeln(
      '  $tag\tn=${items.length}\t'
      'laws=${(seed['law_references'] as List).length}\t'
      'numbers=${(seed['numbers'] as List).length}\t'
      'exps=${(seed['representative_explanations'] as List).length}',
    );
  }
}

Map<String, dynamic> _buildSeed(String tag, List<_Problem> items) {
  // 1) 법령 참조 빈도
  final lawPattern = RegExp(
    r'도로교통법(?:\s*시행규칙|\s*시행령)?\s*제\d+조(?:의\d+)?(?:\s*제\d+항)?'
    r'|시행규칙\s*\[?별표\s*\d+\]?'
    r'|도로교통법\s*시행규칙\s*\[?별표\s*\d+\]?'
    r'|교통사고처리\s*특례법\s*제\d+조(?:\s*제\d+항)?'
    r'|특정범죄\s*가중처벌\s*등에\s*관한\s*법률\s*제\d+조(?:의\d+)?',
  );
  final lawCounts = <String, int>{};
  for (final p in items) {
    for (final m in lawPattern.allMatches(p.explanation)) {
      final norm = m.group(0)!.replaceAll(RegExp(r'\s+'), ' ').trim();
      lawCounts[norm] = (lawCounts[norm] ?? 0) + 1;
    }
  }
  final lawRefs = lawCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // 2) 주요 숫자 패턴
  final numberPatterns = <String, RegExp>{
    'speed_kmh':
        RegExp(r'(?:시속\s*)?(\d+)\s*(?:km|킬로미터)(?:\/h|\s*이하|\s*초과)?'),
    'penalty_points': RegExp(r'벌점\s*(\d+)점?'),
    'fine_man_won': RegExp(r'(\d+(?:,\d{3})*)\s*만원'),
    'bac_percent': RegExp(r'0\.\d+\s*(?:%|퍼센트)'),
    'distance_m': RegExp(r'(\d+)\s*(?:미터|m|ｍ)'),
  };
  final numberHits = <String, Map<String, int>>{
    for (final k in numberPatterns.keys) k: {},
  };
  for (final p in items) {
    final text = '${p.question}\n${p.explanation}';
    numberPatterns.forEach((kind, pat) {
      for (final m in pat.allMatches(text)) {
        final norm = m.group(0)!.replaceAll(RegExp(r'\s+'), ' ').trim();
        numberHits[kind]![norm] = (numberHits[kind]![norm] ?? 0) + 1;
      }
    });
  }

  final numbersOut = <Map<String, dynamic>>[];
  numberHits.forEach((kind, counts) {
    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in top.take(8)) {
      numbersOut.add({'kind': kind, 'sample': e.key, 'count': e.value});
    }
  });

  // 3) 대표 해설 5개: 길이 중앙값 근처에서 선정
  final richExps = items.where((x) => x.explanation.length >= 60).toList()
    ..sort((a, b) => a.explanation.length.compareTo(b.explanation.length));
  final mid = richExps.length ~/ 2;
  final startIdx = (mid - 2).clamp(0, richExps.length);
  final endIdx = (mid + 3).clamp(0, richExps.length);
  final representatives = richExps.sublist(startIdx, endIdx);

  // 4) 문제 색인 (qn + 질문 앞부분)
  final questionIndex = items
      .map((p) => {
            'qn': p.qn,
            'question':
                p.question.length > 100 ? '${p.question.substring(0, 100)}…' : p.question,
            'explanation_length': p.explanation.length,
          })
      .toList();

  return {
    'tag': tag,
    'question_count': items.length,
    'law_references': lawRefs
        .take(20)
        .map((e) => {'ref': e.key, 'count': e.value})
        .toList(),
    'numbers': numbersOut,
    'representative_explanations': representatives
        .map((p) => {
              'qn': p.qn,
              'question': p.question,
              'explanation': p.explanation,
            })
        .toList(),
    'question_index': questionIndex,
  };
}

class _Problem {
  _Problem({required this.qn, required this.question, required this.explanation});
  final int qn;
  final String question;
  final String explanation;
}
