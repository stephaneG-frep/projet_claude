import 'instruction.dart';

class MemoryWrite {
  final int address;
  final int value;
  const MemoryWrite({required this.address, required this.value});
}

/// Résultat d'un [CpuSimulator.step] : ce qui a changé, pour surligner
/// l'interface et générer l'explication pédagogique (sections 16 et 20).
class StepResult {
  final Instruction instruction;
  final Map<String, int> registerChanges;
  final Map<String, bool> flagChanges;
  final List<MemoryWrite> memoryWrites;
  final String explanation;
  final bool halted;

  const StepResult({
    required this.instruction,
    required this.registerChanges,
    required this.flagChanges,
    required this.memoryWrites,
    required this.explanation,
    required this.halted,
  });
}

/// Historique des pas d'exécution d'une session du simulateur.
class ExecutionHistory {
  final List<StepResult> _steps = [];

  List<StepResult> get steps => List.unmodifiable(_steps);

  StepResult? get last => _steps.isEmpty ? null : _steps.last;

  void add(StepResult result) => _steps.add(result);

  void clear() => _steps.clear();

  int get length => _steps.length;
}
