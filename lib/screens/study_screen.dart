import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/question_subcategory_service.dart';
import '../services/subcategory_classifier.dart';
import '../theme/app_theme_colors.dart';
import '../utils/subcategory_ui.dart';
import 'study_card_screen.dart';

/// 학습하기 랜딩. 10개 소카테고리를 리스트로 보여주고, 탭하면 해당
/// 카테고리의 학습 카드 화면([StudyCardScreen]) 으로 이동합니다.
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  Map<String, int>? _counts;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final counts = await QuestionSubcategoryService.loadCounts();
    if (!mounted) return;
    setState(() => _counts = counts);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(
          '학습하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            '주제를 선택해 핵심 포인트와 수치를 먼저 정리해 보세요.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...SubcategoryIds.verbalSubcategoryIds.map((id) {
            final count = _counts?[id] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StudyIndexTile(
                title: l10n.subcategoryLabel(id),
                subtitle: count > 0
                    ? l10n.subcategorySubtitle(id, count)
                    : l10n.subcategoryLabel(id),
                icon: iconForSubcategory(id),
                iconBg: colorForSubcategory(context, id),
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => StudyCardScreen(subcategoryId: id),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StudyIndexTile extends StatelessWidget {
  const _StudyIndexTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    return Material(
      color: ac.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ac.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: ac.primaryDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ac.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: ac.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: ac.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
