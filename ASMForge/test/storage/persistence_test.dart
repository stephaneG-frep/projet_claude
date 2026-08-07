// Vérifie que la progression et les paramètres sont réellement persistés
// et relus depuis le stockage local (section 27/29), pas seulement gardés
// en mémoire le temps d'une session.
import 'package:asmforge/core/storage/local_storage_service.dart';
import 'package:asmforge/core/storage/progress_repository.dart';
import 'package:asmforge/core/storage/settings_repository.dart';
import 'package:asmforge/features/progress/domain/user_progress.dart';
import 'package:asmforge/features/settings/application/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('la progression sauvegardée est intégralement relue', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final repo = ProgressRepository(storage);

    final progress = const UserProgress().copyWith(
      completedLessons: {'m0_l1', 'm0_l2'},
      completedMissions: {'mission_01'},
      xp: 140,
      unlockedBadges: {'premier_bit'},
    );
    await repo.save(progress);

    // Nouvelle instance de dépôt (simule un redémarrage de l'application).
    final reloaded = ProgressRepository(storage).load();
    expect(reloaded.completedLessons, {'m0_l1', 'm0_l2'});
    expect(reloaded.completedMissions, {'mission_01'});
    expect(reloaded.xp, 140);
    expect(reloaded.unlockedBadges, {'premier_bit'});
  });

  test('la réinitialisation efface bien la progression persistée', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final repo = ProgressRepository(storage);
    await repo.save(const UserProgress().copyWith(xp: 500));

    await repo.reset();

    expect(repo.load().xp, 0);
  });

  test('les paramètres sauvegardés sont intégralement relus', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final repo = SettingsRepository(storage);

    await repo.save(const AppSettings(
      animationsEnabled: false,
      textScale: 1.3,
      assistanceLevel: AssistanceLevel.expert,
    ));

    final reloaded = SettingsRepository(storage).load();
    expect(reloaded.animationsEnabled, isFalse);
    expect(reloaded.textScale, 1.3);
    expect(reloaded.assistanceLevel, AssistanceLevel.expert);
  });
}
