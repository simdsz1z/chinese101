import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/course_data.dart';
import '../gamification/gamification_service.dart';
import '../models/study_content.dart';
import '../models/training_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import 'practice_screen.dart';

enum SessionScope { review, playground }

class SessionHubScreen extends StatefulWidget {
  final SessionScope scope;

  const SessionHubScreen({super.key, required this.scope});

  @override
  State<SessionHubScreen> createState() => _SessionHubScreenState();
}

class _SessionHubScreenState extends State<SessionHubScreen> {
  TrainingModeType selectedMode = TrainingModeType.mcq;
  int selectedLevel = 0;
  String selectedCategory = 'all';
  String selectedTag = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationService>(
      builder: (context, service, _) {
        final learnedIds = service.progress.map((item) => item.itemId).toSet();
        final List<StudyCollection> filteredCollections = studyCollections
            .where((collection) {
              final allowedByScope =
                  widget.scope == SessionScope.playground ||
                  collection.characterIds.any(learnedIds.contains);
              final allowedByLevel =
                  selectedLevel == 0 || collection.level == selectedLevel;
              final allowedByCategory =
                  selectedCategory == 'all' ||
                  collection.category == selectedCategory;
              final allowedByTag =
                  selectedTag == 'all' || collection.tags.contains(selectedTag);
              final allowedByMode = collection.recommendedModes.contains(
                selectedMode,
              );
              return allowedByScope &&
                  allowedByLevel &&
                  allowedByCategory &&
                  allowedByTag &&
                  allowedByMode;
            })
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: AppShell(
            title: widget.scope == SessionScope.review
                ? 'Review'
                : 'Playground',
            subtitle: widget.scope == SessionScope.review
                ? 'Regular Review includes words you\'ve already learned. Use this to build long-term retention.'
                : 'Challenge Review focuses on words you\'ve missed in previous attempts. Practice them to master.',
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _filterSection(),
                const SizedBox(height: 20),
                ...filteredCollections.map(
                  (collection) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _collectionCard(
                      context,
                      service,
                      collection,
                      learnedIds,
                    ),
                  ),
                ),
                if (filteredCollections.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'No content matches your current filters yet. Try another mode, level, or category.',
                      style: TextStyle(color: AppColors.textDim),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterSection() {
    final List<String> categories = [
      'all',
      ...{...studyCollections.map((item) => item.category)},
    ];
    final List<String> tags = [
      'all',
      ...{...studyCollections.expand((item) => item.tags)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FILTERS',
            style: TextStyle(
              color: AppColors.textDim,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<TrainingModeType>(
            initialValue: selectedMode,
            decoration: const InputDecoration(labelText: 'Learning mode'),
            items: trainingModes
                .where((mode) => mode.implemented)
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode.type,
                    child: Text(mode.title),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => selectedMode = value ?? TrainingModeType.mcq),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: selectedLevel,
            decoration: const InputDecoration(labelText: 'Level'),
            items: [
              const DropdownMenuItem(value: 0, child: Text('All levels')),
              ...List.generate(
                5,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('Level ${index + 1}'),
                ),
              ),
            ],
            onChanged: (value) => setState(() => selectedLevel = value ?? 0),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: categories
                .map<DropdownMenuItem<String>>(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => selectedCategory = value ?? 'all'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedTag,
            decoration: const InputDecoration(labelText: 'Focus tag'),
            items: tags
                .map<DropdownMenuItem<String>>(
                  (tag) =>
                      DropdownMenuItem<String>(value: tag, child: Text(tag)),
                )
                .toList(),
            onChanged: (value) => setState(() => selectedTag = value ?? 'all'),
          ),
        ],
      ),
    );
  }

  Widget _collectionCard(
    BuildContext context,
    GamificationService service,
    StudyCollection collection,
    Set<String> learnedIds,
  ) {
    final coverage = collection.characterIds.where(learnedIds.contains).length;
    final total = collection.characterIds.length;
    final canPractice = widget.scope == SessionScope.playground || coverage > 0;
    final lessonId = widget.scope == SessionScope.playground
        ? 'playground'
        : 'review';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${collection.level} · ${collection.category}',
                      style: const TextStyle(color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
              Text(
                '$coverage/$total learned',
                style: const TextStyle(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: collection.tags
                .map<Widget>(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ...collection.sentences
              .take(2)
              .map(
                (sentence) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${sentence.hanzi}  ·  ${sentence.translation}',
                    style: const TextStyle(color: AppColors.textDim),
                  ),
                ),
              ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: canPractice
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(
                          lessonId: lessonId,
                          trainingMode: selectedMode,
                          levelFilter: collection.level,
                          categoryFilter: collection.category,
                          tagFilter: selectedTag == 'all' ? null : selectedTag,
                          includeAllContent:
                              widget.scope == SessionScope.playground,
                        ),
                      ),
                    );
                  }
                : null,
            child: Text(
              widget.scope == SessionScope.review
                  ? 'Start review session'
                  : 'Open in playground',
            ),
          ),
        ],
      ),
    );
  }
}
