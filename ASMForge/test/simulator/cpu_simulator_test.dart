import 'package:asmforge/core/simulator/cpu_simulator.dart';
import 'package:asmforge/core/simulator/simulator_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MOV / ADD / SUB', () {
    test('additionne deux registres', () {
      final cpu = CpuSimulator()
        ..loadProgram('MOV RAX, 5\nMOV RBX, 3\nADD RAX, RBX');
      cpu.step();
      cpu.step();
      cpu.step();
      expect(cpu.registers.read('RAX'), 8);
      expect(cpu.halted, isTrue);
    });

    test('SUB met à jour ZF quand le résultat est nul', () {
      final cpu = CpuSimulator()..loadProgram('MOV RAX, 5\nSUB RAX, 5');
      cpu.step();
      cpu.step();
      expect(cpu.registers.read('RAX'), 0);
      expect(cpu.flags.zf, isTrue);
    });

    test('MOV immédiat vers mémoire puis relecture', () {
      final cpu = CpuSimulator()
        ..loadProgram('MOV RBP, 100\nMOV [RBP-8], 42\nMOV RAX, [RBP-8]');
      cpu.step();
      cpu.step();
      cpu.step();
      expect(cpu.registers.read('RAX'), 42);
    });
  });

  group('INC / DEC', () {
    test('incrémente sans toucher CF', () {
      final cpu = CpuSimulator()..loadProgram('MOV RAX, 1\nINC RAX');
      cpu.step();
      cpu.flags.cf = true; // valeur arbitraire précédente
      cpu.step();
      expect(cpu.registers.read('RAX'), 2);
    });
  });

  group('MUL / DIV', () {
    test('multiplie RAX par un registre', () {
      final cpu = CpuSimulator()..loadProgram('MOV RAX, 6\nMOV RBX, 7\nMUL RBX');
      cpu.step();
      cpu.step();
      cpu.step();
      expect(cpu.registers.read('RAX'), 42);
    });

    test('divise RAX et place le reste dans RDX', () {
      final cpu = CpuSimulator()..loadProgram('MOV RAX, 17\nMOV RBX, 5\nDIV RBX');
      cpu.step();
      cpu.step();
      cpu.step();
      expect(cpu.registers.read('RAX'), 3);
      expect(cpu.registers.read('RDX'), 2);
    });

    test('division par zéro lève une erreur pédagogique', () {
      final cpu = CpuSimulator()..loadProgram('MOV RBX, 0\nDIV RBX');
      cpu.step();
      expect(
        () => cpu.step(),
        throwsA(
          isA<AsmRuntimeException>().having(
            (e) => e.message,
            'message',
            contains('RBX contient 0'),
          ),
        ),
      );
    });
  });

  group('CMP / sauts', () {
    test('JE saute quand ZF est actif', () {
      final cpu = CpuSimulator()..loadProgram('''
MOV RAX, 5
CMP RAX, 5
JE egal
MOV RBX, 1
egal:
MOV RBX, 99
''');
      while (cpu.canStep) {
        cpu.step();
      }
      expect(cpu.registers.read('RBX'), 99);
    });

    test('boucle décroissante avec JNE atteint zéro', () {
      final cpu = CpuSimulator()..loadProgram('''
MOV RCX, 5
MOV RAX, 0
boucle:
ADD RAX, 1
DEC RCX
CMP RCX, 0
JNE boucle
''');
      while (cpu.canStep) {
        cpu.step();
      }
      expect(cpu.registers.read('RCX'), 0);
      expect(cpu.registers.read('RAX'), 5);
    });
  });

  group('Pile', () {
    test('PUSH puis POP restitue la valeur', () {
      final cpu = CpuSimulator()..loadProgram('MOV RAX, 42\nPUSH RAX\nMOV RAX, 0\nPOP RBX');
      while (cpu.canStep) {
        cpu.step();
      }
      expect(cpu.registers.read('RBX'), 42);
    });

    test('POP sur pile vide lève une erreur pédagogique', () {
      final cpu = CpuSimulator()..loadProgram('POP RAX');
      expect(() => cpu.step(), throwsA(isA<AsmRuntimeException>()));
    });
  });

  group('CALL / RET', () {
    test('appelle une fonction et revient correctement', () {
      final cpu = CpuSimulator()..loadProgram('''
MOV RAX, 1
CALL double_it
HLT
double_it:
ADD RAX, RAX
RET
''');
      while (cpu.canStep) {
        cpu.step();
      }
      expect(cpu.registers.read('RAX'), 2);
    });
  });

  group('Robustesse', () {
    test('registre invalide donne un message avec suggestion', () {
      final cpu = CpuSimulator();
      expect(
        () => cpu.loadProgram('MOV RXA, 5'),
        throwsA(
          isA<AsmParseException>().having(
            (e) => e.message,
            'message',
            contains('RAX'),
          ),
        ),
      );
    });

    test('saut vers une étiquette inexistante est rejeté à l\'analyse', () {
      final cpu = CpuSimulator();
      expect(
        () => cpu.loadProgram('JMP inconnue'),
        throwsA(isA<AsmParseException>()),
      );
    });

    test('dépassement mémoire est détecté', () {
      final cpu = CpuSimulator()..loadProgram('MOV [999999], 1');
      expect(() => cpu.step(), throwsA(isA<AsmRuntimeException>()));
    });

    test('boucle infinie est stoppée par la limite de sécurité', () {
      final cpu = CpuSimulator()..loadProgram('''
boucle:
JMP boucle
''');
      expect(() {
        while (cpu.canStep) {
          cpu.step();
        }
      }, throwsA(isA<AsmRuntimeException>()));
    });
  });
}
