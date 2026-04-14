import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mock_exam_history_entry.dart';
import '../models/mock_exam_license_kind.dart';
import '../services/mock_exam_history_service.dart';
import '../theme/app_theme_colors.dart';

class MockExamHistoryScreen extends StatefulWidget {
  const MockExamHistoryScreen({super.key});

  @override
  State<MockExamHistoryScreen> createState() => _MockExamHistoryScreenState();
}

class _MockExamHistoryScreenState extends State<MockExamHistoryScreen> {
  late Future<List<MockExamHistoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = MockExamHistoryService.loadEntries();
  }

  Future<void> _reload() async {
    setState(() {
      _future = MockExamHistoryService.loadEntries();
    });
    await _future;
  }

  String _formatWhen(BuildContext context, DateTime dt) {
    final loc = Localizations.localeOf(context).languageCode;
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    if (loc == 'ko') {
      return '$y.$mo.$d $h:$mi';
    }
    return '$y-$mo-$d $h:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(l10n.mockExamHistoryTitle),
      ),
      body: FutureBuilder<List<MockExamHistoryEntry>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.mockExamHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final e = list[i];
                final pass = e.passed;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                          Expanded(
                            child: Text(
                              l10n.mockLicenseLabel(e.licenseKind),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: pass
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              pass ? l10n.mockResultPass : l10n.mockResultFail,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: pass
                                    ? const Color(0xFF15803D)
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${l10n.mockExamHistoryWhen}: ${_formatWhen(context, e.at)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.mockExamHistoryScoreLine}: ${e.score} / ${e.total} · ${l10n.mockResultScaledScore(e.scaledScoreOutOf100)}',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.mockResultPassBar(
                          e.licenseKind.passScoreMinOutOf100,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
