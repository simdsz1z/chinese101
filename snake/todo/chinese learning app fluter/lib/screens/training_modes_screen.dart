import 'package:flutter/material.dart';

import '../models/training_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import 'session_hub_screen.dart';

class TrainingModesScreen extends StatelessWidget {
  const TrainingModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableTitleColor = AppColors.success.withValues(alpha: 0.9);
    final subtleGrayColor = AppColors.textDim.withValues(alpha: 0.3);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppShell(
        title: 'Training Modes',
        subtitle: 'Build recognition, recall speed and mastery skills.',
        child: Column(
          children: [
            // Available Now Section
            _buildSectionHeader(
              context,
              icon: Icons.check_circle_outline,
              title: 'Available now',
              color: availableTitleColor,
              description:
                  'Fully implemented training modes you can use today.',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: trainingModes.where((m) => m.implemented).length,
                  itemBuilder: (context, index) {
                    final implemented = trainingModes
                        .where((m) => m.implemented)
                        .toList();
                    final mode = implemented[index];
                    return _buildModeCard(context, mode);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Coming Soon Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Opacity(
                opacity: 0.85,
                child: _buildSectionHeader(
                  context,
                  icon: Icons.pending_actions_outlined,
                  title: 'Coming soon',
                  color: availableTitleColor,
                  description: 'Training modes under development - stay tuned.',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: subtleGrayColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'These training modes are planned for future releases.',
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...trainingModes.where((m) => !m.implemented).map((mode) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(mode.icon, color: mode.color, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mode.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDim,
                                  ),
                                ),
                                Text(
                                  mode.subtitle.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: subtleGrayColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required String description,
  }) {
    final isAvailable = title == 'Available now';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color.withValues(alpha: isAvailable ? 0.9 : 0.5),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDim,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, TrainingMode mode) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionHubScreen(
            scope: mode.type == TrainingModeType.errorBoss
                ? SessionScope.review
                : SessionScope.playground,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: mode.color.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(mode.icon, color: mode.color, size: 34),
            const SizedBox(height: 12),
            Text(
              mode.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(
              mode.subtitle.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mode.description,
              style: const TextStyle(color: AppColors.textDim),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ready',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
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
