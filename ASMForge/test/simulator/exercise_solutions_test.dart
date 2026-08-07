// Vérifie que les solutions attendues des exercices « Écrire le programme »
// (section 21) satisfont réellement leurs conditions de réussite.
import 'package:asmforge/core/simulator/program_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ex_muldiv_1 — division avec quotient et reste', () {
    final result = runProgramToCompletion('MOV RAX, 20\nMOV RBX, 6\nDIV RBX');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 3);
    expect(result.cpu!.registers.read('RDX'), 2);
  });

  test('ex_loop_2 — somme de 1 à 4 par boucle', () {
    final result = runProgramToCompletion('''
MOV RAX, 0
MOV RCX, 4
boucle:
ADD RAX, RCX
DEC RCX
CMP RCX, 0
JNE boucle
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 10);
  });

  test('ex_mem_1 — écriture puis lecture mémoire', () {
    final result = runProgramToCompletion('MOV [0x20], 99\nMOV RAX, [0x20]');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 99);
  });

  test('ex_stack_2 — échange de valeurs via la pile', () {
    final result = runProgramToCompletion('''
MOV RAX, 1
MOV RBX, 2
PUSH RAX
PUSH RBX
POP RAX
POP RBX
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 2);
    expect(result.cpu!.registers.read('RBX'), 1);
  });

  test('ex_func_1 — fonction triple via CALL/RET', () {
    final result = runProgramToCompletion('''
MOV RAX, 4
CALL triple
HLT
triple:
MOV RBX, 3
MUL RBX
RET
''');
    expect(result.success, isTrue);
    expect(result.cpu!.registers.read('RAX'), 12);
  });
}
