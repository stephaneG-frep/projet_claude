import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../cpu_visualizer/presentation/cpu_diagram.dart';
import '../../cpu_visualizer/presentation/flag_panel.dart';
import '../../cpu_visualizer/presentation/register_panel.dart';
import '../../editor/presentation/asm_code_editor.dart';
import '../../editor/presentation/asm_syntax_controller.dart';
import '../../memory/presentation/memory_viewer.dart';
import '../../settings/application/settings_controller.dart';
import '../../stack/presentation/stack_viewer.dart';
import '../application/lab_controller.dart';
import '../application/lab_state.dart';

const _defaultProgram = '''; Bienvenue dans le Laboratoire ASMForge
MOV RAX, 5
MOV RBX, 3
ADD RAX, RBX
''';

class LabScreen extends ConsumerStatefulWidget {
  const LabScreen({super.key});

  @override
  ConsumerState<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends ConsumerState<LabScreen> {
  late final AsmSyntaxController _controller;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(labControllerProvider).source;
    _controller = AsmSyntaxController(
      text: initial.isEmpty ? _defaultProgram : initial,
    );
    if (initial.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(labControllerProvider.notifier).updateSource(_controller.text);
      });
    }
    _controller.addListener(() {
      ref.read(labControllerProvider.notifier).updateSource(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labState = ref.watch(labControllerProvider);
    final settings = ref.watch(settingsControllerProvider);

    ref.listen(labControllerProvider.select((s) => s.source), (prev, next) {
      if (next != _controller.text) {
        _controller.value = _controller.value.copyWith(text: next);
      }
    });

    final panels = _buildPanels(labState, settings.animationsEnabled);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratoire'),
        actions: [
          IconButton(
            tooltip: 'Nouveau programme',
            icon: const Icon(Icons.description_outlined),
            onPressed: () {
              ref.read(labControllerProvider.notifier).loadStarterCode(_defaultProgram);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final panelColumn = SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(children: panels),
          );
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildEditorColumn(labState, useFixedHeights: false)),
                SizedBox(width: 380, child: panelColumn),
              ],
            );
          }
          // Mode mobile/tablette étroite : tout est empilé dans un seul
          // défilement, avec des hauteurs fixes plutôt que des Expanded
          // contraints par une boîte de taille arbitraire. Cela reste
          // correct quelle que soit l'orientation (portrait ou paysage),
          // y compris sur un écran bas où l'espace vertical disponible
          // est réduit : le contenu défile au lieu de déborder.
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildEditorColumn(labState, useFixedHeights: true),
                panelColumn,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditorColumn(LabState labState, {required bool useFixedHeights}) {
    final editor = AsmCodeEditor(
      controller: _controller,
      highlightedLine: labState.currentLine,
      breakpoints: labState.breakpoints,
      onToggleBreakpoint: (line) =>
          ref.read(labControllerProvider.notifier).toggleBreakpoint(line),
    );
    final console = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: labState.consoleLines.isEmpty
          ? const Text(
              'Appuyez sur Run ou Step pour exécuter le programme.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          : ListView.builder(
              shrinkWrap: useFixedHeights,
              physics: useFixedHeights ? const NeverScrollableScrollPhysics() : null,
              itemCount: labState.consoleLines.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  labState.consoleLines[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: useFixedHeights ? MainAxisSize.min : MainAxisSize.max,
        children: [
          _ControlBar(),
          const SizedBox(height: 10),
          if (labState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.errorRed),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      labState.errorMessage!,
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          useFixedHeights ? SizedBox(height: 300, child: editor) : Expanded(flex: 3, child: editor),
          const SizedBox(height: 10),
          Text('Console d\'exécution', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          useFixedHeights ? SizedBox(height: 160, child: console) : Expanded(flex: 2, child: console),
        ],
      ),
    );
  }

  List<Widget> _buildPanels(LabState labState, bool animationsEnabled) {
    return [
      CpuDiagram(
        pulse: labState.stepPulse,
        animationsEnabled: animationsEnabled,
        stageLabel: labState.halted && labState.hasStarted
            ? 'Exécution terminée.'
            : (labState.currentLine != null ? 'Ligne ${labState.currentLine}' : ''),
      ),
      const SizedBox(height: 12),
      RegisterPanel(registers: labState.registers, changed: labState.lastRegisterChanges),
      const SizedBox(height: 12),
      FlagPanel(flags: labState.flags),
      const SizedBox(height: 12),
      StackViewer(entries: labState.stack),
      const SizedBox(height: 12),
      MemoryViewer(
        memory: ref.read(labControllerProvider.notifier).memory,
        focusAddress: labState.lastMemoryWrites.isNotEmpty
            ? labState.lastMemoryWrites.first
            : (labState.registers['RSP'] ?? 0),
        recentlyWritten: labState.lastMemoryWrites,
      ),
    ];
  }
}

class _ControlBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labState = ref.watch(labControllerProvider);
    final notifier = ref.read(labControllerProvider.notifier);
    final canPressRun =
        !labState.isRunning && (!labState.halted || !labState.hasStarted);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: canPressRun ? notifier.run : null,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Run'),
        ),
        OutlinedButton.icon(
          onPressed: canPressRun ? notifier.step : null,
          icon: const Icon(Icons.skip_next),
          label: const Text('Step'),
        ),
        OutlinedButton.icon(
          onPressed: labState.isRunning ? notifier.pause : null,
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
        ),
        OutlinedButton.icon(
          onPressed: notifier.reset,
          icon: const Icon(Icons.replay),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
