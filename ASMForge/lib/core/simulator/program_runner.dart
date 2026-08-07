import 'cpu_simulator.dart';
import 'simulator_exceptions.dart';

/// Résultat de l'exécution complète d'un programme utilisateur (utilisé
/// par les missions, les mini-projets et les exercices « Écrire le
/// programme »).
class ProgramRunResult {
  final CpuSimulator? cpu;
  final String? error;
  const ProgramRunResult({this.cpu, this.error});

  bool get success => error == null && cpu != null;
}

/// Charge puis exécute [source] jusqu'à son terme (HLT, fin de
/// programme, ou erreur). Protégé par la limite d'instructions du moteur
/// contre les boucles infinies.
ProgramRunResult runProgramToCompletion(String source) {
  final cpu = CpuSimulator();
  try {
    cpu.loadProgram(source);
    while (cpu.canStep) {
      cpu.step();
    }
    return ProgramRunResult(cpu: cpu);
  } on AsmException catch (e) {
    return ProgramRunResult(error: e.message);
  }
}

class CheckOutcome {
  final String description;
  final bool passed;
  final int actualValue;
  final int expectedValue;
  const CheckOutcome({
    required this.description,
    required this.passed,
    required this.actualValue,
    required this.expectedValue,
  });
}

class SimpleCheck {
  final String? register;
  final int? memoryAddress;
  final int expectedValue;
  final String description;
  const SimpleCheck({
    this.register,
    this.memoryAddress,
    required this.expectedValue,
    required this.description,
  });
}

List<CheckOutcome> evaluateChecks(CpuSimulator cpu, List<SimpleCheck> checks) {
  return checks.map((check) {
    final actual = check.register != null
        ? cpu.registers.read(check.register!)
        : cpu.memory.readQword(check.memoryAddress!);
    return CheckOutcome(
      description: check.description,
      passed: actual == check.expectedValue,
      actualValue: actual,
      expectedValue: check.expectedValue,
    );
  }).toList();
}
