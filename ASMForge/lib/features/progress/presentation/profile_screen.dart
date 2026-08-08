import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../application/progress_controller.dart';
import '../domain/badge_def.dart';

/// Profil (section 7) : progression, statistiques (section 35) et accès
/// aux paramètres, à propos et au glossaire.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final totalExercises = progress.exerciseScores.length;
    final successRate = totalExercises == 0
        ? 0
        : (progress.exerciseScores.values.where((v) => v > 0).length / totalExercises * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                        child: Text('${progress.level}', style: const TextStyle(fontSize: 20, color: AppColors.cyan)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Niveau ${progress.level}', style: Theme.of(context).textTheme.titleLarge),
                            Text('${progress.xp} XP au total', style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: progress.levelProgress, minHeight: 8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Statistiques', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 92,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            children: [
              _StatCard(label: 'Temps d\'apprentissage', value: _formatDuration(progress.totalLearningSeconds)),
              _StatCard(label: 'Cours terminés', value: '${progress.completedModules.length}'),
              _StatCard(label: 'Exercices réussis', value: '${progress.completedExercises.length}'),
              _StatCard(label: 'Taux de réussite', value: '$successRate%'),
              _StatCard(label: 'Missions terminées', value: '${progress.completedMissions.length}'),
              _StatCard(label: 'Projets terminés', value: '${progress.completedProjects.length}'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Badges', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final badge in kAllBadges)
                Opacity(
                  opacity: progress.unlockedBadges.contains(badge.id) ? 1 : 0.35,
                  child: Tooltip(
                    message: badge.description,
                    child: Chip(avatar: Text(badge.emoji), label: Text(badge.name)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Glossaire'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/glossary'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Paramètres'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/settings'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('À propos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/about'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
