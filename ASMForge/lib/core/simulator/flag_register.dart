/// Registre de drapeaux (flags) : ZF, CF, SF, OF.
class FlagRegister {
  bool zf = false;
  bool cf = false;
  bool sf = false;
  bool of = false;

  void reset() {
    zf = false;
    cf = false;
    sf = false;
    of = false;
  }

  Map<String, bool> snapshot() => {'ZF': zf, 'CF': cf, 'SF': sf, 'OF': of};

  /// Met à jour ZF/SF à partir d'un résultat, comme le ferait l'ALU après
  /// la plupart des instructions arithmétiques.
  void updateZfSf(int result) {
    zf = result == 0;
    sf = result < 0;
  }

  FlagRegister clone() {
    return FlagRegister()
      ..zf = zf
      ..cf = cf
      ..sf = sf
      ..of = of;
  }
}
