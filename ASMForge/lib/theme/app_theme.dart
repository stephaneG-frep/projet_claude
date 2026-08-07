import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Niveau de contraste choisi par l'utilisateur dans les paramètres.
enum AppContrast { normal, high }

/// Construit le [ThemeData] unique de l'application (Material 3).
/// Toute variation visuelle (contraste, taille de texte) passe par ici.
class AppTheme {
  AppTheme._();

  static ThemeData dark({
    AppContrast contrast = AppContrast.normal,
    double textScale = 1.0,
  }) {
    final bool high = contrast == AppContrast.high;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cyan,
      brightness: Brightness.dark,
      primary: AppColors.cyan,
      secondary: AppColors.violet,
      surface: AppColors.surface,
      error: AppColors.errorRed,
    );

    final Color onSurface = high ? Colors.white : AppColors.textPrimary;
    final Color onSurfaceMuted =
        high ? const Color(0xFFE3E8F5) : AppColors.textSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme.copyWith(
        surface: AppColors.surface,
        onSurface: onSurface,
      ),
      fontFamily: 'monospace',
      textTheme: _textTheme(onSurface, onSurfaceMuted, textScale),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: high ? AppColors.cyan.withValues(alpha: 0.4) : Colors.white10,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.cyan.withValues(alpha: 0.2),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: onSurface, fontSize: 12),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.cyan.withValues(alpha: 0.2),
        selectedLabelTextStyle: TextStyle(color: onSurface),
        unselectedLabelTextStyle: TextStyle(color: onSurfaceMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dividerColor: Colors.white12,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.cyan,
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary, double scale) {
    TextStyle base(double size, {FontWeight? weight, Color? color}) =>
        TextStyle(
          fontSize: size * scale,
          fontWeight: weight,
          color: color ?? primary,
        );
    return TextTheme(
      displayLarge: base(40, weight: FontWeight.bold),
      headlineMedium: base(26, weight: FontWeight.bold),
      titleLarge: base(20, weight: FontWeight.w600),
      titleMedium: base(16, weight: FontWeight.w600),
      bodyLarge: base(16),
      bodyMedium: base(14, color: secondary),
      labelLarge: base(14, weight: FontWeight.w600),
    );
  }
}

/// Couleurs sémantiques utilisées par le simulateur (registres, flags…),
/// exposées séparément pour rester centralisées et réutilisables.
class SimColors {
  SimColors._();
  static const Color registerChanged = AppColors.executionGreen;
  static const Color flagSet = AppColors.executionGreen;
  static const Color flagUnset = AppColors.textSecondary;
  static const Color pointer = AppColors.orange;
  static const Color error = AppColors.errorRed;
}
