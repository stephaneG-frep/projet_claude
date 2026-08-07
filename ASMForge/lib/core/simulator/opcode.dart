/// Instructions supportées par le simulateur pédagogique ASMForge.
///
/// Une instruction n'est ajoutée à cette liste que lorsque son comportement
/// est correctement testé (voir docs/SIMULATOR.md et test/simulator/).
enum Opcode {
  mov,
  add,
  sub,
  inc,
  dec,
  mul,
  div,
  cmp,
  jmp,
  je,
  jne,
  jg,
  jl,
  jge,
  jle,
  push,
  pop,
  call,
  ret,
  nop,
  hlt,
}

extension OpcodeParsing on Opcode {
  String get mnemonic => name.toUpperCase();

  static Opcode? fromMnemonic(String text) {
    final normalized = text.toLowerCase();
    for (final op in Opcode.values) {
      if (op.name == normalized) return op;
    }
    return null;
  }

  /// Nombre d'opérandes attendu (min, max) pour valider la syntaxe.
  (int min, int max) get arity => switch (this) {
        Opcode.mov => (2, 2),
        Opcode.add => (2, 2),
        Opcode.sub => (2, 2),
        Opcode.inc => (1, 1),
        Opcode.dec => (1, 1),
        Opcode.mul => (1, 1),
        Opcode.div => (1, 1),
        Opcode.cmp => (2, 2),
        Opcode.jmp => (1, 1),
        Opcode.je => (1, 1),
        Opcode.jne => (1, 1),
        Opcode.jg => (1, 1),
        Opcode.jl => (1, 1),
        Opcode.jge => (1, 1),
        Opcode.jle => (1, 1),
        Opcode.push => (1, 1),
        Opcode.pop => (1, 1),
        Opcode.call => (1, 1),
        Opcode.ret => (0, 0),
        Opcode.nop => (0, 0),
        Opcode.hlt => (0, 0),
      };

  bool get isJump => switch (this) {
        Opcode.jmp ||
        Opcode.je ||
        Opcode.jne ||
        Opcode.jg ||
        Opcode.jl ||
        Opcode.jge ||
        Opcode.jle ||
        Opcode.call =>
          true,
        _ => false,
      };

  /// Catégorie utilisée par l'encyclopédie de référence (section 25).
  String get category => switch (this) {
        Opcode.mov => 'Transfert de données',
        Opcode.add || Opcode.sub || Opcode.inc || Opcode.dec || Opcode.mul || Opcode.div =>
          'Arithmétique',
        Opcode.cmp => 'Comparaison',
        Opcode.jmp || Opcode.je || Opcode.jne || Opcode.jg || Opcode.jl || Opcode.jge || Opcode.jle =>
          'Saut / branchement',
        Opcode.push || Opcode.pop => 'Pile',
        Opcode.call || Opcode.ret => 'Fonctions',
        Opcode.nop || Opcode.hlt => 'Contrôle',
      };
}
