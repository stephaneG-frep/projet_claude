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
    await tester.tap(find.text('Labo').first);
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

    // PAYSAGE : bascule l'orientation simulée et vérifie l'absence de
    // débordement (RenderFlex overflow) sur le Laboratoire, qui empile
    // éditeur + panneaux dans un seul défilement en largeur étroite.
    final originalSize = tester.view.physicalSize;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = Size(originalSize.height, originalSize.width);
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isNull,
      reason: 'Aucun débordement ne doit apparaître sur le Laboratoire en paysage.',
    );

    // Retour en portrait avant de continuer la navigation.
    tester.view.physicalSize = originalSize;
    await tester.pumpAndSettle();

    // Navigation vers le Profil : vérifie que Statistiques s'affiche sans
    // débordement, y compris avec le libellé le plus long (« Temps
    // d'apprentissage »).
    await tester.tap(find.text('Profil').first);
    await tester.pumpAndSettle();
    expect(find.text('Statistiques'), findsOneWidget);
    expect(find.text('Temps d\'apprentissage'), findsOneWidget);
    expect(
      tester.takeException(),
      isNull,
      reason: 'Aucun débordement ne doit apparaître dans Profil > Statistiques.',
    );

    // Rejoue aussi le paysage sur le Profil, pour la même raison.
    tester.view.physicalSize = Size(originalSize.height, originalSize.width);
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isNull,
      reason: 'Aucun débordement ne doit apparaître dans Profil en paysage.',
    );
    tester.view.physicalSize = originalSize;
    await tester.pumpAndSettle();

    // Paramètres : vérifie le SegmentedButton Guidé/Standard/Expert, qui
    // ne rétrécit jamais ses segments en dessous de leur largeur
    // naturelle et peut déborder sur un écran étroit. Le lien est en bas
    // de la liste du Profil : on la fait défiler à partir d'un point de
    // l'écran plutôt que d'un widget (plusieurs Scrollable coexistent
    // dans l'arbre car les onglets restent montés, ce qui rend les
    // finders par widget ambigus ou instables après défilement).
    final screenCenter = Offset(
      originalSize.width / tester.view.devicePixelRatio / 2,
      originalSize.height / tester.view.devicePixelRatio / 2,
    );
    for (var i = 0; i < 6 && find.text('Paramètres').evaluate().isEmpty; i++) {
      await tester.dragFrom(screenCenter, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(find.text('Paramètres'), findsOneWidget);
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();
    expect(find.text('Standard'), findsOneWidget);
    expect(
      tester.takeException(),
      isNull,
      reason: 'Aucun débordement ne doit apparaître dans Paramètres (niveau d\'assistance).',
    );

    tester.view.physicalSize = Size(originalSize.height, originalSize.width);
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isNull,
      reason: 'Aucun débordement ne doit apparaître dans Paramètres en paysage.',
    );
    tester.view.physicalSize = originalSize;
    await tester.pumpAndSettle();
  });
}
