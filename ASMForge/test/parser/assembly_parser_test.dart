import 'package:asmforge/core/simulator/assembly_parser.dart';
import 'package:asmforge/core/simulator/opcode.dart';
import 'package:asmforge/core/simulator/operand.dart';
import 'package:asmforge/core/simulator/simulator_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = AssemblyParser();

  test('ignore les commentaires et les lignes vides', () {
    final program = parser.parse('''
; ceci est un commentaire
MOV RAX, 5   ; commentaire en fin de ligne

NOP
''');
    expect(program.instructions.length, 2);
    expect(program.instructions[0].opcode, Opcode.mov);
    expect(program.instructions[1].opcode, Opcode.nop);
  });

  test('construit correctement la table des étiquettes', () {
    final program = parser.parse('''
MOV RAX, 1
boucle:
INC RAX
JMP boucle
''');
    expect(program.labels['boucle'], 1);
  });

  test('reconnaît un opérande mémoire avec registre et décalage négatif', () {
    final program = parser.parse('MOV [RBP-8], RAX');
    final dest = program.instructions.first.operands.first;
    expect(dest, isA<MemoryOperand>());
    expect((dest as MemoryOperand).base, 'RBP');
    expect(dest.offset, -8);
  });

  test('reconnaît une adresse mémoire absolue en hexadécimal', () {
    final program = parser.parse('MOV RAX, [0x10]');
    final source = program.instructions.first.operands[1];
    expect(source, isA<MemoryOperand>());
    expect((source as MemoryOperand).base, isNull);
    expect(source.offset, 16);
  });

  test('rejette un nombre d\'opérandes incorrect', () {
    expect(
      () => parser.parse('ADD RAX'),
      throwsA(isA<AsmParseException>()),
    );
  });

  test('rejette MOV vers une valeur immédiate', () {
    expect(
      () => parser.parse('MOV 5, RAX'),
      throwsA(isA<AsmParseException>()),
    );
  });

  test('rejette un opérande de saut qui n\'est pas une étiquette', () {
    expect(
      () => parser.parse('JMP 5'),
      throwsA(isA<AsmParseException>()),
    );
  });

  test('ignore silencieusement les directives NASM non exécutables', () {
    final program = parser.parse('''
section .text
global _start
MOV RAX, 1
''');
    expect(program.instructions.length, 1);
  });
}
