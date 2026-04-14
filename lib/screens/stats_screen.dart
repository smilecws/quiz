import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mock_exam_history_entry.dart';
import '../services/attempted_questions_service.dart';
import '../services/mock_exam_history_service.dart';
import '../services/user_answer_stats_service.dart';
import '../services/wrong_note_service.dart';
import '../theme/app_theme_colors.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _loading = true;

  OverallStats? _overall;
  List<MockExamHistoryEntry> _mockHistory = [];
  List<AnswerQuestionStat> _hardestQuestions = [];
  int _wrongCount = 0;
  int _attemptedCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      UserAnswerStatsService.getOverallStats(),
      MockExamHistoryService.loadEntries(),
      UserAnswerStatsService.getHardestQuestions(n: 10, minAttempts: 2),
      WrongNoteService.loadWrongIds(),
      AttemptedQuestionsService.loadAttemptedIds(),
    ]);

    if (!mounted) return;
    setState(() {
      _overall = results[0] as OverallStats;
      _mockHistory = results[1] as List<MockExamHistoryEntry>;
      _hardestQuestions = results[2] as List<AnswerQuestionStat>;
      _wrongCount = (results[3] as Set<int>).length;
      _attemptedCount = (results[4] as Set<int>).length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(
          l10n.statsTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _SectionHeader(title: l10n.statsSectionOverall),
                  const SizedBox(height: 8),
                  _OverallStatsCard(
                    l10n: l10n,
                    overall: _overall!,
                    wrongCount: _wrongCount,
                    attemptedCount: _attemptedCount,
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(title: l10n.statsMockExamTrend),
                  const SizedBox(height: 8),
                  _MockExamChart(l10n: l10n, history: _mockHistory),
                  if (_hardestQuestions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: l10n.statsHardestTopN(_hardestQuestions.length),
                    ),
                    const SizedBox(height: 8),
                    _HardestQuestionsList(
                      l10n: l10n,
                      questions: _hardestQuestions,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 섹션 헤더
// ──────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: context.appColors.textPrimary,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 전체 현황 카드
// ──────────────────────────────────────────────────────────────────────────────

class _OverallStatsCard extends StatelessWidget {
  const _OverallStatsCard({
    required this.l10n,
    required this.overall,
    required this.wrongCount,
    required this.attemptedCount,
  });

  final AppLocalizations l10n;
  final OverallStats overall;
  final int wrongCount;
  final int attemptedCount;

  @override
  Widget build(BuildContext context) {
    final accuracy = overall.totalAttempts > 0
        ? (overall.accuracyRate * 100).toStringAsFixed(1)
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              icon: Icons.quiz_outlined,
              label: l10n.statsLabelAttempted,
              value: l10n.statsQuestionsUnit(attemptedCount),
              iconColor: context.appColors.primaryDark,
              iconBg: context.appColors.chipBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              icon: Icons.check_circle_outline,
              label: l10n.statsLabelAccuracy,
              value: '$accuracy%',
              iconColor: const Color(0xFF15803D),
              iconBg: const Color(0xFFDCFCE7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              icon: Icons.close_rounded,
              label: l10n.statsLabelWrongNow,
              value: l10n.statsQuestionsUnit(wrongCount),
              iconColor: Colors.red.shade700,
              iconBg: const Color(0xFFFEE2E2),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 모의고사 점수 바 차트
// ──────────────────────────────────────────────────────────────────────────────

class _MockExamChart extends StatelessWidget {
  const _MockExamChart({required this.l10n, required this.history});

  final AppLocalizations l10n;
  final List<MockExamHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: context.appColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.borderLight),
        ),
        child: Center(
          child: Text(
            l10n.statsMockExamChartEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // 최근 10개만 표시 (최신이 오른쪽)
    final recent = history.length > 10
        ? history.sublist(0, 10).reversed.toList()
        : history.reversed.toList();

    const double chartHeight = 120;
    const double barMaxHeight = 90;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: context.appColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.mockResultPass,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.mockResultFail,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recent.map((e) {
                final ratio = e.scaledScoreOutOf100 / 100.0;
                final barH = (ratio * barMaxHeight).clamp(4.0, barMaxHeight);
                final pass = e.passed;
                final barColor =
                    pass ? const Color(0xFF22C55E) : Colors.red.shade400;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${e.scaledScoreOutOf100}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: pass
                                ? const Color(0xFF15803D)
                                : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: barH,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.statsChartOldestFirst,
                style: TextStyle(
                  fontSize: 10,
                  color: context.appColors.textSecondary,
                ),
              ),
              Text(
                l10n.statsChartRecentAttempts(recent.length),
                style: TextStyle(
                  fontSize: 10,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 자주 틀리는 문제 목록
// ──────────────────────────────────────────────────────────────────────────────

class _HardestQuestionsList extends StatelessWidget {
  const _HardestQuestionsList({required this.l10n, required this.questions});

  final AppLocalizations l10n;
  final List<AnswerQuestionStat> questions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.borderLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: questions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: context.appColors.borderLight,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, i) {
          final s = questions[i];
          final wrongRate =
              ((1 - s.accuracyRate) * 100).toStringAsFixed(0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.statsQuestionIdLine(s.questionId),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.statsAttemptsWrongLine(s.attempts, s.wrongCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.statsWrongRatePercent(wrongRate),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _AccuracyBar(rate: s.accuracyRate),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccuracyBar extends StatelessWidget {
  const _AccuracyBar({required this.rate});
  final double rate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: rate,
          backgroundColor: Colors.red.shade100,
          color: rate >= 0.6 ? context.appColors.primary : Colors.red.shade400,
          minHeight: 6,
        ),
      ),
    );
  }
}
