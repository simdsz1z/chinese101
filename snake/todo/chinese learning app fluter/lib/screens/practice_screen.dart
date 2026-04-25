import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/course_data.dart';
import '../gamification/gamification_service.dart';
import '../models/learning_models.dart';
import '../models/study_content.dart';
import '../models/training_mode.dart';
import '../theme/app_theme.dart';

class _PracticeItem {
  final String character;
  final String pinyin;
  final String answer;
  final List<String> options;
  final int level;
  final String category;
  final List<String> tags;
  final TrainingModeType mode;
  final String? hintCharacter;

  const _PracticeItem({
    required this.character,
    required this.pinyin,
    required this.answer,
    required this.options,
    this.level = 0,
    this.category = '',
    this.tags = const [],
    this.mode = TrainingModeType.mcq,
    this.hintCharacter,
  });

  factory _PracticeItem.fromMap(Map<String, dynamic> map) {
    return _PracticeItem(
      character: map['char'] as String? ?? '',
      pinyin: map['pinyin'] as String? ?? '',
      answer: map['meaning'] as String? ?? '',
      options: (map['options'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      level: map['level'] as int? ?? 0,
      category: map['category'] as String? ?? '',
      tags: (map['tags'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      mode: map['mode'] as TrainingModeType? ?? TrainingModeType.mcq,
      hintCharacter: map['char'] as String?,
    );
  }
}

class _DrawingPad extends StatelessWidget {
  final String targetCharacter;
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final ValueChanged<DragStartDetails> onPanStart;
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final VoidCallback onPanEnd;
  final VoidCallback onClear;

  const _DrawingPad({
    required this.targetCharacter,
    required this.strokes,
    required this.currentStroke,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  targetCharacter,
                  style: TextStyle(
                    fontSize: 150,
                    fontWeight: FontWeight.w200,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: GestureDetector(
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: (_) => onPanEnd(),
                    child: CustomPaint(
                      painter: _StrokePainter(
                        strokes: strokes,
                        currentStroke: currentStroke,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Trace over the faded hanzi or write it from memory, then submit.',
          style: TextStyle(color: AppColors.textDim),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  const _StrokePainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }
    _drawStroke(canvas, currentStroke, paint);
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}

class PracticeScreen extends StatefulWidget {
  final String lessonId;
  final TrainingModeType trainingMode;
  final int? levelFilter;
  final String? categoryFilter;
  final String? tagFilter;
  final bool includeAllContent;

  const PracticeScreen({
    super.key,
    required this.lessonId,
    this.trainingMode = TrainingModeType.mcq,
    this.levelFilter,
    this.categoryFilter,
    this.tagFilter,
    this.includeAllContent = false,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final bool isReview;
  late final Lesson? lesson;
  late final List<_PracticeItem> items;
  int currentIndex = 0;
  String? selectedOption;
  bool? isCorrect;
  int score = 0;
  bool finished = false;
  int combo = 0;
  final TextEditingController answerController = TextEditingController();
  DateTime? questionStartedAt;
  List<List<Offset>> strokes = <List<Offset>>[];
  List<Offset> currentStroke = <Offset>[];

  @override
  void initState() {
    super.initState();
    isReview =
        widget.lessonId == 'review' ||
        widget.lessonId == 'boss' ||
        widget.lessonId == 'playground';
    final matchingLessons = courseLevels
        .where((entry) => entry.id == widget.lessonId)
        .toList();
    lesson = matchingLessons.isEmpty ? null : matchingLessons.first;
    final service = context.read<GamificationService>();
    items = isReview
        ? _buildScopedReviewItems(service)
        : _buildLessonItems(widget.lessonId);
    questionStartedAt = DateTime.now();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  _PracticeItem get currentItem => items[currentIndex];
  TrainingModeType get currentMode => currentItem.mode;
  bool get usesInputMode => currentMode == TrainingModeType.recall;
  bool get usesDrawingMode => currentMode == TrainingModeType.drawing;

  List<_PracticeItem> _buildScopedReviewItems(GamificationService service) {
    if (widget.trainingMode == TrainingModeType.errorBoss) {
      return service.bossFightPool.take(5).map(_PracticeItem.fromMap).toList();
    }

    final sourceItems = widget.includeAllContent
        ? _buildItemsFromCollections(studyCollections)
        : _buildItemsFromCollections(
            studyCollections.where((collection) {
              final learnedIds = service.progress
                  .map((item) => item.itemId)
                  .toSet();
              return collection.characterIds.any(learnedIds.contains);
            }).toList(),
          );

    final filtered = sourceItems.where((item) {
      final matchesLevel =
          widget.levelFilter == null || item.level == widget.levelFilter;
      final matchesCategory =
          widget.categoryFilter == null ||
          item.category == widget.categoryFilter;
      final matchesTag =
          widget.tagFilter == null || item.tags.contains(widget.tagFilter);
      final matchesMode = item.mode == widget.trainingMode;
      return matchesLevel && matchesCategory && matchesTag && matchesMode;
    }).toList();

    if (filtered.isNotEmpty) {
      return filtered.take(8).toList();
    }
    return service.reviewPool.take(5).map(_PracticeItem.fromMap).toList();
  }

  List<_PracticeItem> _buildLessonItems(String lessonId) {
    final matchingLessons = courseLevels
        .where((entry) => entry.id == lessonId)
        .toList();
    final selectedLesson = matchingLessons.isEmpty
        ? null
        : matchingLessons.first;
    if (selectedLesson == null) return [];

    if (selectedLesson.questions.isNotEmpty) {
      return selectedLesson.questions.map((question) {
        return _PracticeItem(
          character: question.prompt,
          pinyin: question.mode.name.toUpperCase(),
          answer: question.answer,
          options: question.options.isEmpty
              ? [question.answer]
              : question.options,
          level: selectedLesson.level,
          category: selectedLesson.hskBand,
          tags: [question.mode.name],
          mode: question.mode,
          hintCharacter: question.answer,
        );
      }).toList();
    }

    final meanings = courseLevels
        .expand(
          (entry) => entry.characters.map((character) => character.meaning),
        )
        .toList();

    return selectedLesson.characters.map((character) {
      final distractors = meanings
          .where((item) => item != character.meaning)
          .take(3)
          .toList();
      final options = [...distractors, character.meaning]..sort();
      return _PracticeItem(
        character: character.char,
        pinyin: character.pinyin,
        answer: character.meaning,
        options: options,
        level: selectedLesson.level,
        category: selectedLesson.title.toLowerCase(),
        tags: const [],
        mode: widget.trainingMode,
      );
    }).toList();
  }

  List<_PracticeItem> _buildItemsFromCollections(
    List<StudyCollection> collections,
  ) {
    final meaningMap = {
      for (final lesson in courseLevels)
        for (final character in lesson.characters)
          character.char: character.meaning,
    };
    final pinyinMap = {
      for (final lesson in courseLevels)
        for (final character in lesson.characters)
          character.char: character.pinyin,
    };
    final allMeanings = meaningMap.values.toList();

    return collections.expand((collection) {
      return collection.characterIds.map((id) {
        final answer = meaningMap[id] ?? id;
        final distractors = allMeanings
            .where((item) => item != answer)
            .take(3)
            .toList();
        return _PracticeItem(
          character: widget.trainingMode == TrainingModeType.drawing
              ? 'Draw: $answer'
              : id,
          pinyin: pinyinMap[id] ?? id,
          answer: answer,
          options: [...distractors, answer]..sort(),
          level: collection.level,
          category: collection.category,
          tags: collection.tags,
          mode: widget.trainingMode,
          hintCharacter: id,
        );
      });
    }).toList();
  }

  Future<void> _finishSession() async {
    final service = context.read<GamificationService>();
    if (isReview) {
      await service.completeReview(
        score,
        items.map((item) => item.hintCharacter ?? item.character).toList(),
      );
    } else if (lesson != null) {
      await service.completeLesson(lesson!, score);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  int _speedBonus() {
    if (currentMode != TrainingModeType.speed || questionStartedAt == null) {
      return 0;
    }
    final elapsed = DateTime.now().difference(questionStartedAt!).inSeconds;
    if (elapsed <= 2) return 15;
    if (elapsed <= 4) return 8;
    return 0;
  }

  int get _drawPointCount =>
      strokes.fold<int>(0, (total, stroke) => total + stroke.length) +
      currentStroke.length;

  int get _drawStrokeCount =>
      strokes.where((stroke) => stroke.isNotEmpty).length +
      (currentStroke.isNotEmpty ? 1 : 0);

  void _clearCanvas() {
    setState(() {
      strokes = <List<Offset>>[];
      currentStroke = <Offset>[];
    });
  }

  void _resetStepState() {
    selectedOption = null;
    isCorrect = null;
    answerController.clear();
    questionStartedAt = DateTime.now();
    strokes = <List<Offset>>[];
    currentStroke = <Offset>[];
  }

  /// Validates and checks the user's answer against the prompt type.
  void _checkAnswer() {
    final currentItem = items[currentIndex];
    final response = (selectedOption ?? answerController.text)
        .trim()
        .toLowerCase();
    bool correct = false;

    if (currentMode == TrainingModeType.recall) {
      // Determine what type of answer this prompt expects
      final isPinyinPrompt =
          currentItem.tags.contains('pinyin') ||
          currentItem.character.contains('Meaning:');
      final isHanziPrompt =
          currentItem.character.contains('Draw:') ||
          currentItem.character.contains('&');

      if (isPinyinPrompt) {
        // Check for pinyin prompts - accept exact match or prefixed format
        final isExactPinyin = response == currentItem.pinyin.toLowerCase();
        final isPrefixedPinyin =
            response.startsWith('pinyin:') &&
            response.substring(8).trim().toLowerCase() ==
                currentItem.pinyin.toLowerCase();
        if (isExactPinyin || isPrefixedPinyin) {
          correct = true;
        }
      } else if (isHanziPrompt) {
        // Check for hanzi prompts - accept exact match or prefixed format
        final isExactHanzi =
            response == currentItem.hintCharacter?.toLowerCase() ||
            response == currentItem.answer.toLowerCase();
        final isPrefixedHanzi =
            response.startsWith('hanzi:') &&
            response.substring(7).trim().toLowerCase() ==
                currentItem.character.replaceAll('Draw: ', '').toLowerCase();
        if (isExactHanzi || isPrefixedHanzi) {
          correct = true;
        }
      } else {
        // Default to checking against the stored answer (meaning)
        final isExactAnswer = response == currentItem.answer.toLowerCase();
        // Also accept hanzi for regular recall (backward compatibility)
        final isHintCharacterMatch =
            response == (currentItem.hintCharacter ?? '').toLowerCase();
        if (isExactAnswer || isHintCharacterMatch) {
          correct = true;
        }
      }
    } else {
      // MCQ speed mode - accept the selected option as valid
      if (selectedOption != null) {
        correct =
            currentItem.answer.toLowerCase() == selectedOption!.toLowerCase();
      }
    }

    // Update score and combo based on correctness
    if (correct) {
      score +=
          10 +
          _speedBonus() +
          (usesInputMode ? 10 : 0) +
          (usesDrawingMode ? 12 : 0);
      combo += 1;
    } else {
      combo = 0;
      context.read<GamificationService>().recordMistake(
        currentItem.hintCharacter ?? currentItem.character,
      );
    }

    setState(() {
      isCorrect = correct;
    });
  }

  /// Returns formatted feedback text based on whether the answer was correct.
  String _feedbackText() {
    final currentItem = items[currentIndex];
    // For wrong answers - show correct answer with pinyin and meaning
    if (!isCorrect!) {
      return 'Incorrect!\n\nCorrect answer: ${currentItem.answer}';
    }

    // For correct answers - show celebratory feedback with details
    final parts = <String>['Correct!'];

    // Add pinyin for recall mode
    if (currentMode == TrainingModeType.recall) {
      parts.add('Pinyin: ${currentItem.pinyin}');
    }

    // Add meaning
    parts.add('Meaning: ${currentItem.answer}');

    return parts.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rotate_left,
                  color: AppColors.accent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nothing to review yet',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Finish at least one lesson first, then come back for review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDim),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (finished) {
      final earnedXp = isReview ? 20 + score : (lesson?.xpReward ?? 0) + score;
      final earnedCoins = isReview
          ? 10 + (score ~/ 10)
          : (lesson?.coinsReward ?? 0) + (score ~/ 5);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 68,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isReview ? 'Review Session Complete' : 'Lesson Completed',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You earned $earnedXp XP',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  '$earnedCoins coins',
                  style: const TextStyle(fontSize: 18, color: AppColors.gold),
                ),
                if (currentMode == TrainingModeType.speed) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Best combo: $combo',
                    style: const TextStyle(color: AppColors.textDim),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _finishSession,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: AppColors.accent,
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final item = currentItem;
    final progress = (currentIndex + 1) / items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _titleLabel(),
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.character,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: usesDrawingMode ? 36 : 110,
                        fontWeight: usesDrawingMode
                            ? FontWeight.w700
                            : FontWeight.w200,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_getSubtitle().isNotEmpty)
                      Text(
                        _getSubtitle(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      item.pinyin.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        color: AppColors.textDim,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _getAnswerTypeLabel(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textDim,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _promptLabel(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDim,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (usesDrawingMode)
                      _DrawingPad(
                        targetCharacter: item.hintCharacter ?? item.character,
                        strokes: strokes,
                        currentStroke: currentStroke,
                        onPanStart: (details) {
                          setState(() {
                            currentStroke = [details.localPosition];
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            currentStroke = [
                              ...currentStroke,
                              details.localPosition,
                            ];
                          });
                        },
                        onPanEnd: () {
                          setState(() {
                            if (currentStroke.isNotEmpty) {
                              strokes = [...strokes, currentStroke];
                            }
                            currentStroke = <Offset>[];
                          });
                        },
                        onClear: _clearCanvas,
                      )
                    else if (usesInputMode)
                      TextField(
                        controller: answerController,
                        enabled: isCorrect == null,
                        decoration: InputDecoration(
                          hintText: 'Type your answer',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => selectedOption = value.trim()),
                      )
                    else
                      ...item.options.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OutlinedButton(
                            onPressed: isCorrect == null
                                ? () => setState(() => selectedOption = option)
                                : null,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(62),
                              backgroundColor: selectedOption == option
                                  ? AppColors.accent.withValues(alpha: 0.12)
                                  : AppColors.surface,
                              side: BorderSide(
                                color: selectedOption == option
                                    ? AppColors.accent
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    if (currentMode == TrainingModeType.speed) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Combo x$combo',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (usesDrawingMode) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Strokes: $_drawStrokeCount · Points: $_drawPointCount',
                        style: const TextStyle(
                          color: AppColors.textDim,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isCorrect == null)
                FilledButton(
                  onPressed:
                      (usesDrawingMode
                          ? _drawPointCount < 24
                          : selectedOption == null && !usesInputMode)
                      ? null
                      : () {
                          _checkAnswer();
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: AppColors.accent,
                  ),
                  child: Text(
                    usesDrawingMode ? 'Submit Drawing' : 'Check Answer',
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (isCorrect! ? AppColors.success : AppColors.accent)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isCorrect! ? AppColors.success : AppColors.accent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect! ? Icons.check_circle : Icons.error_outline,
                        color: isCorrect!
                            ? AppColors.success
                            : AppColors.accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _feedbackText(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: usesDrawingMode ? 16 : 18,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          if (currentIndex == items.length - 1) {
                            setState(() => finished = true);
                            return;
                          }
                          setState(() {
                            currentIndex++;
                            _resetStepState();
                          });
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: isCorrect!
                              ? AppColors.success
                              : AppColors.accent,
                        ),
                        child: Text(
                          currentIndex == items.length - 1 ? 'Finish' : 'Next',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleLabel() {
    switch (currentMode) {
      case TrainingModeType.recall:
        if (isReview) return 'REGULAR REVIEW';
        return 'RECALL MODE';
      case TrainingModeType.speed:
        if (isReview) return 'SPEED REVIEW';
        return 'SPEED RECOGNITION';
      case TrainingModeType.errorBoss:
        return 'CHALLENGE REVIEW — BOSS FIGHT';
      case TrainingModeType.drawing:
        return 'DRAWING PRACTICE';
      default:
        if (widget.lessonId == 'playground') return 'PLAYGROUND';
        return isReview ? 'REVIEW' : lesson?.title ?? 'PRACTICE';
    }
  }

  String _getSubtitle() {
    switch (currentMode) {
      case TrainingModeType.recall:
        if (isReview) {
          return 'Includes words you\'ve already learned. Practice them to build long-term retention.';
        }
        return '';
      case TrainingModeType.speed:
        if (isReview) {
          return 'Quick-fire practice with learned words. Test your recall speed and accuracy.';
        }
        return '';
      case TrainingModeType.errorBoss:
        return 'Challenge Review — Focus on words you missed before. Practice will strengthen these weak areas and reduce them from your review queue.';
      case TrainingModeType.drawing:
        if (isReview) {
          return 'Includes learned characters. Draw them to practice recall strength.';
        }
        return '';
      default:
        if (widget.lessonId == 'playground') return 'Free exploration mode';
        return isReview ? '' : '';
    }
  }

  String _getAnswerTypeLabel() {
    switch (currentMode) {
      case TrainingModeType.recall:
        if (isReview) return 'Review item — Production';
        return 'Production — Type your answer';
      case TrainingModeType.speed:
        if (isReview) return 'Review item — Recognition';
        return 'Recognition — Select an option';
      case TrainingModeType.errorBoss:
        return 'Weak Item Practice';
      case TrainingModeType.drawing:
        if (isReview) return 'Review item — Drawing';
        return 'Drawing practice';
      default:
        if (widget.lessonId == 'playground') return 'Interactive Quiz';
        return isReview ? 'Review Item' : 'MCQ Recognition';
    }
  }

  String _promptLabel() {
    switch (currentMode) {
      case TrainingModeType.recall:
        return 'Type the answer (meaning/pinyin/hanzi) into the input field';
      case TrainingModeType.speed:
        return 'Select the correct meaning quickly for combo bonus points';
      case TrainingModeType.errorBoss:
        return 'Challenge Review — Focus on words you missed before';
      case TrainingModeType.drawing:
        return 'Write the character in the drawing area below';
      default:
        if (widget.lessonId == 'playground') return 'PLAYGROUND';
        return '';
    }
  }
}
