import 'opcode.dart';
import 'operand.dart';

/// Une instruction assembleur analysée, prête à être exécutée.
class Instruction {
  final Opcode opcode;
  final List<Operand> operands;

  /// Numéro de ligne dans le code source (1-indexé), utilisé pour le
  /// surlignage dans l'éditeur et les points d'arrêt.
  final int sourceLine;

  /// Texte original de la ligne, pour l'affichage et les explications.
  final String rawText;

  const Instruction({
    required this.opcode,
    required this.operands,
    required this.sourceLine,
    required this.rawText,
  });

  @override
  String toString() => rawText;
}
