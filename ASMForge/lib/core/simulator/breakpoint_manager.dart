/// Gère les points d'arrêt posés sur des numéros de ligne du code source.
class BreakpointManager {
  final Set<int> _lines = {};

  bool has(int line) => _lines.contains(line);

  void toggle(int line) {
    if (_lines.contains(line)) {
      _lines.remove(line);
    } else {
      _lines.add(line);
    }
  }

  void clear() => _lines.clear();

  Set<int> get lines => Set.unmodifiable(_lines);
}
