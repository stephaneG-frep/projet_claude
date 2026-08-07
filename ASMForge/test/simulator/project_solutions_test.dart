// Vérifie que la solution attendue de chaque mini-projet (section 24)
// satisfait réellement ses conditions de réussite.
import 'package:asmforge/core/simulator/program_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Projet 1 — Additionneur', () {
    final result = runProgramToCompletion('MOV RAX, 15\nMOV RBX, 27\nADD RAX, RBX');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 42);
  });

  test('Projet 2 — Comparateur de nombres', () {
    final result = runProgramToCompletion('''
MOV RBX, 10
MOV RCX, 4
MOV RAX, 0
CMP RBX, RCX
JG plus_grand
JMP fin
plus_grand:
MOV RAX, 1
fin:
NOP
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 1);
  });

  test('Projet 3 — Compteur 1 à 10', () {
    final result = runProgramToCompletion('''
MOV RAX, 0
MOV RCX, 10
compter:
INC RAX
DEC RCX
CMP RCX, 0
JNE compter
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 10);
  });

  test('Projet 4 — Somme des nombres pairs', () {
    final result = runProgramToCompletion('''
MOV RAX, 0
MOV RBX, 2
somme:
ADD RAX, RBX
ADD RBX, 2
CMP RBX, 12
JNE somme
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 30);
  });

  test('Projet 5 — Factorielle de 5', () {
    final result = runProgramToCompletion('''
MOV RAX, 1
MOV RCX, 5
factorielle:
MUL RCX
DEC RCX
CMP RCX, 0
JNE factorielle
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 120);
  });

  test('Projet 6 — Manipulation d\'un tableau', () {
    final result = runProgramToCompletion('''
MOV RBP, 0x60
MOV [RBP], 10
MOV [RBP+8], 20
MOV [RBP+16], 30
MOV RAX, [RBP]
ADD RAX, [RBP+8]
ADD RAX, [RBP+16]
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 60);
  });

  test('Projet 7 — Calculatrice simplifiée', () {
    final result = runProgramToCompletion('''
MOV RAX, 12
MOV RBX, 4
SUB RAX, RBX
MOV RBX, 2
DIV RBX
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 4);
  });

  test('Projet 8 — Programme NASM pédagogique', () {
    final result = runProgramToCompletion('''
MOV RAX, 6
MOV RBX, 7
MUL RBX
MOV [0x30], RAX
HLT
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 42);
    expect(result.cpu!.memory.readQword(0x30), 42);
  });
}
