// Test d'intégration exécuté sur un véritable appareil : vérifie le
// parcours réel (onboarding → navigation → Laboratoire → Run/Step/Reset)
// plutôt que de se limiter à une lecture statique du code (section 36).
import 'package:asmforge/app/app.dart';
import 'package:asmforge/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parcours complet : onboarding, navigation, Run/Step/Reset', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AsmForgeApp(),
      ),
    );

    // Splash → Onboarding
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Passer'), findsOneWidget);

    // Passe directement au choix de niveau, puis entre dans l'application.
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(find.text('ENTRER DANS LA FORGE'), findsOneWidget);

    await tester.tap(find.text('Je débute complètement'));
    await tester.pump();
    await tester.tap(find.text('ENTRER DANS LA FORGE'));
    await tester.pumpAndSettle();

    // Dashboard (Accueil) atteint.
    expect(find.text('ASMForge'), findsWidgets);

    // Navigation réelle vers le Laboratoire.
    await tester.tap(find.text('Laboratoire').first);
    await tester.pumpAndSettle();
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Step'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // État initial : RAX à 0 avant toute exécution.
    expect(find.byKey(const ValueKey('register_value_RAX')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('register_value_RAX'))).data,
      '0',
    );

    // RUN : exécute le programme par défaut (MOV/MOV/ADD -> RAX = 8).
    await tester.tap(find.widgetWithText(FilledButton, 'Run'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('register_value_RAX'))).data,
      '8',
      reason: 'Après Run, RAX doit valoir 8 (5 + 3).',
    );

    // RESET : le processeur revient à zéro, le code reste.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('register_value_RAX'))).data,
      '0',
      reason: 'Après Reset, RAX doit revenir à 0.',
    );

    // STEP : exécute pas à pas, en surveillant la progression réelle.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Step'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('register_value_RAX'))).data,
      '5',
      reason: 'Après le premier Step (MOV RAX, 5), RAX doit valoir 5.',
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Step'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Step'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('register_value_RAX'))).data,
      '8',
      reason: 'Après le troisième Step (ADD RAX, RBX), RAX doit valoir 8.',
    );
  });
}
