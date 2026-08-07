import 'package:shared_preferences/shared_preferences.dart';

/// Fine couche au-dessus de `shared_preferences`, choisie car maintenue et
/// compatible avec Android, Web, Linux et Windows (section 29) sans
/// dépendance native supplémentaire à configurer par plateforme.
class LocalStorageService {
  final SharedPreferences _prefs;
  const LocalStorageService(this._prefs);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
