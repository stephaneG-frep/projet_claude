/// Représente un opérande d'instruction assembleur pédagogique.
///
/// Quatre formes sont supportées, volontairement limitées par rapport au
/// NASM réel afin de rester un interpréteur pédagogique isolé et sûr :
/// - registre (`RAX`)
/// - immédiat décimal ou hexadécimal (`5`, `0x1F`)
/// - mémoire indirecte (`[RBP-8]`, `[RAX]`, `[0x10]`)
/// - étiquette, utilisée par JMP/Jcc/CALL (`boucle`)
sealed class Operand {
  const Operand();
}

class RegisterOperand extends Operand {
  final String name;
  const RegisterOperand(this.name);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      other is RegisterOperand && other.name == name;
  @override
  int get hashCode => name.hashCode;
}

class ImmediateOperand extends Operand {
  final int value;
  const ImmediateOperand(this.value);

  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object other) =>
      other is ImmediateOperand && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

/// Adresse mémoire indirecte : `[base + offset]` ou `[offset]` si `base` est
/// nul (adresse absolue).
class MemoryOperand extends Operand {
  final String? base;
  final int offset;
  const MemoryOperand({this.base, this.offset = 0});

  @override
  String toString() {
    if (base == null) return '[$offset]';
    if (offset == 0) return '[$base]';
    final sign = offset >= 0 ? '+' : '-';
    return '[$base$sign${offset.abs()}]';
  }

  @override
  bool operator ==(Object other) =>
      other is MemoryOperand && other.base == base && other.offset == offset;
  @override
  int get hashCode => Object.hash(base, offset);
}

class LabelOperand extends Operand {
  final String name;
  const LabelOperand(this.name);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) => other is LabelOperand && other.name == name;
  @override
  int get hashCode => name.hashCode;
}
