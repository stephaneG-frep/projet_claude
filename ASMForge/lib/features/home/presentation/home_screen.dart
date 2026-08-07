import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/content_providers.dart';
import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';
import '../../progress/domain/badge_def.dart';

/// Dashboard de progression (section 9) : le processeur s'illumine
/// progressivement selon l'avancement de l'utilisateur.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressControllerProvider);
    final modulesAsync = ref.watch(modulesProvider);
    final missionsAsync = ref.watch(missionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ASMForge')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProcessorGlow(progress: progress.levelProgress),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(label: 'Niveau', value: '${progress.level}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(label: 'XP', value: '${progress.xp}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Progression',
                  value: '${(progress.levelProgress * 100).round()}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Leçons terminées',
                  value: '${progress.completedLessons.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Exercices réussis',
                  value: '${progress.completedExercises.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Projets terminés',
                  value: '${progress.completedProjects.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          modulesAsync.when(
            data: (modules) {
              final nextModule = modules.firstWhere(
                (m) => m.lessons.any((l) => !progress.completedLessons.contains(l.id)),
                orElse: () => modules.first,
              );
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book, color: AppColors.cyan),
                  title: Text('Cours actuel : ${nextModule.title}'),
                  subtitle: const Text('Continuer mon apprentissage'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => context.go('/learn'),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, st) => Text('Contenu indisponible : $e'),
          ),
          const SizedBox(height: 10),
          missionsAsync.when(
            data: (missions) {
              final nextMission = missions.firstWhere(
                (m) => !progress.completedMissions.contains(m.id),
                orElse: () => missions.last,
              );
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.flag, color: AppColors.violet),
                  title: Text('Mission ${nextMission.number.toString().padLeft(2, '0')} : ${nextMission.title}'),
                  subtitle: const Text('Restaurer CORE-01'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => context.go('/missions'),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          if (progress.unlockedBadges.isNotEmpty) ...[
            Text('Badges débloqués', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final badge in kAllBadges)
                  if (progress.unlockedBadges.contains(badge.id))
                    Chip(
                      avatar: Text(badge.emoji),
                      label: Text(badge.name),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProcessorGlow extends StatelessWidget {
  final double progress;
  const _ProcessorGlow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final glow = 0.15 + progress.clamp(0, 1) * 0.6;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          colors: [
            AppColors.cyan.withValues(alpha: glow),
            AppColors.background,
          ],
        ),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Icon(Icons.memory, size: 72, color: AppColors.cyan.withValues(alpha: 0.6 + glow * 0.4)),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
