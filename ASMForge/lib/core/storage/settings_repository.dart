import 'dart:convert';

import '../../features/settings/application/app_settings.dart';
import 'local_storage_service.dart';

class SettingsRepository {
  static const _key = 'asmforge_settings_v1';
  final LocalStorageService _storage;
  const SettingsRepository(this._storage);

  AppSettings load() {
    final raw = _storage.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) {
    return _storage.setString(_key, jsonEncode(settings.toJson()));
  }
}
