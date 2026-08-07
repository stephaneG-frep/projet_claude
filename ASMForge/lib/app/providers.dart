import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/content_repository.dart';
import '../core/storage/local_storage_service.dart';
import '../core/storage/progress_repository.dart';
import '../core/storage/settings_repository.dart';
import '../features/settings/application/export_import_service.dart';

/// Fourni via `overrideWithValue` dans `main.dart` une fois
/// `SharedPreferences.getInstance()` résolu.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider doit être surchargé dans main() avant '
    'runApp().',
  );
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(localStorageServiceProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(localStorageServiceProvider));
});

final exportImportServiceProvider = Provider<ExportImportService>((ref) {
  return ExportImportService(
    ref.watch(progressRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});
