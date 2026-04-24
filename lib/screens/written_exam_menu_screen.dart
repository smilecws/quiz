import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mock_exam_license_kind.dart';
import '../models/question.dart';
import '../services/attempted_questions_service.dart';
import '../services/favorite_questions_service.dart';
import '../services/question_service.dart';
import '../services/question_subcategory_service.dart';
import '../services/subcategory_classifier.dart';
import '../models/disqualification_catalog.dart';
import '../models/mock_exam_history_entry.dart';
import '../services/disqualification_catalog_service.dart';
import '../services/mock_exam_history_service.dart';
import '../services/wrong_note_service.dart';
import '../theme/app_theme_colors.dart';
import '../utils/subcategory_ui.dart';
import 'disqualification_detail_screen.dart';
import 'exam_guide_screen.dart';
import 'mock_exam_history_screen.dart';
import 'quiz_screen.dart';
import 'stats_screen.dart';
import 'study_card_screen.dart';

/// 학습 진도 + 모의고사 점수 한 줄 기본 높이 (텍스트 스케일에 비례해 확장)
const double _kHomeStatsRowHeight = 176 * 0.8;
const double _kHomeStatsRowClampMax = 248 * 0.8;

double _homeStatsRowHeight(BuildContext context) {
  final raw = MediaQuery.textScalerOf(context).scale(1);
  final scale = raw.clamp(1.0, 1.85);
  return (_kHomeStatsRowHeight * scale).clamp(_kHomeStatsRowHeight, _kHomeStatsRowClampMax);
}

/// 운전면허 학과시험 홈(스크린샷 레이아웃)
class WrittenExamMenuScreen extends StatefulWidget {
  const WrittenExamMenuScreen({super.key});

  @override
  State<WrittenExamMenuScreen> createState() => _WrittenExamMenuScreenState();
}

class _WrittenExamMenuScreenState extends State<WrittenExamMenuScreen> {
  bool _loading = true;
  Locale? _localeForCounts;

  int _totalCount = 0;
  int _attemptedCount = 0;
  int _favoriteCount = 0;
  int _wrongCount = 0;
  MockExamHistoryEntry? _latestMockExam;

  Timer? _disqualificationTimer;
  DisqualificationCatalog? _disqualificationCatalog;
  bool _disqualificationLoading = true;
  String _disqualificationSnippet = '';

  double get _progress {
    if (_totalCount <= 0) return 0;
    return (_attemptedCount / _totalCount).clamp(0, 1);
  }

  @override
  void initState() {
    super.initState();
    _loadCounts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrapDisqualificationTips();
    });
  }

  @override
  void dispose() {
    _disqualificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrapDisqualificationTips() async {
    if (!mounted) return;
    final cat = await DisqualificationCatalogService.load();
    if (!mounted) return;
    if (cat == null) {
      setState(() {
        _disqualificationCatalog = null;
        _disqualificationLoading = false;
        _disqualificationSnippet =
            AppLocalizations.of(context).disqualificationLoadError;
      });
      return;
    }
    final pool = cat.allCriteriaTexts;
    if (pool.isEmpty) {
      setState(() {
        _disqualificationCatalog = cat;
        _disqualificationLoading = false;
        _disqualificationSnippet =
            AppLocalizations.of(context).disqualificationLoadError;
      });
      return;
    }
    setState(() {
      _disqualificationCatalog = cat;
      _disqualificationLoading = false;
      _disqualificationSnippet = pool[Random().nextInt(pool.length)];
    });
    _disqualificationTimer?.cancel();
    _disqualificationTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted) return;
      setState(() {
        _disqualificationSnippet = pool[Random().nextInt(pool.length)];
      });
    });
  }

  void _openDisqualificationDetail(BuildContext context) {
    final c = _disqualificationCatalog;
    if (c == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).disqualificationLoadError),
        ),
      );
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DisqualificationDetailScreen(catalog: c),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = Localizations.localeOf(context);
    if (_localeForCounts == null) {
      _localeForCounts = loc;
      return;
    }
    if (_localeForCounts != loc) {
      _localeForCounts = loc;
      QuestionService.setLanguageCode(loc.languageCode);
      _loadCounts();
    }
  }

  Future<void> _loadCounts() async {
    // 독립적인 I/O 호출을 병렬 실행하여 홈 화면 로딩 대기 시간을 최소화합니다.
    final fetched = await Future.wait([
      QuestionService.loadQuestionCountOnly(),
      AttemptedQuestionsService.loadAttemptedIds(),
      FavoriteQuestionsService.loadFavoriteIds(),
      WrongNoteService.loadWrongIds(),
      MockExamHistoryService.latestEntry(),
    ]);
    if (!mounted) return;
    setState(() {
      _totalCount = fetched[0] as int;
      _attemptedCount = (fetched[1] as Set<int>).length;
      _favoriteCount = (fetched[2] as Set<int>).length;
      _wrongCount = (fetched[3] as Set<int>).length;
      _latestMockExam = fetched[4] as MockExamHistoryEntry?;
      _loading = false;
    });
  }

  Future<void> _openFavorites(BuildContext context) async {
    final favIds = await FavoriteQuestionsService.loadFavoriteIds();
    if (!context.mounted) return;
    if (favIds.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackNoFavorites)),
      );
      return;
    }
    final byId = await QuestionService.loadAllQuestionsById();
    final favQs =
        favIds.map((id) => byId[id]).whereType<Question>().toList();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: favQs,
          title: l10n.quizTitleFavorites,
          showTimerAndScore: false,
        ),
      ),
    );
    await _loadCounts();
  }

  Future<void> _openWrongNote(BuildContext context) async {
    final ids = await WrongNoteService.loadWrongIds();
    if (!context.mounted) return;
    if (ids.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackNoWrong)),
      );
      return;
    }
    final byId = await QuestionService.loadAllQuestionsById();
    final wrongQuestions =
        ids.map((id) => byId[id]).whereType<Question>().toList();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: wrongQuestions,
          title: l10n.quizTitleWrong,
          showTimerAndScore: false,
        ),
      ),
    );
    await _loadCounts();
  }

  Future<void> _openMockExam(BuildContext context) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<MockExamLicenseKind>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mockLicenseSheetTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.mockLicenseSheetHint,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _PracticeTypeTile(
                  title: l10n.mockLicenseLabel(MockExamLicenseKind.type1Large),
                  subtitle: l10n.mockResultPassBar(
                    MockExamLicenseKind.type1Large.passScoreMinOutOf100,
                  ),
                  icon: Icons.local_shipping_outlined,
                  color: context.appColors.chipBg,
                  onTap: () => Navigator.pop(
                    sheetContext,
                    MockExamLicenseKind.type1Large,
                  ),
                ),
                const SizedBox(height: 8),
                _PracticeTypeTile(
                  title: l10n.mockLicenseLabel(MockExamLicenseKind.type1Special),
                  subtitle: l10n.mockResultPassBar(
                    MockExamLicenseKind.type1Special.passScoreMinOutOf100,
                  ),
                  icon: Icons.precision_manufacturing_outlined,
                  color: const Color(0xFFE9F3FF),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    MockExamLicenseKind.type1Special,
                  ),
                ),
                const SizedBox(height: 8),
                _PracticeTypeTile(
                  title: l10n.mockLicenseLabel(MockExamLicenseKind.type1Normal),
                  subtitle: l10n.mockResultPassBar(
                    MockExamLicenseKind.type1Normal.passScoreMinOutOf100,
                  ),
                  icon: Icons.directions_car_outlined,
                  color: const Color(0xFFEFFBF1),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    MockExamLicenseKind.type1Normal,
                  ),
                ),
                const SizedBox(height: 8),
                _PracticeTypeTile(
                  title: l10n.mockLicenseLabel(MockExamLicenseKind.type2Normal),
                  subtitle: l10n.mockResultPassBar(
                    MockExamLicenseKind.type2Normal.passScoreMinOutOf100,
                  ),
                  icon: Icons.drive_eta_outlined,
                  color: const Color(0xFFFFF3D6),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    MockExamLicenseKind.type2Normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null || !context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(mockExamLicenseKind: choice),
      ),
    );
    await _loadCounts();
  }

  Future<void> _openStats(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const StatsScreen()),
    );
  }

  Future<void> _openMockExamHistory(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const MockExamHistoryScreen()),
    );
    if (context.mounted) await _loadCounts();
  }

  Future<void> _openPracticeMenu(BuildContext context) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<_PracticeType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.practiceSheetTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _PracticeTypeTile(
                  title: l10n.practiceVerbalTitle,
                  subtitle: l10n.practiceVerbalSub,
                  icon: Icons.record_voice_over_outlined,
                  color: context.appColors.chipBg,
                  onTap: () =>
                      Navigator.pop(sheetContext, _PracticeType.speaking),
                ),
                const SizedBox(height: 8),
                _PracticeTypeTile(
                  title: l10n.practiceSignTitle,
                  subtitle: l10n.practiceSignSub,
                  icon: Icons.traffic_outlined,
                  color: const Color(0xFFE9F3FF),
                  onTap: () =>
                      Navigator.pop(sheetContext, _PracticeType.signAndSituation),
                ),
                const SizedBox(height: 8),
                _PracticeTypeTile(
                  title: l10n.practiceVideoTitle,
                  subtitle: l10n.practiceVideoSub,
                  icon: Icons.play_circle_outline_rounded,
                  color: const Color(0xFFFFF3D6),
                  onTap: () =>
                      Navigator.pop(sheetContext, _PracticeType.videoQuestion),
                ),
                const SizedBox(height: 8),
                _PracticeTypeTile(
                  title: l10n.practiceRandomTitle,
                  subtitle: l10n.practiceRandomSub,
                  icon: Icons.shuffle_rounded,
                  color: const Color(0xFFEFFBF1),
                  onTap: () =>
                      Navigator.pop(sheetContext, _PracticeType.randomAll),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (choice == null) return;

    List<Question> questions;
    String title;
    switch (choice) {
      case _PracticeType.speaking:
        if (!context.mounted) return;
        final subcategoryId = await _openVerbalSubcategorySheet(context);
        if (subcategoryId == null || !context.mounted) return;
        if (subcategoryId == _kAllVerbalMarker) {
          questions = await QuestionService.getRandomQuestionsByCategory(
            category: QuestionCategory.verbal,
            count: 40,
          );
          title = l10n.quizTitleVerbal;
        } else {
          questions = await QuestionService.getRandomQuestionsBySubcategory(
            subcategoryId: subcategoryId,
            count: 40,
          );
          title = l10n.quizTitleSubcategory(subcategoryId);
        }
        break;
      case _PracticeType.signAndSituation:
        questions = await QuestionService.getRandomQuestionsByCategory(
          category: QuestionCategory.signAndSituation,
          count: 40,
        );
        title = l10n.quizTitleSign;
        break;
      case _PracticeType.videoQuestion:
        questions = await QuestionService.getRandomQuestionsByCategory(
          category: QuestionCategory.video,
          count: 40,
        );
        title = l10n.quizTitleVideo;
        break;
      case _PracticeType.randomAll:
        questions = await QuestionService.getRandomQuestions(count: 40);
        title = l10n.quizTitleRandom;
        break;
    }

    if (!context.mounted || questions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackNoQuestionsForType)),
        );
      }
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: questions,
          title: title,
          showTimerAndScore: false,
          shuffleQuestions: true,
        ),
      ),
    );
    await _loadCounts();
  }

  /// "말문제" 선택 후 뜨는 2차 시트. 10개 소카테고리 + "전체" 옵션.
  /// 선택된 태그 ID 또는 "전체" 마커 [_kAllVerbalMarker] 를 반환. 취소 시 null.
  Future<String?> _openVerbalSubcategorySheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final counts = await QuestionSubcategoryService.loadCounts();
    if (!context.mounted) return null;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final maxSheetHeight =
            MediaQuery.sizeOf(sheetContext).height * 0.88;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subcategorySheetTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PracticeTypeTile(
                      title: l10n.subcategoryAllVerbalTitle,
                      subtitle: l10n.subcategoryAllVerbalSub,
                      icon: Icons.shuffle_rounded,
                      color: context.appColors.chipBg,
                      onTap: () => Navigator.pop(
                        sheetContext,
                        _kAllVerbalMarker,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...SubcategoryIds.verbalSubcategoryIds.map((id) {
                      final count = counts[id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SubcategoryTileWithStudy(
                          title: l10n.subcategoryLabel(id),
                          subtitle: l10n.subcategorySubtitle(id, count),
                          studyLabel: l10n.studyActionLabel,
                          icon: iconForSubcategory(id),
                          color: colorForSubcategory(context, id),
                          onTapPractice: () =>
                              Navigator.pop(sheetContext, id),
                          onTapStudy: () {
                            Navigator.pop(sheetContext);
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => StudyCardScreen(
                                  subcategoryId: id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progressLabel = _totalCount <= 0
        ? l10n.progressQuestions(0, 0)
        : l10n.progressQuestions(_attemptedCount, _totalCount);
    final mockScoreLine = _latestMockExam == null
        ? l10n.mockExamNoRecordYet
        : l10n.mockExamCardPoints(_latestMockExam!.scaledScoreOutOf100);

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Navigator.of(context).canPop())
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: context.appColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              Text(
                l10n.greetHello,
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.titleMain,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: _homeStatsRowHeight(context),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _LearningProgressCard(
                              progress: _progress,
                              progressText: progressLabel,
                              learningProgressLabel: l10n.learningProgress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              iconBg: context.appColors.chipBg,
                              icon: Icons.bar_chart_rounded,
                              title: l10n.mockExamScoreToday,
                              valueText: mockScoreLine,
                              onTap: () => _openMockExamHistory(context),
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 18),
              Text(
                l10n.problemTypes,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _MenuTile(
                icon: Icons.description_outlined,
                iconBg: context.appColors.chipBg,
                title: l10n.menuPracticeTitle,
                subtitle: l10n.menuPracticeSubtitle,
                onTap: () => _openPracticeMenu(context),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.star_rounded,
                iconBg: const Color(0xFFFFF3D6),
                title: l10n.menuFavoritesTitle,
                subtitle: l10n.menuFavoritesSubtitle(_favoriteCount),
                onTap: () => _openFavorites(context),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.close_rounded,
                iconBg: const Color(0xFFFFE3E3),
                title: l10n.menuWrongTitle,
                subtitle: l10n.menuWrongSubtitle(_wrongCount),
                badgeText: _wrongCount > 0 ? '$_wrongCount' : null,
                onTap: () => _openWrongNote(context),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.qr_code_2_rounded,
                iconBg: const Color(0xFFE9F3FF),
                title: l10n.menuMockTitle,
                subtitle: l10n.menuMockSubtitle,
                onTap: () => _openMockExam(context),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.analytics_outlined,
                iconBg: const Color(0xFFEDE9FE),
                title: l10n.statsTitle,
                subtitle: l10n.statsMenuSubtitle,
                onTap: () => _openStats(context),
              ),
              const SizedBox(height: 10),
              Material(
                color: context.appColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.appColors.borderLight),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.gpp_bad_outlined,
                          color: context.appColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.tipTitle,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: context.appColors.textPrimary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _disqualificationCatalog == null
                                      ? null
                                      : () => _openDisqualificationDetail(
                                            context,
                                          ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF15803D),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 0,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    l10n.disqualificationViewAll,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              child: Text(
                                _disqualificationLoading
                                    ? l10n.disqualificationLoading
                                    : _disqualificationSnippet,
                                key: ValueKey<String>(_disqualificationSnippet),
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.45,
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 메인 화면은 탭과 1:1로 매칭되지 않으므로 선택 강조를 두지 않습니다.
        currentIndex: 0,
        selectedItemColor: context.appColors.textSecondary,
        unselectedItemColor: context.appColors.textSecondary,
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        onTap: (i) {
          if (i == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExamGuideScreen(),
              ),
            );
            return;
          }
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PreparationGuideScreen(),
              ),
            );
            return;
          }
          if (i == 2) {
            ExamGuideScreen.openEducationSchedulePage(context);
            return;
          }
          if (i == 3) {
            ExamGuideScreen.openSchedulePage(context);
            return;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.format_list_numbered_rounded),
            label: l10n.navExamOrder,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist_outlined),
            label: l10n.navPrep,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school_outlined),
            label: l10n.navEduSchedule,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_available_outlined),
            label: l10n.navTestSchedule,
          ),
        ],
      ),
    );
  }
}

enum _PracticeType { speaking, signAndSituation, videoQuestion, randomAll }

/// 소카테고리 2차 시트에서 "말문제 전체" 를 나타내는 센티넬.
/// 태그 ID 문자열과 충돌하지 않는 값이면 됨.
const String _kAllVerbalMarker = '__all_verbal__';

class _PracticeTypeTile extends StatelessWidget {
  const _PracticeTypeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.appColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: context.appColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.appColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 소카테고리 시트 2차 타일. 큰 영역 탭 = 바로 풀기,
/// 우측 "공부하기" 버튼 탭 = 학습 카드 화면 이동.
class _SubcategoryTileWithStudy extends StatelessWidget {
  const _SubcategoryTileWithStudy({
    required this.title,
    required this.subtitle,
    required this.studyLabel,
    required this.icon,
    required this.color,
    required this.onTapPractice,
    required this.onTapStudy,
  });

  final String title;
  final String subtitle;
  final String studyLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTapPractice;
  final VoidCallback onTapStudy;

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    return InkWell(
      onTap: onTapPractice,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ac.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ac.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ac.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: ac.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // "공부하기" 보조 버튼 — 부모 InkWell 탭 차단을 위해 Material 로 감싼다
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTapStudy,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ac.chipBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: ac.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: ac.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        studyLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ac.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 오늘 모의고사 점수·학습 진도 카드 공통 (34×34, 아이콘 20pt, 중앙 정렬)
class _RoundedIconBadge extends StatelessWidget {
  const _RoundedIconBadge({
    required this.icon,
    required this.iconBg,
  });

  final IconData icon;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: context.appColors.primaryDark,
        size: 20,
      ),
    );
  }
}

class _LearningProgressCard extends StatelessWidget {
  const _LearningProgressCard({
    required this.progress,
    required this.progressText,
    required this.learningProgressLabel,
  });

  final double progress;
  final String progressText;
  final String learningProgressLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _RoundedIconBadge(
                    icon: Icons.menu_book_outlined,
                    iconBg: context.appColors.chipBg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  progressText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.textPrimary,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      learningProgressLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.appColors.borderLight,
              valueColor:
                  AlwaysStoppedAnimation<Color>(context.appColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.valueText,
    this.onTap,
  });

  final Color iconBg;
  final IconData icon;
  final String title;
  final String valueText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundedIconBadge(icon: icon, iconBg: iconBg),
          const SizedBox(height: 10),
          Text(
            valueText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: context.appColors.textPrimary,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.textSecondary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.appColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.borderLight),
        ),
        child: content,
      );
    }

    return Material(
      color: context.appColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.borderLight),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.borderLight),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: context.appColors.primaryDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeText != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Icon(Icons.chevron_right_rounded,
                  color: context.appColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
