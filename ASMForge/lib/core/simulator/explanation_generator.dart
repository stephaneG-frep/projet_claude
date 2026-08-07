import 'instruction.dart';
import 'opcode.dart';
import 'operand.dart';

/// Génère localement (aucune IA externe, section 20) une explication en
/// français lisible pour chaque instruction exécutée.
class ExplanationGenerator {
  ExplanationGenerator._();

  static String explain({
    required Instruction instruction,
    required Map<String, int> before,
    required Map<String, int> after,
    required Map<String, bool> flagsAfter,
  }) {
    final ops = instruction.operands;
    String val(Operand o) => o is RegisterOperand
        ? '${o.name} (${before[o.name]})'
        : o.toString();

    switch (instruction.opcode) {
      case Opcode.mov:
        return 'Le processeur copie la valeur ${val(ops[1])} dans '
            '${ops[0]}.';
      case Opcode.add:
        final dest = ops[0] as RegisterOperand;
        return 'Le processeur prend la valeur de ${dest.name} '
            '(${before[dest.name]}), ajoute ${val(ops[1])}, puis stocke le '
            'résultat ${after[dest.name]} dans ${dest.name}.';
      case Opcode.sub:
        final dest = ops[0] as RegisterOperand;
        return 'Le processeur prend la valeur de ${dest.name} '
            '(${before[dest.name]}), soustrait ${val(ops[1])}, puis stocke '
            'le résultat ${after[dest.name]} dans ${dest.name}.';
      case Opcode.inc:
        final dest = ops[0] as RegisterOperand;
        return '${dest.name} passe de ${before[dest.name]} à '
            '${after[dest.name]} (incrémentation de 1).';
      case Opcode.dec:
        final dest = ops[0] as RegisterOperand;
        return '${dest.name} passe de ${before[dest.name]} à '
            '${after[dest.name]} (décrémentation de 1).';
      case Opcode.mul:
        return 'RAX (${before['RAX']}) est multiplié par ${val(ops[0])}, '
            'le résultat ${after['RAX']} est stocké dans RAX.';
      case Opcode.div:
        return 'RAX (${before['RAX']}) est divisé par ${val(ops[0])} : le '
            'quotient (${after['RAX']}) va dans RAX, le reste '
            '(${after['RDX']}) va dans RDX.';
      case Opcode.cmp:
        return 'Le processeur compare ${val(ops[0])} et ${val(ops[1])} en '
            'effectuant une soustraction interne (sans la stocker) pour '
            'mettre à jour les flags.';
      case Opcode.jmp:
        return 'Le processeur saute inconditionnellement vers l\'étiquette '
            '« ${ops[0]} ».';
      case Opcode.je:
        return flagsAfter['ZF'] == true
            ? 'ZF est activé, donc le processeur saute vers « ${ops[0]} ».'
            : 'ZF est désactivé, donc le saut vers « ${ops[0]} » n\'a pas '
                'lieu : l\'exécution continue à la ligne suivante.';
      case Opcode.jne:
        return flagsAfter['ZF'] == false
            ? 'ZF est désactivé, donc le processeur saute vers '
                '« ${ops[0]} ».'
            : 'ZF est activé, donc le saut vers « ${ops[0]} » n\'a pas '
                'lieu.';
      case Opcode.jg:
        return 'Comparaison « strictement supérieur » : le processeur '
            'évalue SF et OF pour décider de sauter vers « ${ops[0]} ».';
      case Opcode.jl:
        return 'Comparaison « strictement inférieur » : le processeur '
            'évalue SF et OF pour décider de sauter vers « ${ops[0]} ».';
      case Opcode.jge:
        return 'Comparaison « supérieur ou égal » : le processeur évalue '
            'SF et OF pour décider de sauter vers « ${ops[0]} ».';
      case Opcode.jle:
        return 'Comparaison « inférieur ou égal » : le processeur évalue '
            'ZF, SF et OF pour décider de sauter vers « ${ops[0]} ».';
      case Opcode.push:
        return 'La valeur ${val(ops[0])} est empilée : RSP diminue de 8 '
            'et la valeur est écrite au sommet de la pile.';
      case Opcode.pop:
        final dest = ops[0] as RegisterOperand;
        return 'La valeur au sommet de la pile (${after[dest.name]}) est '
            'retirée et placée dans ${dest.name} ; RSP augmente de 8.';
      case Opcode.call:
        return 'L\'adresse de retour est empilée, puis le processeur '
            'saute vers la fonction « ${ops[0]} ».';
      case Opcode.ret:
        return 'L\'adresse de retour est dépilée et le processeur y '
            'retourne : fin de la fonction.';
      case Opcode.nop:
        return 'Aucune opération : le processeur passe simplement à la '
            'ligne suivante.';
      case Opcode.hlt:
        return 'Arrêt du programme (HLT) : l\'exécution est terminée.';
    }
  }
}
