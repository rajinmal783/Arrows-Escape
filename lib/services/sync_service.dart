import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';
import '../models/level_progress.dart';
import '../models/user_profile.dart';

class SyncService {
  final LocalStorageService _local;
  final SupabaseService _supabase;

  SyncService(this._local, this._supabase);

  /// Synchronizes local offline progress, profile stats, inventory, and settings with Supabase.
  Future<void> syncAll() async {
    final user = _supabase.currentUser;
    if (user == null) return;

    try {
      debugPrint('Starting full cloud sync for user ${user.id}...');

      // 1. Sync Level Progress
      await _syncLevelProgress(user.id);

      // 2. Sync User Profile & Inventory
      await _syncUserProfileAndInventory(user.id, user);

      // 3. Sync User Settings
      await _syncUserSettings(user.id);

      // 4. Clear pending sync queue once merged
      await _local.clearSyncQueue();
      debugPrint('Sync completed successfully.');
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  Future<void> _syncLevelProgress(String userId) async {
    final cloudRecords = await _supabase.fetchCloudProgress(userId);
    final localRecords = _local.loadAllProgress(userId: userId);

    final cloudMap = {for (var p in cloudRecords) p.levelId: p};
    final localMap = {for (var p in localRecords) p.levelId: p};

    final allLevelIds = {...cloudMap.keys, ...localMap.keys};

    for (final id in allLevelIds) {
      final local = localMap[id];
      final cloud = cloudMap[id];

      if (local != null && cloud != null) {
        final merged = LevelProgress(
          levelId: id,
          completed: local.completed || cloud.completed,
          stars: local.stars > cloud.stars ? local.stars : cloud.stars,
          bestScore: local.bestScore > cloud.bestScore ? local.bestScore : cloud.bestScore,
          bestMoves: (local.bestMoves != null && cloud.bestMoves != null)
              ? (local.bestMoves! < cloud.bestMoves! ? local.bestMoves : cloud.bestMoves)
              : (local.bestMoves ?? cloud.bestMoves),
          attempts: (local.attempts > cloud.attempts ? local.attempts : cloud.attempts),
          hintsUsed: (local.hintsUsed > cloud.hintsUsed ? local.hintsUsed : cloud.hintsUsed),
          completedAt: local.completedAt ?? cloud.completedAt,
        );
        await _local.saveProgress(merged, userId: userId);
        await _supabase.upsertLevelProgress(userId, merged);
      } else if (local != null) {
        await _supabase.upsertLevelProgress(userId, local);
      } else if (cloud != null) {
        await _local.saveProgress(cloud, userId: userId);
      }
    }
  }

  Future<void> _syncUserProfileAndInventory(String userId, dynamic user) async {
    final cloudProfile = await _supabase.fetchProfile(userId);
    final localProfile = _local.loadProfile(userId: userId);

    final metaName = (user.userMetadata?['full_name'] as String?) ??
        (user.userMetadata?['name'] as String?) ??
        (user.userMetadata?['user_name'] as String?);
    final metaAvatar = (user.userMetadata?['avatar_url'] as String?) ??
        (user.userMetadata?['picture'] as String?);
    final userEmail = user.email as String?;

    if (cloudProfile != null) {
      final merged = UserProfile(
        id: userId,
        username: (cloudProfile.username.isNotEmpty && cloudProfile.username != 'Player')
            ? cloudProfile.username
            : (metaName ?? (localProfile.username.isNotEmpty ? localProfile.username : 'Player')),
        fullName: metaName ?? cloudProfile.fullName ?? localProfile.fullName,
        email: userEmail ?? cloudProfile.email ?? localProfile.email,
        avatarUrl: metaAvatar ?? cloudProfile.avatarUrl ?? localProfile.avatarUrl,
        level: localProfile.level > cloudProfile.level ? localProfile.level : cloudProfile.level,
        xp: localProfile.xp > cloudProfile.xp ? localProfile.xp : cloudProfile.xp,
        coins: localProfile.coins > cloudProfile.coins ? localProfile.coins : cloudProfile.coins,
        totalStars: localProfile.totalStars > cloudProfile.totalStars ? localProfile.totalStars : cloudProfile.totalStars,
        currentStreak: localProfile.currentStreak > cloudProfile.currentStreak ? localProfile.currentStreak : cloudProfile.currentStreak,
        longestStreak: localProfile.longestStreak > cloudProfile.longestStreak ? localProfile.longestStreak : cloudProfile.longestStreak,
        hintsCount: localProfile.hintsCount > cloudProfile.hintsCount ? localProfile.hintsCount : cloudProfile.hintsCount,
        undosCount: localProfile.undosCount > cloudProfile.undosCount ? localProfile.undosCount : cloudProfile.undosCount,
      );
      await _local.saveProfile(merged);
      await _supabase.upsertProfile(merged);
    } else {
      final newProfile = localProfile.copyWith(
        id: userId,
        username: metaName ?? localProfile.username,
        fullName: metaName ?? localProfile.fullName,
        email: userEmail ?? localProfile.email,
        avatarUrl: metaAvatar ?? localProfile.avatarUrl,
      );
      await _local.saveProfile(newProfile);
      await _supabase.upsertProfile(newProfile);
    }
  }

  Future<void> _syncUserSettings(String userId) async {
    final cloudSettings = await _supabase.fetchUserSettings(userId);
    final localSettings = _local.loadSettings();

    if (cloudSettings != null) {
      await _local.saveSettings(cloudSettings);
    } else {
      await _supabase.upsertUserSettings(userId, localSettings);
    }
  }
}
