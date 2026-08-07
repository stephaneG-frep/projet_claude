import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/simulator/cpu_simulator.dart';
import '../../../core/simulator/memory_manager.dart';
import '../../../core/simulator/opcode.dart';
import '../../../core/simulator/simulator_exceptions.dart';
import '../../progress/application/progress_controller.dart';
import 'lab_state.dart';

const _arithmeticOpcodes = {
  Opcode.add,
  Opcode.sub,
  Opcode.inc,
  Opcode.dec,
  Opcode.mul,
  Opcode.div,
};

/// Pilote le simulateur pour l'écran Laboratoire : Run / Step / Pause /
/// Reset (sections 11, 12, 16). Le moteur [CpuSimulator] reste la seule
/// source de vérité de l'exécution ; ce contrôleur ne fait qu'orchestrer
/// et traduire son état en [LabState] observable par l'UI.
class LabController extends Notifier<LabState> {
  final CpuSimulator _cpu = CpuSimulator();
  Timer? _runTimer;
  String _loadedSource = '';

  /// Exposé en lecture pour le Memory Viewer (section 18) : la mémoire
  /// simulée elle-même reste mutable et gérée par [CpuSimulator].
  MemoryManager get memory => _cpu.memory;

  @override
  LabState build() {
    ref.onDispose(() => _runTimer?.cancel());
    return const LabState();
  }

  void updateSource(String source) {
    state = state.copyWith(source: source);
  }

  bool _ensureLoaded() {
    if (_loadedSource == state.source && state.program.isNotEmpty) {
      return true;
    }
    try {
      _cpu.loadProgram(state.source);
      _loadedSource = state.source;
      state = state.copyWith(
        program: _cpu.program,
        breakpoints: _cpu.breakpoints.lines,
        clearError: true,
        hasStarted: false,
        halted: _cpu.halted,
        currentLine: _cpu.currentInstruction?.sourceLine,
        registers: _cpu.registers.snapshot(),
        flags: _cpu.flags.snapshot(),
        stack: _cpu.stack.entries(),
        consoleLines: const [],
      );
      return true;
    } on AsmException catch (e) {
      state = state.copyWith(errorMessage: e.message, halted: true);
      return false;
    }
  }

  void _syncFromCpu({String? consoleLine}) {
    state = state.copyWith(
      program: _cpu.program,
      registers: _cpu.registers.snapshot(),
      flags: _cpu.flags.snapshot(),
      stack: _cpu.stack.entries(),
      currentLine: _cpu.currentInstruction?.sourceLine,
      halted: _cpu.halted,
      hasStarted: true,
      consoleLines: consoleLine == null
          ? state.consoleLines
          : [...state.consoleLines, consoleLine],
      clearError: true,
    );
  }

  void toggleBreakpoint(int line) {
    _cpu.breakpoints.toggle(line);
    state = state.copyWith(breakpoints: Set.from(_cpu.breakpoints.lines));
  }

  void step() {
    if (!_ensureLoaded()) return;
    if (!_cpu.canStep) {
      state = state.copyWith(halted: true);
      return;
    }
    final fromLine = _cpu.currentInstruction?.sourceLine;
    try {
      final result = _cpu.step();
      if (result == null) {
        state = state.copyWith(halted: true);
        return;
      }
      _afterSuccessfulStep(
        result.instruction.opcode,
        fromLine,
        result.explanation,
        registerChanges: result.registerChanges.keys.toSet(),
        memoryWrites: result.memoryWrites.map((w) => w.address).toSet(),
      );
    } on AsmException catch (e) {
      _handleRuntimeError(e);
    }
  }

  void _afterSuccessfulStep(
    Opcode opcode,
    int? fromLine,
    String explanation, {
    Set<String> registerChanges = const {},
    Set<int> memoryWrites = const {},
  }) {
    _syncFromCpu(consoleLine: explanation);
    state = state.copyWith(
      lastRegisterChanges: registerChanges,
      lastMemoryWrites: memoryWrites,
      stepPulse: state.stepPulse + 1,
    );

    if (_arithmeticOpcodes.contains(opcode)) {
      ref.read(progressControllerProvider.notifier).recordArithmeticInstructions(1);
    }
    if (_cpu.flags.zf) {
      ref.read(progressControllerProvider.notifier).recordMilestone('zero_flag_triggered');
    }
    if (_cpu.history.last?.memoryWrites.isNotEmpty ?? false) {
      ref.read(progressControllerProvider.notifier).recordMilestone('memory_write_done');
    }
    if (opcode.isJump && fromLine != null && _cpu.currentInstruction != null) {
      final targetLine = _cpu.currentInstruction!.sourceLine;
      if (targetLine <= fromLine) {
        ref.read(progressControllerProvider.notifier).recordMilestone('loop_executed');
      }
    }
  }

  void _handleRuntimeError(AsmException e) {
    _runTimer?.cancel();
    state = state.copyWith(
      errorMessage: e.message,
      halted: true,
      isRunning: false,
      registers: _cpu.registers.snapshot(),
      flags: _cpu.flags.snapshot(),
      stack: _cpu.stack.entries(),
      consoleLines: [...state.consoleLines, '⚠ ${e.message}'],
    );
  }

  void run() {
    if (!_ensureLoaded()) return;
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    var isFirstTick = true;
    _runTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (!_cpu.canStep) {
        timer.cancel();
        state = state.copyWith(isRunning: false, halted: true);
        return;
      }
      final fromLine = _cpu.currentInstruction?.sourceLine;
      if (!isFirstTick && _cpu.breakpoints.has(_cpu.currentInstruction!.sourceLine)) {
        timer.cancel();
        state = state.copyWith(isRunning: false);
        return;
      }
      isFirstTick = false;
      try {
        final result = _cpu.step();
        if (result != null) {
          _afterSuccessfulStep(
            result.instruction.opcode,
            fromLine,
            result.explanation,
            registerChanges: result.registerChanges.keys.toSet(),
            memoryWrites: result.memoryWrites.map((w) => w.address).toSet(),
          );
        }
        if (_cpu.halted) {
          timer.cancel();
          state = state.copyWith(isRunning: false);
        }
      } on AsmException catch (e) {
        timer.cancel();
        _handleRuntimeError(e);
      }
    });
  }

  void pause() {
    _runTimer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _runTimer?.cancel();
    _loadedSource = '';
    _cpu.reset();
    state = LabState(
      source: state.source,
      breakpoints: Set.from(_cpu.breakpoints.lines),
    );
    _ensureLoaded();
  }

  void loadStarterCode(String code) {
    _runTimer?.cancel();
    _loadedSource = '';
    state = LabState(source: code);
    _ensureLoaded();
  }
}

final labControllerProvider = NotifierProvider<LabController, LabState>(
  LabController.new,
);
