import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/mock_exam_license_kind.dart';
import '../models/session_result.dart';
import '../theme/app_theme_colors.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final List<SessionResult> results;
  final MockExamLicenseKind? mockExamLicenseKind;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.results,
    this.mockExamLicenseKind,
  });

  int get _scaledScoreOutOf100 =>
      total <= 0 ? 0 : ((score * 100) / total).round();

  String _gradeLabel(AppLocalizations l10n) {
    if (mockExamLicenseKind != null) {
      final passed = _scaledScoreOutOf100 >=
          mockExamLicenseKind!.passScoreMinOutOf100;
      return passed ? l10n.mockResultPass : l10n.mockResultFail;
    }
    final ratio = total <= 0 ? 0.0 : score / total;
    if (ratio >= 0.9) return '🏆 우수';
    if (ratio >= 0.7) return '👍 양호';
    if (ratio >= 0.5) return '📚 보통';
    return '💪 분발';
  }

  Color _scoreColor(AppThemeColors ac) {
    if (mockExamLicenseKind != null) {
      final passed = _scaledScoreOutOf100 >=
          mockExamLicenseKind!.passScoreMinOutOf100;
      return passed ? const Color(0xFF15803D) : Colors.red.shade700;
    }
    final ratio = total <= 0 ? 0.0 : score / total;
    if (ratio >= 0.9) return const Color(0xFF15803D);
    if (ratio >= 0.7) return ac.primaryDark;
    if (ratio >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _indicesToLabels(SessionResult r, Iterable<int> indices) {
    return indices
        .map((i) => '${i + 1}. ${r.question.options[i]}')
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    final l10n = AppLocalizations.of(context);
    final gradeLabel = _gradeLabel(l10n);
    final scoreColor = _scoreColor(ac);
    final kind = mockExamLicenseKind;
    final incorrectResults =
        results.where((r) => !r.isCorrect).toList();

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        title: const Text('시험 결과'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
            decoration: BoxDecoration(
              color: ac.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ac.borderLight),
              boxShadow: [
                BoxShadow(
                  color: ac.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: kind == null
                ? Column(
                    children: [
                      Text(
                        gradeLabel,
                        style: TextStyle(
                          fontSize: 20,
                          color: ac.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$score / $total',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total <= 0
                            ? '—'
                            : '정답률 ${(score / total * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          color: ac.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              gradeLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: ac.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$score / $total',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              total <= 0
                                  ? '—'
                                  : '정답률 ${(score / total * 100).toStringAsFixed(1)}%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: ac.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              l10n.mockResultScaledScore(_scaledScoreOutOf100),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ac.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.mockResultLicenseKindLine}: ${l10n.mockLicenseLabel(kind)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.25,
                                color: ac.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.mockResultPassBar(kind.passScoreMinOutOf100),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.25,
                                color: ac.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '오답 노트',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ac.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: incorrectResults.length,
              itemBuilder: (context, index) {
                final r = incorrectResults[index];
                final question = r.question;
                final selected = r.selectedIndices;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ac.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${results.indexOf(r) + 1}. ${question.question}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: ac.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (question.isMultipleChoice) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.close,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '내 답: ${selected.isNotEmpty ? _indicesToLabels(r, selected) : "(선택 없음)"}',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '정답: ${_indicesToLabels(r, question.correctIndices)}',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        if (selected.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.close,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '내 답: ${question.options[selected.first]}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.check,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '정답: ${question.options[question.correctIndices.first]}',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ac.primary,
                  foregroundColor: ac.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '다시 풀기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
