import 'package:flutter/material.dart';

import '../../../core/simulator/opcode.dart';
import '../../../core/simulator/register_bank.dart';
import '../../../theme/app_colors.dart';

final Set<String> _mnemonics = Opcode.values.map((o) => o.mnemonic).toSet();

/// Contrôleur de texte avec coloration syntaxique légère, sans dépendance
/// externe (évite les risques de compatibilité d'un package tiers de
/// coloration de code pour un besoin aussi ciblé).
class AsmSyntaxController extends TextEditingController {
  AsmSyntaxController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = style ?? const TextStyle();
    final lines = text.split('\n');
    final spans = <TextSpan>[];

    for (var i = 0; i < lines.length; i++) {
      spans.addAll(_highlightLine(lines[i], base));
      if (i != lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return TextSpan(style: base, children: spans);
  }

  List<TextSpan> _highlightLine(String line, TextStyle base) {
    final commentIndex = line.indexOf(';');
    final code = commentIndex == -1 ? line : line.substring(0, commentIndex);
    final comment = commentIndex == -1 ? '' : line.substring(commentIndex);

    final spans = <TextSpan>[];
    final wordPattern = RegExp(r'([A-Za-z_][A-Za-z0-9_]*|\S)');
    var cursor = 0;
    for (final match in wordPattern.allMatches(code)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: code.substring(cursor, match.start), style: base));
      }
      final word = match.group(0)!;
      spans.add(TextSpan(text: word, style: base.merge(_styleFor(word, code, match.start))));
      cursor = match.end;
    }
    if (cursor < code.length) {
      spans.add(TextSpan(text: code.substring(cursor), style: base));
    }
    if (comment.isNotEmpty) {
      spans.add(TextSpan(
        text: comment,
        style: base.copyWith(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ));
    }
    return spans;
  }

  TextStyle _styleFor(String word, String fullLine, int start) {
    final isLabel = fullLine.substring(start).trimLeft().startsWith(
              RegExp('^${RegExp.escape(word)}\\s*:'),
            ) &&
        fullLine.trimLeft().startsWith(word);
    if (isLabel) {
      return const TextStyle(color: AppColors.violet, fontWeight: FontWeight.bold);
    }
    if (_mnemonics.contains(word.toUpperCase()) &&
        fullLine.trimLeft().toUpperCase().startsWith(word.toUpperCase())) {
      return const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold);
    }
    if (RegisterBank.isValid(word)) {
      return const TextStyle(color: AppColors.orange);
    }
    if (RegExp(r'^-?(0x[0-9A-Fa-f]+|\d+)$').hasMatch(word)) {
      return const TextStyle(color: AppColors.executionGreen);
    }
    return const TextStyle(color: AppColors.textPrimary);
  }
}
