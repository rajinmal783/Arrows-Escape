import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';
import 'auth_provider.dart';
import '../models/user_settings.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const UserSettings()) {
    _load();
  }

  void _load() {
    final storage = _ref.read(localStorageProvider);
    state = storage.loadSettings();
  }

  Future<void> toggleSound() async {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    await _save();
  }

  Future<void> toggleMusic() async {
    state = state.copyWith(musicEnabled: !state.musicEnabled);
    await _save();
  }

  Future<void> toggleVibration() async {
    state = state.copyWith(vibrationEnabled: !state.vibrationEnabled);
    await _save();
  }

  Future<void> toggleGrid() async {
    state = state.copyWith(gridEnabled: !state.gridEnabled);
    await _save();
  }

  Future<void> setTheme(String theme) async {
    state = state.copyWith(theme: theme);
    await _save();
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    await _save();
  }

  Future<void> _save() async {
    final storage = _ref.read(localStorageProvider);
    await storage.saveSettings(state);

    final auth = _ref.read(authProvider);
    if (auth.user != null) {
      await _ref.read(supabaseServiceProvider).upsertUserSettings(auth.user!.id, state);
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier(ref);
});

final activeCosmeticThemeProvider = StateNotifierProvider<ActiveCosmeticThemeNotifier, String>((ref) {
  return ActiveCosmeticThemeNotifier(ref);
});

class ActiveCosmeticThemeNotifier extends StateNotifier<String> {
  final Ref _ref;

  ActiveCosmeticThemeNotifier(this._ref) : super('classic') {
    state = _ref.read(localStorageProvider).getActiveTheme();
  }

  Future<void> setTheme(String themeKey) async {
    state = themeKey;
    await _ref.read(localStorageProvider).setActiveTheme(themeKey);
  }
}
