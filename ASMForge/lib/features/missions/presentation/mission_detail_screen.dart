import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/content_providers.dart';
import '../../../core/simulator/program_runner.dart';
import '../../../theme/app_colors.dart';
import '../../editor/presentation/asm_code_editor.dart';
import '../../editor/presentation/asm_syntax_controller.dart';
import '../../progress/application/progress_controller.dart';
import '../../simulator/application/lab_controller.dart';
import '../domain/mission.dart';

class MissionDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const MissionDetailScreen({super.key, required this.id});

  @override
  ConsumerState<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends ConsumerState<MissionDetailScreen> {
  AsmSyntaxController? _controller;
  int _hintsShown = 0;
  bool? _success;
  List<CheckOutcome> _outcomes = [];
  String? _runError;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(missionsProvider);
    final progress = ref.watch(progressControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mission')),
      body: missionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (missions) {
          final mission = missions.firstWhere((m) => m.id == widget.id);
          _controller ??= AsmSyntaxController(text: mission.starterCode);
          final done = progress.completedMissions.contains(mission.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('MISSION ${mission.number.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.violet, fontWeight: FontWeight.bold)),
              Text(mission.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(mission.narrative, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: AppColors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(mission.objective)),
                  ],
                ),
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
                    label: const Text('Vérifier la mission'),
                    onPressed: () => _check(mission.checks),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Ouvrir dans le laboratoire'),
                    onPressed: () {
                      ref.read(labControllerProvider.notifier).loadStarterCode(_controller!.text);
                      context.go('/lab');
                    },
                  ),
                  if (_hintsShown < mission.hints.length)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('Indice'),
                      onPressed: () => setState(() => _hintsShown++),
                    ),
                ],
              ),
              for (var i = 0; i < _hintsShown; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('💡 ${mission.hints[i]}', style: const TextStyle(color: AppColors.orange)),
                ),
              if (_runError != null) ...[
                const SizedBox(height: 14),
                _ResultBanner(success: false, message: _runError!),
              ] else if (_success != null) ...[
                const SizedBox(height: 14),
                _ResultBanner(
                  success: _success!,
                  message: _success!
                      ? 'Mission réussie : CORE-01 progresse.'
                      : _outcomes.where((o) => !o.passed).map((o) => o.description).join('\n'),
                ),
              ],
              if (done) ...[
                const SizedBox(height: 10),
                const Text('✔ Mission déjà validée.', style: TextStyle(color: AppColors.executionGreen)),
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
    final simpleChecks = checks.map((c) => c.toSimpleCheck()).toList();
    final outcomes = evaluateChecks(result.cpu!, simpleChecks);
    final allPassed = outcomes.every((o) => o.passed);
    setState(() {
      _runError = null;
      _success = allPassed;
      _outcomes = outcomes;
    });
    if (allPassed) {
      ref.read(progressControllerProvider.notifier).completeMission(widget.id);
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
