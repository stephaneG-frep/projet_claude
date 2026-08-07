import 'simulator_exceptions.dart';

/// Mémoire simulée, adressable par octet.
///
/// Taille volontairement réduite (4 Ko) : suffisante pour illustrer
/// pédagogiquement adresses, pile et tableaux, sans complexité de gestion
/// de grands espaces d'adressage inutile pour l'apprentissage.
class MemoryManager {
  static const int size = 4096;

  /// Le sommet de la pile démarre en haut de la mémoire simulée et
  /// grandit vers les adresses basses, comme sur une vraie pile x86-64.
  static const int stackTop = size - 8;

  final List<int> _bytes = List<int>.filled(size, 0);

  int readByte(int address) {
    _checkBounds(address);
    return _bytes[address];
  }

  void writeByte(int address, int value) {
    _checkBounds(address);
    _bytes[address] = value & 0xFF;
  }

  /// Lit un mot de 8 octets (little-endian) à partir de [address].
  int readQword(int address) {
    _checkBounds(address);
    _checkBounds(address + 7);
    int value = 0;
    for (var i = 7; i >= 0; i--) {
      value = (value << 8) | _bytes[address + i];
    }
    return value;
  }

  void writeQword(int address, int value) {
    _checkBounds(address);
    _checkBounds(address + 7);
    var v = value;
    for (var i = 0; i < 8; i++) {
      _bytes[address + i] = v & 0xFF;
      v >>= 8;
    }
  }

  void _checkBounds(int address) {
    if (address < 0 || address >= size) {
      throw AsmRuntimeException(
        'Accès mémoire invalide à l\'adresse 0x${address.toRadixString(16)} '
        '(mémoire simulée limitée à $size octets, de 0x0000 à '
        '0x${(size - 1).toRadixString(16)}).',
      );
    }
  }

  List<int> get bytes => List.unmodifiable(_bytes);

  void reset() {
    for (var i = 0; i < size; i++) {
      _bytes[i] = 0;
    }
  }

  MemoryManager clone() {
    final m = MemoryManager();
    for (var i = 0; i < size; i++) {
      m._bytes[i] = _bytes[i];
    }
    return m;
  }
}
