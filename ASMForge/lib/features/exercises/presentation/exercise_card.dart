import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/simulator/program_runner.dart';
import '../../../theme/app_colors.dart';
import '../../editor/presentation/asm_code_editor.dart';
import '../../editor/presentation/asm_syntax_controller.dart';
import '../../progress/application/progress_controller.dart';
import '../domain/exercise.dart';

/// Affiche un exercice pédagogique (section 21) quel que soit son type,
/// et gère la correction détaillée (section 22) : jamais un simple
/// « FAUX », toujours une raison, le concept concerné, la solution et la
/// possibilité de réessayer.
class ExerciseCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  const ExerciseCard({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  bool? _isCorrect;
  int? _selectedIndex;
  final _textController = TextEditingController();
  List<String>? _reorderState;
  late AsmSyntaxController _codeController;
  String? _runFeedback;

  @override
  void initState() {
    super.initState();
    final data = widget.exercise.data;
    if (widget.exercise.type == ExerciseType.reorder) {
      _reorderState = (data['lines'] as List).cast<String>().toList()..shuffle();
    }
    if (widget.exercise.type == ExerciseType.writeProgram) {
      _codeController = AsmSyntaxController(text: data['starterCode'] as String? ?? '');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit(bool correct, {String? feedback}) {
    setState(() {
      _isCorrect = correct;
      _runFeedback = feedback;
    });
    ref.read(progressControllerProvider.notifier).completeExercise(widget.exercise.id, correct: correct);
  }

  void _retry() {
    setState(() {
      _isCorrect = null;
      _selectedIndex = null;
      _runFeedback = null;
      _textController.clear();
      final data = widget.exercise.data;
      if (widget.exercise.type == ExerciseType.reorder) {
        _reorderState = (data['lines'] as List).cast<String>().toList()..shuffle();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.prompt, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildBody(exercise),
            if (_isCorrect != null) ...[
              const SizedBox(height: 12),
              _FeedbackBanner(
                correct: _isCorrect!,
                concept: exercise.concept,
                explanation: (exercise.data['explanation'] as String?) ?? '',
                extra: _runFeedback,
                onRetry: _retry,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Exercise exercise) {
    switch (exercise.type) {
      case ExerciseType.qcm:
        return _buildQcm(exercise);
      case ExerciseType.fillBlank:
        return _buildFillBlank(exercise);
      case ExerciseType.predictResult:
        return _buildPredictResult(exercise);
      case ExerciseType.findError:
        return _buildFindError(exercise);
      case ExerciseType.reorder:
        return _buildReorder(exercise);
      case ExerciseType.writeProgram:
        return _buildWriteProgram(exercise);
    }
  }

  Widget _buildQcm(Exercise exercise) {
    final options = (exercise.data['options'] as List).cast<String>();
    final correctIndex = exercise.data['correctIndex'] as int;
    return RadioGroup<int>(
      groupValue: _selectedIndex,
      onChanged: (v) => setState(() => _selectedIndex = v),
      child: Column(
        children: [
          for (var i = 0; i < options.length; i++)
            RadioListTile<int>(
              value: i,
              enabled: _isCorrect == null,
              title: Text(options[i]),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _isCorrect != null || _selectedIndex == null
                ? null
                : () => _submit(_selectedIndex == correctIndex),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget _buildFillBlank(Exercise exercise) {
    final template = exercise.data['template'] as String;
    final correctAnswer = (exercise.data['correctAnswer'] as String).trim().toUpperCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CodeBlock(template),
        const SizedBox(height: 10),
        TextField(
          controller: _textController,
          enabled: _isCorrect == null,
          decoration: const InputDecoration(labelText: 'Complétez la ligne manquante (___)'),
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _isCorrect != null
              ? null
              : () => _submit(_textController.text.trim().toUpperCase() == correctAnswer),
          child: const Text('Valider'),
        ),
      ],
    );
  }

  Widget _buildPredictResult(Exercise exercise) {
    final code = exercise.data['code'] as String;
    final question = exercise.data['question'] as String;
    final correctAnswer = (exercise.data['correctAnswer'] as String).trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CodeBlock(code),
        const SizedBox(height: 10),
        Text(question),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          enabled: _isCorrect == null,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(labelText: 'Votre réponse'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _isCorrect != null
              ? null
              : () => _submit(_textController.text.trim() == correctAnswer),
          child: const Text('Valider'),
        ),
      ],
    );
  }

  Widget _buildFindError(Exercise exercise) {
    final code = exercise.data['code'] as String;
    final options = (exercise.data['options'] as List).cast<String>();
    final correctIndex = exercise.data['correctIndex'] as int;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CodeBlock(code),
        const SizedBox(height: 10),
        RadioGroup<int>(
          groupValue: _selectedIndex,
          onChanged: (v) => setState(() => _selectedIndex = v),
          child: Column(
            children: [
              for (var i = 0; i < options.length; i++)
                RadioListTile<int>(
                  value: i,
                  enabled: _isCorrect == null,
                  title: Text(options[i]),
                ),
            ],
          ),
        ),
        FilledButton(
          onPressed: _isCorrect != null || _selectedIndex == null
              ? null
              : () => _submit(_selectedIndex == correctIndex),
          child: const Text('Valider'),
        ),
      ],
    );
  }

  Widget _buildReorder(Exercise exercise) {
    final correctOrder = (exercise.data['lines'] as List).cast<String>();
    final items = _reorderState!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorderItem: (oldIndex, newIndex) {
            if (_isCorrect != null) return;
            setState(() {
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          },
          children: [
            for (final line in items)
              ListTile(
                key: ValueKey(line),
                tileColor: AppColors.surfaceSecondary,
                title: Text(line, style: const TextStyle(fontFamily: 'monospace')),
                trailing: const Icon(Icons.drag_handle),
              ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _isCorrect != null
              ? null
              : () => _submit(_listEquals(items, correctOrder)),
          child: const Text('Valider l\'ordre'),
        ),
      ],
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Widget _buildWriteProgram(Exercise exercise) {
    final instructions = exercise.data['instructions'] as String;
    final checksData = (exercise.data['checks'] as List).cast<Map<String, dynamic>>();
    final checks = checksData
        .map((c) => SimpleCheck(
              register: c['register'] as String?,
              memoryAddress: c['memoryAddress'] as int?,
              expectedValue: c['expectedValue'] as int,
              description: c['description'] as String,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(instructions, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: AsmCodeEditor(controller: _codeController),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _isCorrect != null
              ? null
              : () {
                  final result = runProgramToCompletion(_codeController.text);
                  if (!result.success) {
                    _submit(false, feedback: result.error);
                    return;
                  }
                  final outcomes = evaluateChecks(result.cpu!, checks);
                  final allPassed = outcomes.every((o) => o.passed);
                  final failedDescriptions = outcomes
                      .where((o) => !o.passed)
                      .map((o) => '${o.description} (obtenu : ${o.actualValue}, attendu : ${o.expectedValue})')
                      .join('\n');
                  _submit(allPassed, feedback: allPassed ? null : failedDescriptions);
                },
          child: const Text('Exécuter et vérifier'),
        ),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String text;
  const _CodeBlock(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontFamily: 'monospace')),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final bool correct;
  final String concept;
  final String explanation;
  final String? extra;
  final VoidCallback onRetry;

  const _FeedbackBanner({
    required this.correct,
    required this.concept,
    required this.explanation,
    required this.extra,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.executionGreen : AppColors.errorRed;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle : Icons.error, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                correct ? 'Bonne réponse !' : 'Ce n\'est pas encore ça.',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (concept.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Concept concerné : $concept', style: const TextStyle(color: AppColors.textSecondary)),
          ],
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(explanation),
          ],
          if (extra != null && extra!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(extra!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ],
          if (!correct) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}
