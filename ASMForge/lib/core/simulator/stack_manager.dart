import 'memory_manager.dart';
import 'register_bank.dart';
import 'simulator_exceptions.dart';

/// Gère PUSH/POP au-dessus de la mémoire simulée, en pilotant RSP.
///
/// RSP démarre à [MemoryManager.size] (pile vide, « juste après » la
/// dernière adresse valide) et décroît de 8 à chaque PUSH, comme une vraie
/// pile x86-64 qui grandit vers les adresses basses.
class StackManager {
  final MemoryManager memory;
  final RegisterBank registers;

  StackManager(this.memory, this.registers);

  static int get emptyPointer => MemoryManager.size;

  void push(int value) {
    final rsp = registers.read('RSP');
    final newRsp = rsp - 8;
    if (newRsp < 0) {
      throw const AsmRuntimeException(
        'Débordement de pile : il n\'y a plus de place pour empiler une '
        'nouvelle valeur (PUSH).',
      );
    }
    memory.writeQword(newRsp, value);
    registers.write('RSP', newRsp);
  }

  int pop() {
    final rsp = registers.read('RSP');
    if (rsp >= emptyPointer) {
      throw const AsmRuntimeException(
        'Pile vide : impossible de dépiler (POP), aucune valeur n\'a été '
        'empilée au préalable.',
      );
    }
    final value = memory.readQword(rsp);
    registers.write('RSP', rsp + 8);
    return value;
  }

  bool get isEmpty => registers.read('RSP') >= emptyPointer;

  /// Retourne les entrées de la pile du sommet vers la base, pour le
  /// Stack Viewer (section 19).
  List<StackEntry> entries() {
    final rsp = registers.read('RSP');
    final result = <StackEntry>[];
    for (var addr = rsp; addr < emptyPointer; addr += 8) {
      result.add(StackEntry(address: addr, value: memory.readQword(addr)));
    }
    return result;
  }
}

class StackEntry {
  final int address;
  final int value;
  const StackEntry({required this.address, required this.value});
}
