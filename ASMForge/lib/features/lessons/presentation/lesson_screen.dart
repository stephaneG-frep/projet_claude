import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/content_providers.dart';
import '../../../theme/app_colors.dart';
import '../../exercises/presentation/exercise_card.dart';
import '../../progress/application/progress_controller.dart';
import '../../progress/domain/badge_def.dart';
import '../domain/module.dart';

class LessonScreen extends ConsumerWidget {
  final String moduleId;
  final String lessonId;
  const LessonScreen({super.key, required this.moduleId, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesProvider);
    final exercisesAsync = ref.watch(exercisesProvider);
    final progress = ref.watch(progressControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leçon')),
      body: modulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (modules) {
          final module = modules.firstWhere((m) => m.id == moduleId);
          final lesson = module.lessons.firstWhere((l) => l.id == lessonId);
          final isDone = progress.completedLessons.contains(lesson.id);
          final lessonExercises = exercisesAsync.maybeWhen(
            data: (list) => list.where((e) => e.lessonId == lesson.id).toList(),
            orElse: () => const [],
          );
          final nextLesson = _nextLesson(module, lesson.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Module ${module.number} — ${module.title}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(lesson.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              for (final block in lesson.blocks) _ContentBlockView(block: block),
              const SizedBox(height: 20),
              if (!isDone)
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Marquer comme terminé'),
                  onPressed: () => _completeLesson(context, ref, module, lesson.id),
                )
              else
                const _DoneBanner(),
              if (lessonExercises.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Exercices', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                for (final exercise in lessonExercises) ExerciseCard(exercise: exercise),
              ],
              const SizedBox(height: 24),
              if (nextLesson != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text('Leçon suivante : ${nextLesson.title}'),
                  onPressed: () => context.pushReplacement('/learn/lesson/$moduleId/${nextLesson.id}'),
                ),
            ],
          );
        },
      ),
    );
  }

  Lesson? _nextLesson(LearningModule module, String currentId) {
    final index = module.lessons.indexWhere((l) => l.id == currentId);
    if (index == -1 || index == module.lessons.length - 1) return null;
    return module.lessons[index + 1];
  }

  void _completeLesson(BuildContext context, WidgetRef ref, LearningModule module, String lessonId) {
    final notifier = ref.read(progressControllerProvider.notifier);
    final newlyUnlocked = notifier.completeLesson(lessonId);

    final updatedProgress = ref.read(progressControllerProvider);
    final allDone = module.lessons.every((l) => updatedProgress.completedLessons.contains(l.id));
    if (allDone) notifier.markModuleCompleted(module.id);

    if (newlyUnlocked.isNotEmpty) {
      _showBadgeSnackbar(context, newlyUnlocked);
    }
  }

  void _showBadgeSnackbar(BuildContext context, List<BadgeDef> badges) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Badge débloqué : ${badges.map((b) => '${b.emoji} ${b.name}').join(', ')}'),
        backgroundColor: AppColors.surfaceSecondary,
      ),
    );
  }
}

class _DoneBanner extends StatelessWidget {
  const _DoneBanner();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.executionGreen),
        SizedBox(width: 8),
        Text('Leçon terminée', style: TextStyle(color: AppColors.executionGreen)),
      ],
    );
  }
}

class _ContentBlockView extends StatelessWidget {
  final ContentBlock block;
  const _ContentBlockView({required this.block});

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case ContentBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(block.text, style: Theme.of(context).textTheme.bodyLarge),
        );
      case ContentBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(color: AppColors.cyan)),
              Expanded(child: Text(block.text)),
            ],
          ),
        );
      case ContentBlockType.code:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(block.text, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
        );
      case ContentBlockType.tip:
        return _Callout(
          text: block.text,
          color: AppColors.cyan,
          icon: Icons.lightbulb_outline,
        );
      case ContentBlockType.warning:
        return _Callout(
          text: block.text,
          color: AppColors.orange,
          icon: Icons.warning_amber_outlined,
        );
    }
  }
}

class _Callout extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _Callout({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
