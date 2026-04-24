import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../models/study_card.dart';
import '../services/question_service.dart';
import '../services/study_card_service.dart';
import '../theme/app_theme_colors.dart';
import 'quiz_screen.dart';

/// 소카테고리 학습 카드 화면.
/// `assets/study/<subcategoryId>.json` 을 로드해 핵심 포인트·수치·대표 기출을 보여줍니다.
class StudyCardScreen extends StatefulWidget {
  const StudyCardScreen({super.key, required this.subcategoryId});

  final String subcategoryId;

  @override
  State<StudyCardScreen> createState() => _StudyCardScreenState();
}

class _StudyCardScreenState extends State<StudyCardScreen> {
  bool _loading = true;
  StudyCard? _card;
  List<Question> _exampleQuestions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final card = await StudyCardService.loadCard(widget.subcategoryId);
    if (card == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    final byId = await QuestionService.loadAllQuestionsById();
    final examples = card.exampleQuestionIds
        .map((id) => byId[id])
        .whereType<Question>()
        .toList();
    if (!mounted) return;
    setState(() {
      _card = card;
      _exampleQuestions = examples;
      _loading = false;
    });
  }

  Future<void> _openExampleQuiz(BuildContext context) async {
    if (_exampleQuestions.isEmpty) return;
    final title = _card!.titleFor(Localizations.localeOf(context).languageCode);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: _exampleQuestions,
          title: title,
          showTimerAndScore: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    if (_loading) {
      return Scaffold(
        backgroundColor: ac.background,
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(color: ac.primary, strokeWidth: 3),
        ),
      );
    }

    final card = _card;
    if (card == null) {
      return Scaffold(
        backgroundColor: ac.background,
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '학습 자료를 불러오지 못했습니다.',
              style: TextStyle(color: ac.textSecondary, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        title: Text(
          card.titleFor(lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          Text(
            card.leadFor(lang),
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: ac.textPrimary,
            ),
          ),
          const SizedBox(height: 22),
          _SectionHeader(title: l10n.studyScreenSectionKeyPoints),
          const SizedBox(height: 10),
          ...card.keyPoints.map((k) => _KeyPointCard(point: k, lang: lang)),
          const SizedBox(height: 22),
          _SectionHeader(title: l10n.studyScreenSectionNumbers),
          const SizedBox(height: 10),
          _NumbersTable(entries: card.numbers, lang: lang),
          if (_exampleQuestions.isNotEmpty) ...[
            const SizedBox(height: 22),
            _SectionHeader(title: l10n.studyScreenSectionExamples),
            const SizedBox(height: 10),
            ..._exampleQuestions.map(
              (q) => _ExampleQuestionTile(
                question: q,
                onTap: () => _openExampleQuiz(context),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _exampleQuestions.isEmpty
                  ? null
                  : () => _openExampleQuiz(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ac.primary,
                foregroundColor: ac.onPrimary,
                disabledBackgroundColor: ac.borderLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.studyScreenQuizRelated,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class _KeyPointCard extends StatelessWidget {
  const _KeyPointCard({required this.point, required this.lang});
  final KeyPoint point;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ac.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ac.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            point.headingFor(lang),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ac.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            point.bodyFor(lang),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: ac.textPrimary,
            ),
          ),
          if (point.lawRefs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: point.lawRefs
                  .map(
                    (ref) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ac.chipBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: ac.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        ref,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ac.primaryDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumbersTable extends StatelessWidget {
  const _NumbersTable({required this.entries, required this.lang});
  final List<NumberEntry> entries;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: ac.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ac.borderLight),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: ac.borderLight),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entries[i].labelFor(lang),
                      style: TextStyle(
                        fontSize: 13,
                        color: ac.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      entries[i].valueFor(lang),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ac.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExampleQuestionTile extends StatelessWidget {
  const _ExampleQuestionTile({required this.question, required this.onTap});
  final Question question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    return Material(
      color: ac.surfaceWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ac.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: ac.chipBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${question.id}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ac.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: ac.textPrimary,
                  ),
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
