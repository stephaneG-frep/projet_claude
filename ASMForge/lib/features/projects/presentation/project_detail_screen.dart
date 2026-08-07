import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/content_providers.dart';
import '../../../core/simulator/program_runner.dart';
import '../../../theme/app_colors.dart';
import '../../editor/presentation/asm_code_editor.dart';
import '../../editor/presentation/asm_syntax_controller.dart';
import '../../missions/domain/mission.dart';
import '../../progress/application/progress_controller.dart';
import '../../simulator/application/lab_controller.dart';

/// Mini-projet (section 24) : objectif, explication, étapes, indices,
/// solution et explication de la solution.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ProjectDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  AsmSyntaxController? _controller;
  bool _showSolution = false;
  int _hintsShown = 0;
  bool? _success;
  String? _runError;
  List<CheckOutcome> _outcomes = [];

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final progress = ref.watch(progressControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mini-projet')),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (projects) {
          final project = projects.firstWhere((p) => p.id == widget.id);
          _controller ??= AsmSyntaxController(text: '; Écrivez votre solution ici\n');
          final done = progress.completedProjects.contains(project.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('PROJET ${project.number}', style: const TextStyle(color: AppColors.violet, fontWeight: FontWeight.bold)),
              Text(project.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(project.objective, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Text(project.explanation),
              const SizedBox(height: 14),
              Text('Étapes', style: Theme.of(context).textTheme.titleMedium),
              for (var i = 0; i < project.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text('${i + 1}. ${project.steps[i]}'),
                ),
              const SizedBox(height: 16),
              SizedBox(height: 220, child: AsmCodeEditor(controller: _controller!)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.play_circle),
                    label: const Text('Exécuter et vérifier'),
                    onPressed: () => _check(project.checks),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Ouvrir dans le laboratoire'),
                    onPressed: () {
                      ref.read(labControllerProvider.notifier).loadStarterCode(_controller!.text);
                      context.go('/lab');
                    },
                  ),
                  if (_hintsShown < project.hints.length)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('Indice'),
                      onPressed: () => setState(() => _hintsShown++),
                    ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(_showSolution ? 'Masquer la solution' : 'Voir la solution'),
                    onPressed: () => setState(() => _showSolution = !_showSolution),
                  ),
                ],
              ),
              for (var i = 0; i < _hintsShown; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('💡 ${project.hints[i]}', style: const TextStyle(color: AppColors.orange)),
                ),
              if (_runError != null) ...[
                const SizedBox(height: 14),
                _ResultBanner(success: false, message: _runError!),
              ] else if (_success != null) ...[
                const SizedBox(height: 14),
                _ResultBanner(
                  success: _success!,
                  message: _success!
                      ? 'Bravo, le projet est validé !'
                      : _outcomes.where((o) => !o.passed).map((o) => o.description).join('\n'),
                ),
              ],
              if (done) ...[
                const SizedBox(height: 10),
                const Text('✔ Projet déjà validé.', style: TextStyle(color: AppColors.executionGreen)),
              ],
              if (_showSolution) ...[
                const SizedBox(height: 20),
                Text('Solution', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(10)),
                  child: Text(project.solutionCode, style: const TextStyle(fontFamily: 'monospace')),
                ),
                const SizedBox(height: 10),
                Text(project.solutionExplanation),
              ],
            ],
          );
        },
      ),
    );
  }

  void _check(List<MissionCheck> checks) {
    final result = runProgramToCompletion(_controller!.text);
    if (!result.success) {
      setState(() {
        _runError = result.error;
        _success = null;
      });
      return;
    }
    final outcomes = evaluateChecks(result.cpu!, checks.map((c) => c.toSimpleCheck()).toList());
    final allPassed = outcomes.every((o) => o.passed);
    setState(() {
      _runError = null;
      _success = allPassed;
      _outcomes = outcomes;
    });
    if (allPassed) {
      ref.read(progressControllerProvider.notifier).completeProject(widget.id);
    }
  }
}

class _ResultBanner extends StatelessWidget {
  final bool success;
  final String message;
  const _ResultBanner({required this.success, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.executionGreen : AppColors.errorRed;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(message, style: TextStyle(color: color)),
    );
  }
}
