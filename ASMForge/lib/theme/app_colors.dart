import 'package:flutter/material.dart';

/// Palette centralisée de The Forge — ASMForge.
/// Toutes les couleurs de l'application doivent provenir d'ici,
/// jamais d'une valeur codée en dur dans un widget.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF090E1A);
  static const Color surface = Color(0xFF131C2E);
  static const Color surfaceSecondary = Color(0xFF1B263B);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color executionGreen = Color(0xFF3DFF9A);
  static const Color orange = Color(0xFFFFB454);
  static const Color errorRed = Color(0xFFFF5D73);

  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textSecondary = Color(0xFFAAB6CC);

  // Palette claire (haute lisibilité), utilisée en option de contraste
  // renforcé ou par un futur thème clair.
  static const Color backgroundLight = Color(0xFFF6F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFE9EEF7);
  static const Color textPrimaryLight = Color(0xFF0B1220);
  static const Color textSecondaryLight = Color(0xFF44506A);
}
