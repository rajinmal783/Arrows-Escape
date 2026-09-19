import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/level_progress.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  String _keyWithUser(String baseKey, String? userId) {
    if (userId == null || userId.isEmpty || userId == 'guest' || userId == 'guest_user') {
      return '${baseKey}_guest';
    }
    return '${baseKey}_$userId';
  }

  // --- Level Progress ---
  List<LevelProgress> loadAllProgress({String? userId}) {
    if (userId == 'guest' || userId == 'guest_user') {
      return [];
    }
    final key = _keyWithUser(AppConstants.keyUserProgress, userId);
    final raw = _prefs.getString(key) ?? (userId != null ? null : _prefs.getString(AppConstants.keyUserProgress));
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) => LevelProgress.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProgress(LevelProgress progress, {String? userId}) async {
    // Guest progress is NOT saved permanently (always resets to Level 1 on new session)
    if (userId == null || userId == 'guest' || userId == 'guest_user') {
      return;
    }

    final key = _keyWithUser(AppConstants.keyUserProgress, userId);
    final all = loadAllProgress(userId: userId);
    final index = all.indexWhere((p) => p.levelId == progress.levelId);
    if (index >= 0) {
      all[index] = progress;
    } else {
      all.add(progress);
    }
    await _prefs.setString(
      key,
      jsonEncode(all.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> clearGuestData() async {
    await _prefs.remove('${AppConstants.keyUserProgress}_guest');
    await _prefs.remove(AppConstants.keyUserProgress);
    await _prefs.remove('${AppConstants.keyCachedProfile}_guest');
  }

  LevelProgress? getProgress(int levelId, {String? userId}) {
    final all = loadAllProgress(userId: userId);
    final index = all.indexWhere((p) => p.levelId == levelId);
    return index >= 0 ? all[index] : null;
  }

  // --- Profile ---
  UserProfile loadProfile({String? userId}) {
    if (userId == 'guest' || userId == 'guest_user') {
      return const UserProfile(
        id: 'guest',
        username: 'Guest Player',
        coins: 100,
        level: 1,
        xp: 0,
      );
    }
    final key = _keyWithUser(AppConstants.keyCachedProfile, userId);
    final raw = _prefs.getString(key) ?? (userId != null ? null : _prefs.getString(AppConstants.keyCachedProfile));
    if (raw == null || raw.isEmpty) {
      return const UserProfile(
        id: 'guest',
        username: 'Guest Player',
        coins: 100,
        level: 1,
        xp: 0,
      );
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile(id: 'guest', username: 'Guest Player');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    if (profile.id == 'guest' || profile.id == 'guest_user') {
      return;
    }
    final key = _keyWithUser(AppConstants.keyCachedProfile, profile.id);
    await _prefs.setString(
      key,
      jsonEncode(profile.toJson()),
    );
  }

  // --- Settings ---
  UserSettings loadSettings() {
    final raw = _prefs.getString(AppConstants.keyUserSettings);
    if (raw == null || raw.isEmpty) return const UserSettings();
    try {
      return UserSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserSettings();
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _prefs.setString(
      AppConstants.keyUserSettings,
      jsonEncode(settings.toJson()),
    );
  }

  // --- Offline Sync Queue ---
  List<Map<String, dynamic>> loadSyncQueue() {
    final raw = _prefs.getString(AppConstants.keyOfflineSyncQueue);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> enqueueSync(Map<String, dynamic> item) async {
    final queue = loadSyncQueue();
    queue.add(item);
    await _prefs.setString(AppConstants.keyOfflineSyncQueue, jsonEncode(queue));
  }

  Future<void> clearSyncQueue() async {
    await _prefs.remove(AppConstants.keyOfflineSyncQueue);
  }

  // --- Theme & Cosmetics ---
  String getActiveTheme() {
    return _prefs.getString(AppConstants.keyActiveTheme) ?? 'classic';
  }

  Future<void> setActiveTheme(String themeKey) async {
    await _prefs.setString(AppConstants.keyActiveTheme, themeKey);
  }

  List<String> getUnlockedThemes() {
    final list = _prefs.getStringList(AppConstants.keyUnlockedThemes);
    return list ?? ['classic'];
  }

  Future<void> unlockTheme(String themeKey) async {
    final list = getUnlockedThemes();
    if (!list.contains(themeKey)) {
      list.add(themeKey);
      await _prefs.setStringList(AppConstants.keyUnlockedThemes, list);
    }
  }
}
