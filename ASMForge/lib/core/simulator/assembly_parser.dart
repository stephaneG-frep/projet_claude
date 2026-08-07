import 'instruction.dart';
import 'opcode.dart';
import 'operand.dart';
import 'register_bank.dart';
import 'simulator_exceptions.dart';
import 'tokenizer.dart';

/// Résultat d'une analyse réussie : instructions exécutables + table des
/// étiquettes (nom -> index dans [instructions]).
class ParsedProgram {
  final List<Instruction> instructions;
  final Map<String, int> labels;
  const ParsedProgram({required this.instructions, required this.labels});
}

final RegExp _memoryOperandPattern = RegExp(
  r'^(?<reg>[A-Za-z]{2,3})?\s*(?<sign>[+-])?\s*(?<num>0[xX][0-9A-Fa-f]+|\d+)?$',
);
final RegExp _immediatePattern = RegExp(r'^-?(0[xX][0-9A-Fa-f]+|\d+)$');
final RegExp _labelPattern = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

int _parseIntLiteral(String text) {
  final negative = text.startsWith('-');
  final unsigned = negative ? text.substring(1) : text;
  final value = unsigned.toLowerCase().startsWith('0x')
      ? int.parse(unsigned.substring(2), radix: 16)
      : int.parse(unsigned);
  return negative ? -value : value;
}

/// Transforme un programme source en [ParsedProgram] exécutable par
/// [CpuSimulator]. Interpréteur pédagogique isolé : ne dépend d'aucune
/// exécution native, ne lit et n'écrit rien en dehors de la mémoire
/// simulée en RAM du processus Dart.
class AssemblyParser {
  final Tokenizer _tokenizer = Tokenizer();

  ParsedProgram parse(String source) {
    final lines = _tokenizer.tokenize(source);

    // Première passe : construit la table des étiquettes en comptant
    // uniquement les lignes qui produisent une instruction réelle.
    final labels = <String, int>{};
    var pendingLabels = <String>[];
    var instructionIndex = 0;
    for (final line in lines) {
      if (line.label != null) {
        pendingLabels.add(line.label!);
      }
      if (line.mnemonic != null) {
        for (final l in pendingLabels) {
          labels[l] = instructionIndex;
        }
        pendingLabels = [];
        instructionIndex++;
      }
    }
    if (pendingLabels.isNotEmpty) {
      // Étiquette en fin de fichier sans instruction : pointe sur HLT
      // implicite (fin de programme).
      for (final l in pendingLabels) {
        labels[l] = instructionIndex;
      }
    }

    // Seconde passe : construit les instructions.
    final instructions = <Instruction>[];
    for (final line in lines) {
      if (line.mnemonic == null) continue;
      final opcode = OpcodeParsing.fromMnemonic(line.mnemonic!);
      if (opcode == null) {
        final suggestion = suggestClosestName(
          line.mnemonic!,
          Opcode.values.map((o) => o.mnemonic),
        );
        throw AsmParseException(
          suggestion != null
              ? 'L\'instruction « ${line.mnemonic} » n\'existe pas. '
                  'Vouliez-vous écrire « $suggestion » ?'
              : 'L\'instruction « ${line.mnemonic} » n\'est pas reconnue par '
                  'ASMForge. Consultez la Référence pour la liste des '
                  'instructions supportées.',
          line: line.lineNumber,
        );
      }

      final operands = line.operandText
          .map((text) => _parseOperand(text, line.lineNumber, labels))
          .toList();

      final (min, max) = opcode.arity;
      if (operands.length < min || operands.length > max) {
        throw AsmParseException(
          '${opcode.mnemonic} attend '
          '${min == max ? "$min opérande(s)" : "entre $min et $max opérandes"}, '
          'mais ${operands.length} ont été trouvé(s) : « ${line.raw.trim()} ».',
          line: line.lineNumber,
        );
      }

      _validateOperandTypes(opcode, operands, line.lineNumber, line.raw);

      instructions.add(
        Instruction(
          opcode: opcode,
          operands: operands,
          sourceLine: line.lineNumber,
          rawText: line.raw.trim(),
        ),
      );
    }

    return ParsedProgram(instructions: instructions, labels: labels);
  }

  Operand _parseOperand(
    String text,
    int lineNumber,
    Map<String, int> labelsSoFar,
  ) {
    final trimmed = text.trim();

    if (RegisterBank.isValid(trimmed)) {
      return RegisterOperand(trimmed.toUpperCase());
    }

    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      final inner = trimmed.substring(1, trimmed.length - 1).trim();
      final match = _memoryOperandPattern.firstMatch(inner);
      if (match == null) {
        throw AsmParseException(
          'Adresse mémoire invalide : « $trimmed ». Utilisez par exemple '
          '[RBP-8], [RAX] ou [0x10].',
          line: lineNumber,
        );
      }
      final reg = match.namedGroup('reg');
      final sign = match.namedGroup('sign');
      final num = match.namedGroup('num');
      if (reg == null && num == null) {
        throw AsmParseException(
          'Adresse mémoire vide : « $trimmed ».',
          line: lineNumber,
        );
      }
      if (reg != null && !RegisterBank.isValid(reg)) {
        final suggestion = suggestClosestName(reg, RegisterBank.all);
        throw AsmParseException(
          suggestion != null
              ? 'Le registre $reg n\'existe pas. Vouliez-vous écrire '
                  '$suggestion ?'
              : 'Le registre $reg n\'existe pas.',
          line: lineNumber,
        );
      }
      var offset = num == null ? 0 : _parseIntLiteral(num);
      if (sign == '-') offset = -offset;
      return MemoryOperand(base: reg?.toUpperCase(), offset: offset);
    }

    if (_immediatePattern.hasMatch(trimmed)) {
      return ImmediateOperand(_parseIntLiteral(trimmed));
    }

    if (_labelPattern.hasMatch(trimmed)) {
      if (!labelsSoFar.containsKey(trimmed)) {
        // Un mot court qui ressemble à un registre est plus probablement
        // une faute de frappe sur un registre qu'une étiquette manquante.
        final registerSuggestion = suggestClosestName(
          trimmed,
          RegisterBank.all,
        );
        if (registerSuggestion != null) {
          throw AsmParseException(
            'Le registre $trimmed n\'existe pas. Vouliez-vous écrire '
            '$registerSuggestion ?',
            line: lineNumber,
          );
        }
        final labelSuggestion = suggestClosestName(
          trimmed,
          labelsSoFar.keys,
        );
        throw AsmParseException(
          labelSuggestion != null
              ? 'L\'étiquette « $trimmed » n\'existe pas dans ce programme. '
                  'Vouliez-vous écrire « $labelSuggestion » ?'
              : 'L\'étiquette « $trimmed » n\'existe pas dans ce programme. '
                  'Ajoutez « $trimmed: » devant une ligne pour la créer.',
          line: lineNumber,
        );
      }
      return LabelOperand(trimmed);
    }

    throw AsmParseException(
      'Opérande incompréhensible : « $trimmed ».',
      line: lineNumber,
    );
  }

  void _validateOperandTypes(
    Opcode opcode,
    List<Operand> operands,
    int lineNumber,
    String raw,
  ) {
    void requireWritable(Operand op, String opName) {
      if (op is ImmediateOperand || op is LabelOperand) {
        throw AsmParseException(
          '$opName nécessite un registre ou une adresse mémoire comme '
          'destination, pas une valeur immédiate ou une étiquette : '
          '« ${raw.trim()} ».',
          line: lineNumber,
        );
      }
    }

    void requireLabel(Operand op, String opName) {
      if (op is! LabelOperand) {
        throw AsmParseException(
          '$opName attend une étiquette (le nom d\'un emplacement dans le '
          'code), pas « $op ».',
          line: lineNumber,
        );
      }
    }

    void requireRegister(Operand op, String opName) {
      if (op is! RegisterOperand) {
        throw AsmParseException(
          '$opName ne fonctionne que sur un registre, pas « $op ».',
          line: lineNumber,
        );
      }
    }

    switch (opcode) {
      case Opcode.mov:
      case Opcode.add:
      case Opcode.sub:
        requireWritable(operands[0], opcode.mnemonic);
      case Opcode.inc:
      case Opcode.dec:
      case Opcode.mul:
      case Opcode.div:
        requireRegister(operands[0], opcode.mnemonic);
      case Opcode.cmp:
        break;
      case Opcode.jmp:
      case Opcode.je:
      case Opcode.jne:
      case Opcode.jg:
      case Opcode.jl:
      case Opcode.jge:
      case Opcode.jle:
      case Opcode.call:
        requireLabel(operands[0], opcode.mnemonic);
      case Opcode.push:
        if (operands[0] is LabelOperand) {
          throw AsmParseException(
            'PUSH nécessite un registre ou une valeur immédiate, pas une '
            'étiquette.',
            line: lineNumber,
          );
        }
      case Opcode.pop:
        requireRegister(operands[0], 'POP');
      case Opcode.ret:
      case Opcode.nop:
      case Opcode.hlt:
        break;
    }
  }
}
