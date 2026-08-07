import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/storage/settings_repository.dart';
import 'app_settings.dart';

class SettingsController extends Notifier<AppSettings> {
  late final SettingsRepository _repository;

  @override
  AppSettings build() {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.load();
  }

  void _update(AppSettings Function(AppSettings) transform) {
    state = transform(state);
    _repository.save(state);
  }

  void setAnimationsEnabled(bool value) =>
      _update((s) => s.copyWith(animationsEnabled: value));

  void setSoundEnabled(bool value) =>
      _update((s) => s.copyWith(soundEnabled: value));

  void setVibrationEnabled(bool value) =>
      _update((s) => s.copyWith(vibrationEnabled: value));

  void setTextScale(double value) =>
      _update((s) => s.copyWith(textScale: value));

  void setHighContrast(bool value) =>
      _update((s) => s.copyWith(highContrast: value));

  void setAssistanceLevel(AssistanceLevel level) =>
      _update((s) => s.copyWith(assistanceLevel: level));

  void reloadFromStorage() => state = _repository.load();
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
