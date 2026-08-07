import 'arithmetic.dart';
import 'assembly_parser.dart';
import 'breakpoint_manager.dart';
import 'execution_history.dart';
import 'explanation_generator.dart';
import 'flag_register.dart';
import 'instruction.dart';
import 'memory_manager.dart';
import 'opcode.dart';
import 'operand.dart';
import 'register_bank.dart';
import 'simulator_exceptions.dart';
import 'stack_manager.dart';

/// Moteur d'exécution du simulateur CPU pédagogique ASMForge.
///
/// Entièrement synchrone et indépendant de Flutter : testable seul
/// (voir test/simulator/). L'UI (Laboratoire) pilote Run/Step/Pause/Reset
/// en appelant [step] en boucle, jamais en dupliquant de logique ici.
///
/// Sécurité : cet interpréteur ne lit et n'écrit que dans sa mémoire
/// simulée en RAM du processus Dart. Il n'exécute jamais de code natif,
/// n'accède ni au système de fichiers, ni au réseau, ni à des processus
/// externes (section 39 du cahier des charges).
class CpuSimulator {
  static const int instructionLimit = 20000;

  final RegisterBank registers = RegisterBank();
  final FlagRegister flags = FlagRegister();
  final MemoryManager memory = MemoryManager();
  final ExecutionHistory history = ExecutionHistory();
  final BreakpointManager breakpoints = BreakpointManager();
  late final StackManager stack = StackManager(memory, registers);

  List<Instruction> program = [];
  Map<String, int> labels = {};
  int ip = 0;
  bool halted = true;
  int stepCount = 0;
  AsmException? lastError;

  /// Analyse [source] et réinitialise complètement l'état du processeur.
  void loadProgram(String source) {
    final parsed = AssemblyParser().parse(source);
    program = parsed.instructions;
    labels = parsed.labels;
    reset();
  }

  void reset() {
    registers.reset();
    flags.reset();
    memory.reset();
    history.clear();
    ip = 0;
    stepCount = 0;
    lastError = null;
    halted = program.isEmpty;
  }

  bool get canStep => !halted && ip >= 0 && ip < program.length;

  Instruction? get currentInstruction =>
      (ip >= 0 && ip < program.length) ? program[ip] : null;

  /// Exécute une seule instruction (mode Step). Retourne `null` si le
  /// programme est déjà arrêté ou terminé.
  StepResult? step() {
    if (!canStep) {
      halted = true;
      return null;
    }

    stepCount++;
    if (stepCount > instructionLimit) {
      halted = true;
      lastError = AsmRuntimeException(
        'Le programme a dépassé la limite de sécurité de $instructionLimit '
        'instructions exécutées. Cela ressemble à une boucle infinie : '
        'vérifiez votre condition de sortie (CMP / Jcc).',
      );
      throw lastError!;
    }

    final instr = program[ip];
    final beforeRegs = registers.snapshot();
    final beforeFlags = flags.snapshot();
    final memWrites = <MemoryWrite>[];

    int nextIp;
    try {
      nextIp = _execute(instr, memWrites);
    } on AsmException catch (e) {
      halted = true;
      lastError = e;
      rethrow;
    }

    ip = nextIp;
    registers.write('RIP', ip);
    if (instr.opcode == Opcode.hlt || ip >= program.length || ip < 0) {
      halted = true;
    }

    final afterRegs = registers.snapshot();
    final afterFlags = flags.snapshot();

    final regChanges = <String, int>{};
    for (final k in afterRegs.keys) {
      if (beforeRegs[k] != afterRegs[k]) regChanges[k] = afterRegs[k]!;
    }
    final flagChanges = <String, bool>{};
    for (final k in afterFlags.keys) {
      if (beforeFlags[k] != afterFlags[k]) flagChanges[k] = afterFlags[k]!;
    }

    final explanation = ExplanationGenerator.explain(
      instruction: instr,
      before: beforeRegs,
      after: afterRegs,
      flagsAfter: afterFlags,
    );

    final result = StepResult(
      instruction: instr,
      registerChanges: regChanges,
      flagChanges: flagChanges,
      memoryWrites: memWrites,
      explanation: explanation,
      halted: halted,
    );
    history.add(result);
    return result;
  }

  /// Exécute jusqu'à l'arrêt, une erreur, ou un point d'arrêt atteint.
  /// Utilisé par le mode Run ; le contrôle du rythme (pour permettre
  /// Pause) est délégué à l'appelant, qui doit ré-invoquer [runUntilPause]
  /// par petits lots ou observer [halted] entre deux appels à [step].
  List<StepResult> runUntilPause({required bool Function() isPaused}) {
    final results = <StepResult>[];
    while (canStep && !isPaused()) {
      final instr = program[ip];
      if (results.isNotEmpty && breakpoints.has(instr.sourceLine)) break;
      final result = step();
      if (result != null) results.add(result);
      if (halted) break;
    }
    return results;
  }

  int _resolveAddress(MemoryOperand op) {
    final base = op.base == null ? 0 : registers.read(op.base!);
    return base + op.offset;
  }

  int _readOperand(Operand op) {
    return switch (op) {
      RegisterOperand r => registers.read(r.name),
      ImmediateOperand i => i.value,
      MemoryOperand m => memory.readQword(_resolveAddress(m)),
      LabelOperand l => throw AsmRuntimeException(
          'L\'étiquette « ${l.name} » ne peut pas être utilisée comme '
          'valeur.',
        ),
    };
  }

  void _writeOperand(Operand op, int value, List<MemoryWrite> memWrites) {
    switch (op) {
      case RegisterOperand r:
        registers.write(r.name, value);
      case MemoryOperand m:
        final addr = _resolveAddress(m);
        memory.writeQword(addr, value);
        memWrites.add(MemoryWrite(address: addr, value: value));
      default:
        throw const AsmRuntimeException('Destination invalide.');
    }
  }

  int _execute(Instruction instr, List<MemoryWrite> memWrites) {
    final ops = instr.operands;
    switch (instr.opcode) {
      case Opcode.mov:
        _writeOperand(ops[0], _readOperand(ops[1]), memWrites);
        return ip + 1;

      case Opcode.add:
        {
          final a = _readOperand(ops[0]);
          final b = _readOperand(ops[1]);
          final r = addWithFlags(a, b);
          _writeOperand(ops[0], r.value, memWrites);
          flags.updateZfSf(r.value);
          flags.cf = r.carry;
          flags.of = r.overflow;
          return ip + 1;
        }

      case Opcode.sub:
        {
          final a = _readOperand(ops[0]);
          final b = _readOperand(ops[1]);
          final r = subWithFlags(a, b);
          _writeOperand(ops[0], r.value, memWrites);
          flags.updateZfSf(r.value);
          flags.cf = r.carry;
          flags.of = r.overflow;
          return ip + 1;
        }

      case Opcode.inc:
        {
          final a = _readOperand(ops[0]);
          final r = addWithFlags(a, 1);
          _writeOperand(ops[0], r.value, memWrites);
          flags.updateZfSf(r.value);
          flags.of = r.overflow;
          return ip + 1;
        }

      case Opcode.dec:
        {
          final a = _readOperand(ops[0]);
          final r = subWithFlags(a, 1);
          _writeOperand(ops[0], r.value, memWrites);
          flags.updateZfSf(r.value);
          flags.of = r.overflow;
          return ip + 1;
        }

      case Opcode.mul:
        {
          final a = registers.read('RAX');
          final b = _readOperand(ops[0]);
          final r = mulWithFlags(a, b);
          registers.write('RAX', r.value);
          flags.cf = r.carry;
          flags.of = r.overflow;
          return ip + 1;
        }

      case Opcode.div:
        {
          final divisor = _readOperand(ops[0]);
          if (divisor == 0) {
            final name = ops[0] is RegisterOperand
                ? (ops[0] as RegisterOperand).name
                : ops[0].toString();
            throw AsmRuntimeException(
              'Division impossible : $name contient 0.',
              line: instr.sourceLine,
            );
          }
          final dividend = registers.read('RAX');
          final r = divWithRemainder(dividend, divisor);
          registers.write('RAX', r.quotient);
          registers.write('RDX', r.remainder);
          return ip + 1;
        }

      case Opcode.cmp:
        {
          final a = _readOperand(ops[0]);
          final b = _readOperand(ops[1]);
          final r = subWithFlags(a, b);
          flags.updateZfSf(r.value);
          flags.cf = r.carry;
          flags.of = r.overflow;
          return ip + 1;
        }

      case Opcode.jmp:
        return labels[(ops[0] as LabelOperand).name]!;

      case Opcode.je:
        return flags.zf ? labels[(ops[0] as LabelOperand).name]! : ip + 1;

      case Opcode.jne:
        return !flags.zf ? labels[(ops[0] as LabelOperand).name]! : ip + 1;

      case Opcode.jg:
        return (!flags.zf && flags.sf == flags.of)
            ? labels[(ops[0] as LabelOperand).name]!
            : ip + 1;

      case Opcode.jl:
        return (flags.sf != flags.of)
            ? labels[(ops[0] as LabelOperand).name]!
            : ip + 1;

      case Opcode.jge:
        return (flags.sf == flags.of)
            ? labels[(ops[0] as LabelOperand).name]!
            : ip + 1;

      case Opcode.jle:
        return (flags.zf || flags.sf != flags.of)
            ? labels[(ops[0] as LabelOperand).name]!
            : ip + 1;

      case Opcode.push:
        stack.push(_readOperand(ops[0]));
        return ip + 1;

      case Opcode.pop:
        {
          final value = stack.pop();
          registers.write((ops[0] as RegisterOperand).name, value);
          return ip + 1;
        }

      case Opcode.call:
        stack.push(ip + 1);
        return labels[(ops[0] as LabelOperand).name]!;

      case Opcode.ret:
        return stack.pop();

      case Opcode.nop:
        return ip + 1;

      case Opcode.hlt:
        return ip + 1;
    }
  }
}
