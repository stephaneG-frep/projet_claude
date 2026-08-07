import 'memory_manager.dart';

/// Banque de registres 64 bits simulés.
///
/// Limitation connue : sur le web, Dart compile les entiers en `double`
/// JavaScript (précision entière sûre jusqu'à 2^53). Le simulateur reste
/// donc « 64 bits dans les limites raisonnables de Dart », comme demandé
/// par le cahier des charges, et non un vrai registre matériel 64 bits sur
/// toutes les plateformes.
class RegisterBank {
  static const List<String> generalPurpose = [
    'RAX',
    'RBX',
    'RCX',
    'RDX',
    'RSI',
    'RDI',
  ];

  static const List<String> pointers = ['RSP', 'RBP', 'RIP'];

  static const List<String> all = [...generalPurpose, ...pointers];

  final Map<String, int> _values = {
    for (final r in all) r: r == 'RSP' ? MemoryManager.size : 0,
  };

  int read(String name) {
    final key = name.toUpperCase();
    if (!_values.containsKey(key)) {
      throw ArgumentError('Registre inconnu : $name');
    }
    return _values[key]!;
  }

  void write(String name, int value) {
    final key = name.toUpperCase();
    if (!_values.containsKey(key)) {
      throw ArgumentError('Registre inconnu : $name');
    }
    _values[key] = value;
  }

  static bool isValid(String name) => all.contains(name.toUpperCase());

  Map<String, int> snapshot() => Map.unmodifiable(_values);

  void reset() {
    for (final r in all) {
      _values[r] = r == 'RSP' ? MemoryManager.size : 0;
    }
  }

  RegisterBank clone() {
    final bank = RegisterBank();
    bank._values.addAll(_values);
    return bank;
  }
}
