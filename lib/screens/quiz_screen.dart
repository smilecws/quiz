import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../models/mock_exam_license_kind.dart';
import '../models/mock_exam_history_entry.dart';
import '../models/question.dart';
import '../models/session_result.dart';
import '../services/attempted_questions_service.dart';
import '../services/favorite_questions_service.dart';
import '../services/global_answer_stats_service.dart';
import '../services/mock_exam_history_service.dart';
import '../services/question_service.dart';
import '../services/user_answer_log_service.dart';
import '../services/user_answer_stats_service.dart';
import '../services/wrong_note_service.dart';
import '../theme/app_theme_colors.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question>? questions;
  final String? title;
  /// `true`면 화면 진입 시 문항 순서를 섞습니다.
  /// (예: "전체 문제 풀기"에서 항상 랜덤 순서로 시작)
  final bool shuffleQuestions;
  /// `true`: 시험 모드(모의고사) — 40분 타이머·점수 표시
  /// `false`: 미풀이/즐겨찾기/오답 — 총 문항 수만 우측 상단 표시
  final bool showTimerAndScore;

  /// 모의고사에서 선택한 면허 종류(합격 점수 기준). null이면 결과 화면은 기존 등급 표시만 사용.
  final MockExamLicenseKind? mockExamLicenseKind;

  const QuizScreen({
    super.key,
    this.questions,
    this.title,
    this.shuffleQuestions = false,
    this.showTimerAndScore = true,
    this.mockExamLicenseKind,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const Duration _timeLimit = Duration(minutes: 40);

  List<Question> _questions = [];
  int _currentIndex = 0;
  int? _selectedSingle;
  final Set<int> _selectedMultiple = {};
  bool _answered = false;
  final List<SessionResult> _results = [];
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();
  static const int _kMaxImageDataUriCache = 24;
  final Map<String, Uint8List?> _imageBytesCache = {};
  Timer? _timer;
  int _remainingSeconds = _timeLimit.inSeconds;
  Set<int> _favoriteIds = {};
  bool _finishing = false;
  /// 세션 시작 시각(문제 로드 완료 직후). 풀이 이력 로깅에 사용.
  DateTime? _sessionStartedAt;
  VideoPlayerController? _videoController;
  Future<void>? _videoInit;

  /// 웹·핫리스타트에서 `VideoPlayer`가 아직 붙어 있는 동안 컨트롤러를 `dispose`하면
  /// `used after being disposed`가 난다. 다음 프레임에 정리한다.
  void _disposeVideoLater(VideoPlayerController? c) {
    if (c == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.dispose();
    });
  }
  String? _loadedVideoUri;

  Question get _q => _questions[_currentIndex];

  Iterable<int> _attemptedIdsSoFar() {
    final ids = _results.map((r) => r.questionId).toSet();
    if (!_loading && _questions.isNotEmpty && _answered) {
      ids.add(_q.id);
    }
    return ids;
  }

  Future<void> _saveAttemptedSoFar() async {
    final ids = _attemptedIdsSoFar();
    if (ids.isEmpty) return;
    await AttemptedQuestionsService.markSessionAttempted(ids);
  }

  /// 현재 선택 상태를 [SessionResult]로 변환합니다.
  SessionResult _buildSessionResult(Question q) {
    final Object? selectedObj = _currentSelectedObject(q);
    final bool isCorrect = _isCorrectAnswer(q, selectedObj);
    final List<int> selectedIndices;
    if (selectedObj is int) {
      selectedIndices = [selectedObj];
    } else if (selectedObj is Set<int>) {
      selectedIndices = selectedObj.toList()..sort();
    } else {
      selectedIndices = const [];
    }
    return SessionResult(
      questionId: q.id,
      question: q,
      selectedIndices: selectedIndices,
      isCorrect: isCorrect,
    );
  }

  List<SessionResult> _resultsSoFarForPersistence() {
    final byId = <int, SessionResult>{
      for (final r in _results) r.questionId: r,
    };

    if (!_loading && _questions.isNotEmpty && _answered) {
      final currentQ = _q;
      if (!byId.containsKey(currentQ.id)) {
        byId[currentQ.id] = _buildSessionResult(currentQ);
      }
    }

    return byId.values.toList(growable: false);
  }

  Future<void> _saveWrongNoteSoFar() async {
    final results = _resultsSoFarForPersistence();
    if (results.isEmpty) return;
    await WrongNoteService.applySessionResults(results);
  }

  Future<void> _saveStatsSoFar() async {
    final results = _resultsSoFarForPersistence();
    if (results.isEmpty) return;
    await Future.wait([
      UserAnswerStatsService.applySessionResults(results),
      GlobalAnswerStatsService.applySessionResults(results),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    final v = _videoController;
    _videoController = null;
    _videoInit = null;
    _disposeVideoLater(v);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _prepareVideoForQuestion(Question q) async {
    final uri = q.videoUri;
    if (uri == null || uri.isEmpty) {
      final old = _videoController;
      _videoController = null;
      _videoInit = null;
      _loadedVideoUri = null;
      _disposeVideoLater(old);
      return;
    }
    if (_loadedVideoUri == uri) return;

    final old = _videoController;
    _videoController = null;
    _videoInit = null;
    _loadedVideoUri = uri;
    _disposeVideoLater(old);

    // 웹(Chrome)에서는 WMV가 재생되지 않습니다(HTML5 video 미지원).
    // 이 경우 "재생 불가" 카드로 자연스럽게 안내합니다.
    if (kIsWeb && uri.toLowerCase().endsWith('.wmv')) {
      return;
    }

    try {
      final controller = uri.startsWith('https://')
          ? VideoPlayerController.networkUrl(Uri.parse(uri))
          : VideoPlayerController.asset(uri);
      controller.setLooping(true);
      _videoController = controller;
      _videoInit = controller.initialize();
      await _videoInit;
      if (!mounted) return;
      setState(() {});
      await controller.play();
    } catch (_) {
      final failed = _videoController;
      _videoController = null;
      _videoInit = null;
      _disposeVideoLater(failed);
    }
  }

  Future<void> _loadQuestions() async {
    final questions = widget.questions ??
        await QuestionService.getRandomQuestions(count: 40);
    final List<Question> prepared =
        widget.shuffleQuestions ? (List<Question>.from(questions)..shuffle()) : questions;
    final fav = await FavoriteQuestionsService.loadFavoriteIds();
    if (!mounted) return;
    setState(() {
      _questions = prepared;
      _favoriteIds = fav;
      _loading = false;
    });
    if (_questions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문제를 불러오지 못했어요. (문항 0개)')),
      );
      Navigator.pop(context);
      return;
    }
    await _prepareVideoForQuestion(_q);
    _sessionStartedAt = DateTime.now();
    if (widget.showTimerAndScore) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = _timeLimit.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) return;
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds == 0) {
        _finishDueToTimeLimit();
      }
    });
  }

  String get _timeText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _resetForNext() {
    _selectedSingle = null;
    _selectedMultiple.clear();
    _answered = false;
  }

  Uint8List? _getImageBytes(String dataUri) {
    final hit = _imageBytesCache[dataUri];
    if (hit != null) return hit;
    final decoded = decodeImageDataUri(dataUri);
    _imageBytesCache[dataUri] = decoded;
    while (_imageBytesCache.length > _kMaxImageDataUriCache) {
      _imageBytesCache.remove(_imageBytesCache.keys.first);
    }
    return decoded;
  }

  void _onOptionTap(int index) {
    if (!widget.showTimerAndScore && _answered) return;
    final q = _q;
    if (q.isMultipleChoice) {
      setState(() {
        if (_selectedMultiple.contains(index)) {
          _selectedMultiple.remove(index);
        } else {
          _selectedMultiple.add(index);
        }
      });
    } else {
      setState(() {
        _selectedSingle = index;
        // 모의고사에서는 즉시 정답/채점/해설을 공개하지 않습니다.
        if (!widget.showTimerAndScore) {
          _answered = true;
          if (index == q.correctIndices.first) {
          }
        }
      });
    }
  }

  void _submitMultiple() {
    // 모의고사에서는 '정답 확인' 버튼을 사용하지 않습니다.
    if (widget.showTimerAndScore) return;
    if (_answered || !_q.isMultipleChoice) return;
    if (_selectedMultiple.isEmpty) return;
    final correct = _q.correctIndexSet;
    final selected = Set<int>.from(_selectedMultiple);
    setState(() {
      _answered = true;
      if (correct.length == selected.length &&
          correct.containsAll(selected)) {
      }
    });
  }

  bool get _canProceed {
    if (widget.showTimerAndScore) return true;
    return _answered;
  }

  bool get _canSubmitMultiple {
    if (widget.showTimerAndScore) return false;
    return _q.isMultipleChoice &&
        !_answered &&
        _selectedMultiple.isNotEmpty;
  }

  bool _isCorrectAnswer(Question q, Object? selected) {
    if (q.isMultipleChoice) {
      final sel = selected is Set<int> ? selected : <int>{};
      final correct = q.correctIndexSet;
      return correct.length == sel.length && correct.containsAll(sel);
    }
    final sel = selected as int?;
    return sel != null && sel == q.correctIndices.first;
  }

  Object? _currentSelectedObject(Question q) {
    if (q.isMultipleChoice) {
      if (_selectedMultiple.isEmpty) return null;
      return Set<int>.from(_selectedMultiple);
    }
    return _selectedSingle;
  }

  Future<void> _finalizeAndGoToResults() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();

    // 이미 기록된 결과를 questionId로 맵핑
    final Map<int, SessionResult> byId = {
      for (final r in _results) r.questionId: r,
    };

    // 현재 문제에서 답을 선택했는데 '다음 문제'를 안 누른 경우도 반영
    final currentQ = _q;
    if (!byId.containsKey(currentQ.id)) {
      byId[currentQ.id] = _buildSessionResult(currentQ);
    }

    // 미답 문제는 오답(선택 없음)으로 채움
    final List<SessionResult> allResults = _questions.map((q) {
      return byId[q.id] ??
          SessionResult(
            questionId: q.id,
            question: q,
            selectedIndices: const [],
            isCorrect: false,
          );
    }).toList();

    final newScore = allResults.where((r) => r.isCorrect).length;

    if (widget.mockExamLicenseKind != null) {
      final wrongIds = allResults
          .where((r) => !r.isCorrect)
          .map((r) => r.questionId)
          .toList();
      await MockExamHistoryService.addRecord(
        MockExamHistoryEntry(
          atMillis: DateTime.now().millisecondsSinceEpoch,
          licenseKind: widget.mockExamLicenseKind!,
          score: newScore,
          total: _questions.length,
          wrongQuestionIds: wrongIds,
        ),
      );
    }

    // 독립적인 저장 작업은 병렬로 실행
    await Future.wait([
      WrongNoteService.applySessionResults(allResults),
      AttemptedQuestionsService.markSessionAttempted(
        _questions.map((q) => q.id),
      ),
      UserAnswerStatsService.applySessionResults(allResults),
      GlobalAnswerStatsService.applySessionResults(allResults),
      UserAnswerLogService.saveSession(
        allResults,
        licenseKind: widget.mockExamLicenseKind,
        startedAt: _sessionStartedAt,
      ),
    ]);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: newScore,
          total: _questions.length,
          results: allResults,
          mockExamLicenseKind: widget.mockExamLicenseKind,
        ),
      ),
    );
  }

  void _finishDueToTimeLimit() {
    if (!mounted) return;
    _finalizeAndGoToResults();
  }

  Future<void> _nextQuestion() async {
    if (!_canProceed) return;
    final q = _q;
    final result = _buildSessionResult(q);
    _results.add(result);

    if (_currentIndex + 1 < _questions.length) {
      // setState를 먼저 하면 새 문항의 videoUri와 이전 VideoPlayerController가
      // 한 프레임 겹쳐 dispose된 컨트롤러로 VideoPlayer가 붙는 경우가 있음(웹·핫리스타트).
      final nextQ = _questions[_currentIndex + 1];
      await _prepareVideoForQuestion(nextQ);
      if (!mounted) return;
      setState(() {
        _currentIndex++;
        _resetForNext();
      });
      // 다음 문제는 항상 상단부터 보이도록 이동 (답 선택 시에는 스크롤 유지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.jumpTo(0);
      });
    } else {
      await _finalizeAndGoToResults();
    }
  }

  Future<void> _toggleFavorite() async {
    await FavoriteQuestionsService.toggle(_q.id);
    final next = await FavoriteQuestionsService.loadFavoriteIds();
    if (mounted) setState(() => _favoriteIds = next);
  }

  Color _optionColor(AppThemeColors ac, int index) {
    if (widget.showTimerAndScore || !_answered) return ac.surfaceCard;
    final q = _q;
    final isCorrect = q.correctIndexSet.contains(index);
    if (isCorrect) return const Color(0xFFDCFCE7);
    if (q.isMultipleChoice) {
      if (_selectedMultiple.contains(index)) return const Color(0xFFFEE2E2);
    } else {
      if (index == _selectedSingle) return const Color(0xFFFEE2E2);
    }
    return ac.surfaceCard;
  }

  Color _optionBorderColor(AppThemeColors ac, int index) {
    if (widget.showTimerAndScore || !_answered) {
      if (_q.isMultipleChoice && _selectedMultiple.contains(index)) {
        return ac.primary;
      }
      if (!_q.isMultipleChoice && _selectedSingle == index) {
        return ac.primary;
      }
      return ac.borderLight;
    }
    final q = _q;
    if (q.correctIndexSet.contains(index)) return Colors.green;
    if (q.isMultipleChoice && _selectedMultiple.contains(index)) {
      return Colors.red;
    }
    if (!q.isMultipleChoice && index == _selectedSingle) return Colors.red;
    return ac.borderLight;
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    if (_loading) {
      return Scaffold(
        backgroundColor: ac.background,
        body: Center(
          child: CircularProgressIndicator(
            color: ac.primary,
            strokeWidth: 3,
          ),
        ),
      );
    }

    final question = _q;
    final progress = (_currentIndex + 1) / _questions.length;
    final navigator = Navigator.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(Future.wait([
          _saveAttemptedSoFar(),
          _saveWrongNoteSoFar(),
          _saveStatsSoFar(),
        ]).whenComplete(() {
          if (!mounted) return;
          navigator.pop(result);
        }));
      },
      child: Scaffold(
        backgroundColor: ac.background,
        appBar: AppBar(
          title: Text(
            widget.title ?? '${_currentIndex + 1} / ${_questions.length}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
          IconButton(
            tooltip: _favoriteIds.contains(question.id)
                ? '즐겨찾기 해제'
                : '즐겨찾기',
            onPressed: _toggleFavorite,
            icon: Icon(
              _favoriteIds.contains(question.id)
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: _favoriteIds.contains(question.id)
                  ? Colors.amber.shade700
                  : ac.textSecondary,
            ),
          ),
          if (widget.showTimerAndScore) ...[
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_remainingSeconds <= 60)
                        ? const Color(0xFFFEE2E2)
                        : ac.surfaceCard,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: (_remainingSeconds <= 60)
                          ? Colors.red.shade200
                          : ac.borderLight,
                    ),
                  ),
                  child: Text(
                    _timeText,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: (_remainingSeconds <= 60)
                          ? Colors.red.shade700
                          : ac.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '채점 전',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ac.textSecondary,
                  ),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ac.surfaceCard,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: ac.borderLight),
                  ),
                  child: Text(
                    '총 ${_questions.length}문제',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ac.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: ac.borderLight,
            color: ac.primary,
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey('quiz_scroll'),
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  if (question.isMultipleChoice)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(
                        avatar: Icon(Icons.checklist, size: 18, color: ac.primaryDark),
                        label: const Text('복수 선택 — 해당하는 보기를 모두 고르세요'),
                        backgroundColor: ac.chipBg,
                        side: BorderSide(color: ac.primary.withValues(alpha: 0.25)),
                        labelStyle: TextStyle(
                          color: ac.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Text(
                      'Q${_currentIndex + 1}. ${question.question}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: ac.textPrimary,
                      ),
                    ),
                  ),
                  if (question.videoUri != null) ...[
                    const SizedBox(height: 16),
                    _VideoCard(
                      key: ValueKey(
                        '${question.id}_${question.videoUri}_'
                        '${_videoController?.hashCode ?? 0}',
                      ),
                      init: _videoInit,
                      controller: _videoController,
                      videoUri: question.videoUri!,
                    ),
                  ],
                  if (question.hasImages) ...[
                    const SizedBox(height: 16),
                    ...question.imageUris.map((uri) {
                      final bytes = _getImageBytes(uri);
                      final caption = question.imageCaptionsByUri[uri];
                      final isSignAndSituation =
                          question.category == '표지 및 상황문제';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final imageCaptionStyle = GoogleFonts.jua(
                              fontSize: 14,
                              height: 1.3,
                              color: ac.textSecondary,
                              fontWeight: FontWeight.w600,
                            );
                            final baseW = constraints.maxWidth * 0.5;

                            Widget imageBlock({
                              required double width,
                              required BoxFit fit,
                            }) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: width,
                                  color: ac.surfaceWhite,
                                  child: bytes != null
                                      ? Image.memory(
                                          bytes,
                                          fit: fit,
                                          gaplessPlayback: true,
                                        )
                                      : Image.asset(
                                          uri,
                                          fit: fit,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              size: 40,
                                              color: ac.textSecondary
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            }

                            final captionText = caption?.trim();
                            final hasCaption = captionText != null &&
                                captionText.isNotEmpty;

                            if (isSignAndSituation) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  imageBlock(
                                    width: constraints.maxWidth,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  if (hasCaption) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      captionText,
                                      textAlign: TextAlign.center,
                                      style: imageCaptionStyle,
                                    ),
                                  ],
                                ],
                              );
                            }

                            final w = baseW;
                            return Center(
                              child: SizedBox(
                                width: w,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    imageBlock(
                                      width: w,
                                      fit: BoxFit.contain,
                                    ),
                                    if (hasCaption) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        captionText,
                                        textAlign: TextAlign.center,
                                        style: imageCaptionStyle,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                  ...List.generate(question.options.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _onOptionTap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _optionColor(ac, i),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _optionBorderColor(ac, i),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (question.isMultipleChoice)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    _selectedMultiple.contains(i)
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: ac.primary,
                                  ),
                                ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: ac.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: GoogleFonts.jua(
                                      fontWeight: FontWeight.bold,
                                      color: ac.primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[i],
                                  style: GoogleFonts.jua(
                                    fontSize: 16,
                                    color: ac.textPrimary,
                                  ),
                                ),
                              ),
                              if (!widget.showTimerAndScore &&
                                  _answered &&
                                  question.correctIndexSet.contains(i))
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                              if (!widget.showTimerAndScore &&
                                  _answered &&
                                  !question.correctIndexSet.contains(i) &&
                                  (question.isMultipleChoice
                                      ? _selectedMultiple.contains(i)
                                      : _selectedSingle == i))
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (!widget.showTimerAndScore && _answered) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ac.chipBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ac.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              color: ac.primaryDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              question.explanation,
                              style: GoogleFonts.jua(
                                fontSize: 14,
                                color: ac.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                if (!widget.showTimerAndScore &&
                    question.isMultipleChoice &&
                    !_answered) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canSubmitMultiple ? _submitMultiple : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ac.primaryDark,
                        foregroundColor: ac.onPrimary,
                        disabledBackgroundColor: ac.borderLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '정답 확인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed
                        ? () async {
                            await _nextQuestion();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ac.primary,
                      foregroundColor: ac.onPrimary,
                      disabledBackgroundColor: ac.borderLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentIndex + 1 < _questions.length
                          ? '다음 문제'
                          : '결과 보기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _VideoCard extends StatefulWidget {
  const _VideoCard({
    super.key,
    required this.init,
    required this.controller,
    required this.videoUri,
  });

  final Future<void>? init;
  final VideoPlayerController? controller;
  final String videoUri;

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  @override
  Widget build(BuildContext context) {
    final ac = context.appColors;
    final init = widget.init;
    final controller = widget.controller;
    if (init == null || controller == null) {
      final isWmvOnWeb = kIsWeb && widget.videoUri.toLowerCase().endsWith('.wmv');
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ac.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ac.borderLight),
        ),
        child: Text(
          isWmvOnWeb
              ? '이 동영상은 웹에서 재생할 수 없습니다. (WMV 미지원)\nWindows 앱으로 실행해 주세요.\n(${widget.videoUri})'
              : '동영상을 재생할 수 없습니다.\n(${widget.videoUri})',
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: ac.textSecondary,
          ),
        ),
      );
    }

    return FutureBuilder<void>(
      future: init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ac.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ac.borderLight),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  '동영상 로딩 중…',
                  style: TextStyle(
                    fontSize: 13,
                    color: ac.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final aspect = controller.value.aspectRatio == 0
            ? (16 / 9)
            : controller.value.aspectRatio;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ac.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ac.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: aspect,
                  child: VideoPlayer(controller),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    tooltip: controller.value.isPlaying ? '일시정지' : '재생',
                    onPressed: () async {
                      // 컨트롤러가 교체/정리되는 타이밍(웹·핫리스타트 포함)에도
                      // dispose된 컨트롤러에 pause/play를 호출하지 않도록 방어합니다.
                      final c = controller;
                      if (!mounted || widget.controller != c) return;
                      final shouldPause = c.value.isPlaying;
                      try {
                        if (shouldPause) {
                          await c.pause();
                        } else {
                          await c.play();
                        }
                      } catch (_) {
                        return;
                      }
                      if (!mounted || widget.controller != c) return;
                      setState(() {});
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 30,
                      color: ac.primaryDark,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '동영상 문제',
                      style: TextStyle(
                        fontSize: 13,
                        color: ac.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
