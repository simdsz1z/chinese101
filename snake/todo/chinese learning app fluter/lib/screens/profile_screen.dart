import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../gamification/gamification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import 'achievements_screen.dart';
import 'session_hub_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationService>(
      builder: (context, service, _) {
        final profile = service.profile;
        return AppShell(
          title: 'Profile',
          subtitle: 'Your identity, progress, and rewards.',
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, Color(0xFF771616)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.person, size: 42, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Level ${profile.level}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _profileCard(
                'Current XP',
                '${profile.xp}',
                Icons.bolt,
                AppColors.gold,
              ),
              const SizedBox(height: 12),
              _profileCard(
                'Coins',
                '${profile.coins}',
                Icons.monetization_on,
                AppColors.gold,
              ),
              const SizedBox(height: 12),
              _profileCard(
                'Lessons Completed',
                '${profile.lessonsCompleted.length}',
                Icons.school,
                Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              _profileCard(
                'Characters Learned',
                '${profile.totalCharactersLearned}',
                Icons.translate,
                Colors.greenAccent,
              ),
              const SizedBox(height: 12),
              _profileCard(
                'Review Sessions',
                '${profile.reviewSessionsCompleted}',
                Icons.rotate_left,
                AppColors.accent,
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
                      'ACHIEVEMENTS',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _achievementRow(
                      title: 'Arena Rankings',
                      description: 'View leaderboard and tier status.',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        );
                      },
                      icon: Icons.emoji_events_outlined,
                    ),
                    const SizedBox(height: 12),
                    _achievementRow(
                      title: 'Playground',
                      description: 'Explore all games and practice modes.',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SessionHubScreen(
                              scope: SessionScope.playground,
                            ),
                          ),
                        );
                      },
                      icon: Icons.explore_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textDim),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _achievementRow({
    required String title,
    required String description,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textDim),
        ],
      ),
    );
  }
}
