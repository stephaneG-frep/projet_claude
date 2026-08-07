// Test de fumée : l'application démarre sans lever d'exception et affiche
// l'écran de démarrage (section 36 : « l'application démarre »).

import 'package:asmforge/app/app.dart';
import 'package:asmforge/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ASMForge démarre et affiche l\'écran de démarrage', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AsmForgeApp(),
      ),
    );

    expect(find.text('ASMForge'), findsOneWidget);
    expect(
      find.text('Comprendre la machine, instruction après instruction.'),
      findsOneWidget,
    );

    // Laisse le minuteur du splash (navigation automatique) s'exécuter et
    // se dissoudre avant la fin du test, sans dépendre du contenu chargé
    // ensuite (qui nécessite les assets, testés séparément).
    await tester.pump(const Duration(seconds: 1));
  });
}
