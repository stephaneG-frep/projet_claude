import '../../../core/simulator/instruction.dart';
import '../../../core/simulator/stack_manager.dart';

class LabState {
  final String source;
  final List<Instruction> program;
  final Map<String, int> registers;
  final Map<String, bool> flags;
  final List<StackEntry> stack;
  final List<int> memoryPreview;
  final int? currentLine;
  final bool halted;
  final bool isRunning;
  final bool hasStarted;
  final String? errorMessage;
  final List<String> consoleLines;
  final Set<int> breakpoints;
  final Set<String> lastRegisterChanges;
  final Set<int> lastMemoryWrites;
  final int stepPulse;

  const LabState({
    this.source = '',
    this.program = const [],
    this.registers = const {},
    this.flags = const {},
    this.stack = const [],
    this.memoryPreview = const [],
    this.currentLine,
    this.halted = true,
    this.isRunning = false,
    this.hasStarted = false,
    this.errorMessage,
    this.consoleLines = const [],
    this.breakpoints = const {},
    this.lastRegisterChanges = const {},
    this.lastMemoryWrites = const {},
    this.stepPulse = 0,
  });

  LabState copyWith({
    String? source,
    List<Instruction>? program,
    Map<String, int>? registers,
    Map<String, bool>? flags,
    List<StackEntry>? stack,
    List<int>? memoryPreview,
    int? currentLine,
    bool clearCurrentLine = false,
    bool? halted,
    bool? isRunning,
    bool? hasStarted,
    String? errorMessage,
    bool clearError = false,
    List<String>? consoleLines,
    Set<int>? breakpoints,
    Set<String>? lastRegisterChanges,
    Set<int>? lastMemoryWrites,
    int? stepPulse,
  }) {
    return LabState(
      source: source ?? this.source,
      program: program ?? this.program,
      registers: registers ?? this.registers,
      flags: flags ?? this.flags,
      stack: stack ?? this.stack,
      memoryPreview: memoryPreview ?? this.memoryPreview,
      currentLine: clearCurrentLine ? null : (currentLine ?? this.currentLine),
      halted: halted ?? this.halted,
      isRunning: isRunning ?? this.isRunning,
      hasStarted: hasStarted ?? this.hasStarted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      consoleLines: consoleLines ?? this.consoleLines,
      breakpoints: breakpoints ?? this.breakpoints,
      lastRegisterChanges: lastRegisterChanges ?? this.lastRegisterChanges,
      lastMemoryWrites: lastMemoryWrites ?? this.lastMemoryWrites,
      stepPulse: stepPulse ?? this.stepPulse,
    );
  }
}
