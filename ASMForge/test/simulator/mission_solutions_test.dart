// Vérifie que la solution attendue de chaque mission (section 23) satisfait
// réellement ses conditions de réussite, en exécutant le code à travers le
// même moteur que celui utilisé par l'application (core/simulator).
import 'package:asmforge/core/simulator/program_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mission 01 — Réveiller le processeur', () {
    final result = runProgramToCompletion('MOV RAX, 1');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 1);
  });

  test('Mission 02 — Restaurer les registres', () {
    final result = runProgramToCompletion('''
MOV RAX, 1
MOV RBX, 2
MOV RCX, 3
MOV RDX, 4
MOV RSI, 5
MOV RDI, 6
''');
    expect(result.success, isTrue);
    final regs = result.cpu!.registers;
    expect(regs.read('RAX'), 1);
    expect(regs.read('RBX'), 2);
    expect(regs.read('RCX'), 3);
    expect(regs.read('RDX'), 4);
    expect(regs.read('RSI'), 5);
    expect(regs.read('RDI'), 6);
  });

  test('Mission 03 — Réparer l\'ALU', () {
    final result = runProgramToCompletion('''
MOV RAX, 8
MOV RBX, 4
ADD RAX, RBX
MOV RBX, 2
MUL RBX
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 24);
  });

  test('Mission 04 — Débloquer une boucle infinie', () {
    final result = runProgramToCompletion('''
MOV RAX, 0
MOV RCX, 5
boucle:
ADD RAX, RCX
DEC RCX
CMP RCX, 0
JNE boucle
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 15);
  });

  test('Mission 05 — Reconstruire la pile', () {
    final result = runProgramToCompletion('''
PUSH 10
PUSH 20
POP RAX
POP RBX
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 20);
    expect(result.cpu!.registers.read('RBX'), 10);
  });

  test('Mission 06 — Retrouver une valeur perdue en mémoire', () {
    final result = runProgramToCompletion('''
MOV [0x40], 77
MOV RAX, [0x40]
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 77);
  });

  test('Mission 07 — Réparer un CALL/RET', () {
    final result = runProgramToCompletion('''
MOV RAX, 5
CALL ajouter_dix
HLT
ajouter_dix:
ADD RAX, 10
RET
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 15);
  });

  test('Mission 08 — Restaurer CORE-01 (factorielle de 4)', () {
    final result = runProgramToCompletion('''
MOV RAX, 1
MOV RCX, 4
boucle:
MUL RCX
DEC RCX
CMP RCX, 0
JNE boucle
MOV [0x50], RAX
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 24);
    expect(result.cpu!.memory.readQword(0x50), 24);
  });
}
