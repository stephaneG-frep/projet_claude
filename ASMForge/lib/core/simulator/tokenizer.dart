/// Une ligne source découpée en éléments exploitables par le parser.
class SourceLine {
  final int lineNumber;
  final String raw;
  final String? label;
  final String? mnemonic;
  final List<String> operandText;

  const SourceLine({
    required this.lineNumber,
    required this.raw,
    this.label,
    this.mnemonic,
    this.operandText = const [],
  });

  bool get isEmpty => label == null && mnemonic == null;
}

/// Découpe un programme assembleur pédagogique en [SourceLine].
///
/// Gère : commentaires `;`, étiquettes `nom:`, mnémonique + opérandes
/// séparés par des virgules. Les directives NASM (`section`, `global`…)
/// sont ignorées silencieusement si présentes, car le simulateur cible un
/// sous-ensemble exécutable simplifié (voir docs/SIMULATOR.md).
class Tokenizer {
  static const _ignoredDirectives = {
    'section',
    'global',
    'extern',
    'bits',
    'default',
  };

  List<SourceLine> tokenize(String source) {
    final lines = source.split('\n');
    final result = <SourceLine>[];

    for (var i = 0; i < lines.length; i++) {
      final lineNumber = i + 1;
      var content = lines[i];

      final commentIndex = content.indexOf(';');
      if (commentIndex != -1) {
        content = content.substring(0, commentIndex);
      }
      content = content.trim();

      if (content.isEmpty) {
        result.add(SourceLine(lineNumber: lineNumber, raw: lines[i]));
        continue;
      }

      String? label;
      if (content.contains(':')) {
        final parts = content.split(':');
        label = parts.first.trim();
        content = parts.sublist(1).join(':').trim();
      }

      if (content.isEmpty) {
        result.add(
          SourceLine(lineNumber: lineNumber, raw: lines[i], label: label),
        );
        continue;
      }

      final firstSpace = content.indexOf(RegExp(r'\s'));
      String mnemonicWord;
      String remainder;
      if (firstSpace == -1) {
        mnemonicWord = content;
        remainder = '';
      } else {
        mnemonicWord = content.substring(0, firstSpace);
        remainder = content.substring(firstSpace + 1).trim();
      }

      if (_ignoredDirectives.contains(mnemonicWord.toLowerCase())) {
        result.add(
          SourceLine(lineNumber: lineNumber, raw: lines[i], label: label),
        );
        continue;
      }

      final operandText = remainder.isEmpty
          ? <String>[]
          : _splitOperands(remainder);

      result.add(
        SourceLine(
          lineNumber: lineNumber,
          raw: lines[i],
          label: label,
          mnemonic: mnemonicWord,
          operandText: operandText,
        ),
      );
    }
    return result;
  }

  List<String> _splitOperands(String text) {
    final operands = <String>[];
    final buffer = StringBuffer();
    var depth = 0;
    for (final ch in text.split('')) {
      if (ch == '[') depth++;
      if (ch == ']') depth--;
      if (ch == ',' && depth == 0) {
        operands.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    if (buffer.toString().trim().isNotEmpty) {
      operands.add(buffer.toString().trim());
    }
    return operands;
  }
}
