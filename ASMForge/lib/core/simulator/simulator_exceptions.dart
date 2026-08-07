/// Exceptions pédagogiques du simulateur.
///
/// Conformément à la section « Gestion des erreurs » du cahier des charges,
/// aucun message ne doit ressembler à un code d'erreur brut : chaque
/// exception porte un message humain, en français, expliquant la cause et
/// si possible une piste de correction.
sealed class AsmException implements Exception {
  final String message;
  final int? line;
  const AsmException(this.message, {this.line});

  @override
  String toString() => message;
}

/// Erreur détectée pendant l'analyse (tokenizer / parser) : syntaxe
/// invalide, mnémonique inconnu, nombre d'opérandes incorrect…
class AsmParseException extends AsmException {
  const AsmParseException(super.message, {super.line});
}

/// Erreur détectée pendant l'exécution : division par zéro, registre
/// invalide, pile vide, saut vers une étiquette inexistante, dépassement
/// mémoire, boucle trop longue…
class AsmRuntimeException extends AsmException {
  const AsmRuntimeException(super.message, {super.line});
}

/// Suggère le nom de registre valide le plus proche (distance de
/// Levenshtein) afin de produire des messages du type :
/// « Le registre RXA n'existe pas. Vouliez-vous écrire RAX ? »
String? suggestClosestName(String input, Iterable<String> validNames) {
  String? best;
  int bestDistance = 999;
  for (final candidate in validNames) {
    final d = _levenshtein(input.toUpperCase(), candidate.toUpperCase());
    if (d < bestDistance) {
      bestDistance = d;
      best = candidate;
    }
  }
  if (best != null && bestDistance <= 2) return best;
  return null;
}

int _levenshtein(String a, String b) {
  final la = a.length;
  final lb = b.length;
  if (la == 0) return lb;
  if (lb == 0) return la;
  final matrix = List.generate(la + 1, (_) => List<int>.filled(lb + 1, 0));
  for (var i = 0; i <= la; i++) {
    matrix[i][0] = i;
  }
  for (var j = 0; j <= lb; j++) {
    matrix[0][j] = j;
  }
  for (var i = 1; i <= la; i++) {
    for (var j = 1; j <= lb; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost,
      ].reduce((v, e) => v < e ? v : e);
    }
  }
  return matrix[la][lb];
}
