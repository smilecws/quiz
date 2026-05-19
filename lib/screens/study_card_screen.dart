import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../models/study_card.dart';
import '../services/question_service.dart';
import '../services/study_card_service.dart';
import '../theme/app_theme_colors.dart';
import 'quiz_screen.dart';

/// 소카테고리 학습 카드 화면.
///
/// `assets/study/<subcategoryId>.json` 을 로드해 토픽 아코디언 + 가로 스와이프
/// 카드뉴스로 보여줍니다. 토픽이 비어 있는 구버전 카드는 평면
/// key_points / numbers 를 "전체" 토픽의 슬라이드 시퀀스로 자동 변환합니다.
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
  String? _openTopicId;

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
              l10n.studyScreenLoadError,
              style: TextStyle(color: ac.textSecondary, fontSize: 14),
            ),
          ),
        ),
      );
    }

    final topics = card.topics.isNotEmpty
        ? card.topics
        : [_legacyToTopic(card, ac.primary)];

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
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: ac.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < topics.length; i++) ...[
            _TopicTile(
              index: i + 1,
              topic: topics[i],
              isOpen: _openTopicId == topics[i].id,
              lang: lang,
              onToggle: () => setState(() {
                _openTopicId =
                    _openTopicId == topics[i].id ? null : topics[i].id;
              }),
            ),
            if (i != topics.length - 1) const SizedBox(height: 12),
          ],
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

/// schema v1 카드: 평면 key_points / numbers 를 단일 "전체" 토픽으로 감쌉니다.
/// v2 콘텐츠가 작성되기 전까지의 임시 호환 경로 — 카드 작성자가 토픽 구조로
/// 손수 재작성하면 자연스럽게 이 경로를 빠져나갑니다.
StudyTopic _legacyToTopic(StudyCard card, Color accent) {
  final slides = <StudySlide>[
    for (var i = 0; i < card.legacyKeyPoints.length; i++)
      ContentSlide(
        tag: {
          'ko': 'KEY ${i + 1}',
          'en': 'KEY ${i + 1}',
          'zh': 'KEY ${i + 1}',
          'vi': 'KEY ${i + 1}',
        },
        title: card.legacyKeyPoints[i].heading,
        highlight: const {'ko': ''},
        body: card.legacyKeyPoints[i].body,
        note: card.legacyKeyPoints[i].lawRefs.isEmpty
            ? const {'ko': ''}
            : {'ko': card.legacyKeyPoints[i].lawRefs.join(' · ')},
      ),
    if (card.legacyNumbers.isNotEmpty)
      SummarySlide(
        title: const {
          'ko': '핵심 정리',
          'en': 'Key takeaways',
          'zh': '核心整理',
          'vi': 'Tóm tắt chính',
        },
        items: [
          for (final n in card.legacyNumbers)
            SummaryItem(label: n.label, value: n.value),
        ],
        lawRefs: const [],
      ),
  ];
  return StudyTopic(
    id: 'all',
    label: card.title,
    desc: const {'ko': ''},
    accent: accent,
    slides: slides,
  );
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.index,
    required this.topic,
    required this.isOpen,
    required this.lang,
    required this.onToggle,
  });

  final int index;
  final StudyTopic topic;
  final bool isOpen;
  final String lang;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: ac.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOpen
              ? topic.accent.withValues(alpha: 0.45)
              : ac.borderLight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: topic.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: topic.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.labelFor(lang),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: ac.textPrimary,
                          ),
                        ),
                        if (topic.descFor(lang).isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            topic.descFor(lang),
                            style: TextStyle(
                              fontSize: 13,
                              color: ac.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ac.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isOpen
                ? _CardNews(topic: topic, lang: lang)
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

class _CardNews extends StatefulWidget {
  const _CardNews({required this.topic, required this.lang});

  final StudyTopic topic;
  final String lang;

  @override
  State<_CardNews> createState() => _CardNewsState();
}

class _CardNewsState extends State<_CardNews> {
  late final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final total = widget.topic.slides.length;
    if (total == 0) return;
    final next = (_index + delta + total) % total;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _jumpTo(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.topic.accent;
    final slides = widget.topic.slides;
    if (slides.isEmpty) {
      return const SizedBox(height: 0);
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
      child: Column(
        children: [
          Container(
            height: 340,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final s = slides[i];
                return switch (s) {
                  ContentSlide() =>
                    _ContentSlideView(slide: s, accent: accent, lang: widget.lang),
                  SummarySlide() =>
                    _SummarySlideView(slide: s, accent: accent, lang: widget.lang),
                };
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _RoundButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _go(-1),
                background: Colors.white,
                foreground: const Color(0xFF334155),
              ),
              const Spacer(),
              for (var i = 0; i < slides.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _jumpTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? accent
                          : accent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _RoundButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _go(1),
                background: accent,
                foreground: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: foreground),
        ),
      ),
    );
  }
}

class _ContentSlideView extends StatelessWidget {
  const _ContentSlideView({
    required this.slide,
    required this.accent,
    required this.lang,
  });

  final ContentSlide slide;
  final Color accent;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    final tag = slide.tagFor(lang);
    final highlight = slide.highlightFor(lang);
    final note = slide.noteFor(lang);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tag.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            slide.titleFor(lang),
            style: TextStyle(
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: ac.textPrimary,
            ),
          ),
          if (highlight.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                highlight,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                slide.bodyFor(lang),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: ac.textPrimary,
                ),
              ),
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '💡 $note',
              style: TextStyle(
                fontSize: 11.5,
                color: ac.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummarySlideView extends StatelessWidget {
  const _SummarySlideView({
    required this.slide,
    required this.accent,
    required this.lang,
  });

  final SummarySlide slide;
  final Color accent;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slide.titleFor(lang),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ac.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: slide.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = slide.items[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: ac.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ac.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.labelFor(lang),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.valueFor(lang),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: ac.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (slide.lawRefs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final ref in slide.lawRefs)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      ref,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
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
