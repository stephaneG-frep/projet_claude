// Vérifie que Pause interrompt réellement une exécution Run en cours
// (section 11/36), en utilisant de vrais délais (le contrôleur pilote un
// Timer.periodic réel), sans widget ni fausse horloge.
import 'package:asmforge/app/providers.dart';
import 'package:asmforge/features/simulator/application/lab_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Pause arrête la progression du Run et Run ne redémarre pas seul', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(labControllerProvider.notifier);
    notifier.updateSource('''
MOV RAX, 0
boucle:
ADD RAX, 1
JMP boucle
''');

    notifier.run();
    expect(container.read(labControllerProvider).isRunning, isTrue);

    // Laisse s'exécuter quelques pas réels (un pas toutes les 350 ms).
    await Future.delayed(const Duration(milliseconds: 900));
    notifier.pause();

    final afterPause = container.read(labControllerProvider);
    expect(afterPause.isRunning, isFalse);
    final raxAfterPause = afterPause.registers['RAX'];
    expect(raxAfterPause, isNotNull);
    expect(raxAfterPause! > 0, isTrue, reason: 'Au moins un pas doit avoir progressé avant la pause.');

    // Vérifie qu'aucun pas supplémentaire ne se produit après Pause.
    await Future.delayed(const Duration(milliseconds: 900));
    final afterWait = container.read(labControllerProvider);
    expect(afterWait.isRunning, isFalse);
    expect(afterWait.registers['RAX'], raxAfterPause);
  });
}
