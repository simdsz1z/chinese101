import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/course_data.dart';
import '../gamification/gamification_service.dart';
import '../models/training_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import 'daily_challenge_screen.dart';
import 'practice_screen.dart';
import 'session_hub_screen.dart';
import 'training_modes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationService>(
      builder: (context, service, _) {
        final profile = service.profile;
        final nextLesson = service.nextLesson;
        final reviewPool = service.reviewPool;

        return AppShell(
          title: 'Learn, Review, Earn',
          subtitle: 'Your personalized learning dashboard.',
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _statCard(
                    'Streak',
                    '${profile.streak} days',
                    Icons.local_fire_department,
                    AppColors.accent,
                  ),
                  _statCard(
                    'Level',
                    '${profile.level}',
                    Icons.star,
                    Colors.blueAccent,
                  ),
                  _statCard(
                    'Coins',
                    '${profile.coins}',
                    Icons.monetization_on,
                    AppColors.gold,
                  ),
                  _statCard(
                    'Lessons Completed',
                    '${profile.lessonsCompleted.length}',
                    Icons.emoji_events,
                    Colors.greenAccent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _heroCard(
                context,
                service,
                nextLesson?.id ?? 'level-1',
                nextLesson?.title ?? 'Greetings',
                reviewPool.length,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRAINING METHODS',
                            style: TextStyle(
                              color: AppColors.textDim,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Practice with multiple choice questions and timed challenges to build speed and accuracy.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TrainingModesScreen(),
                          ),
                        );
                      },
                      child: const Text('Open Modes'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      title: 'XP to next level',
                      value: '${service.xpToNextLevel}',
                      subtitle:
                          'Complete lessons in order to build your vocabulary progressively.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      title: 'Review sessions',
                      value: '${profile.reviewSessionsCompleted}',
                      subtitle:
                          'Review sessions help you retain what you learn. Earn bonus points for consistent practice.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY CHALLENGE',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${service.challenge.content.character} · ${service.challenge.content.pinyin}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.challenge.content.question,
                      style: const TextStyle(color: AppColors.textDim),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DailyChallengeScreen(
                              challengeItem: dailyChallenge.content,
                              isCompletedToday:
                                  Provider.of<GamificationService>(
                                    context,
                                    listen: false,
                                  ).isCompletedToday,
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text('Complete Daily Challenge'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _secondaryActionCard(
                context,
                title: 'Playground',
                subtitle: 'Explore all games and practice modes freely.',
                icon: Icons.explore_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SessionHubScreen(scope: SessionScope.playground),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _secondaryActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Explore'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textDim)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(
    BuildContext context,
    GamificationService service,
    String lessonId,
    String title,
    int reviewCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MAIN LOOP',
            style: TextStyle(
              color: AppColors.textDim,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Learn, Review, Earn, Repeat',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete lessons to unlock new vocabulary, then practice in review mode to strengthen what you learn.',
            style: TextStyle(color: AppColors.textDim),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(
                          lessonId: lessonId,
                          trainingMode: TrainingModeType.mcq,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text('Next Level: $title'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PracticeScreen(
                          lessonId: 'review',
                          trainingMode: TrainingModeType.mcq,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                    backgroundColor: AppColors.background,
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    reviewCount > 0
                        ? 'Review Mode / $reviewCount cards'
                        : 'Complete lessons first',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: AppColors.textDim)),
        ],
      ),
    );
  }
}
