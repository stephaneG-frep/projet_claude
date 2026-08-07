import 'dart:convert';

import '../../features/progress/domain/user_progress.dart';
import 'local_storage_service.dart';

class ProgressRepository {
  static const _key = 'asmforge_progress_v1';
  final LocalStorageService _storage;
  const ProgressRepository(this._storage);

  UserProgress load() {
    final raw = _storage.getString(_key);
    if (raw == null) return const UserProgress();
    try {
      return UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> save(UserProgress progress) {
    return _storage.setString(_key, jsonEncode(progress.toJson()));
  }

  Future<void> reset() => _storage.remove(_key);
}
