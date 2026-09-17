import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';
import '../models/level_progress.dart';

class SyncService {
  final LocalStorageService _local;
  final SupabaseService _supabase;

  SyncService(this._local, this._supabase);

  /// Synchronizes local offline progress with cloud storage.
  Future<void> syncAll() async {
    final user = _supabase.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch cloud progress
      final cloudRecords = await _supabase.fetchCloudProgress(user.id);
      final localRecords = _local.loadAllProgress();

      final cloudMap = {for (var p in cloudRecords) p.levelId: p};
      final localMap = {for (var p in localRecords) p.levelId: p};

      // 2. Merge local and cloud
      final allLevelIds = {...cloudMap.keys, ...localMap.keys};

      for (final id in allLevelIds) {
        final local = localMap[id];
        final cloud = cloudMap[id];

        if (local != null && cloud != null) {
          // Take the better record
          final merged = LevelProgress(
            levelId: id,
            completed: local.completed || cloud.completed,
            stars: local.stars > cloud.stars ? local.stars : cloud.stars,
            bestScore: local.bestScore > cloud.bestScore ? local.bestScore : cloud.bestScore,
            attempts: (local.attempts > cloud.attempts ? local.attempts : cloud.attempts),
          );
          await _local.saveProgress(merged);
          await _supabase.upsertLevelProgress(user.id, merged);
        } else if (local != null) {
          // Push to cloud
          await _supabase.upsertLevelProgress(user.id, local);
        } else if (cloud != null) {
          // Pull to local
          await _local.saveProgress(cloud);
        }
      }

      // 3. Clear pending sync queue once merged
      await _local.clearSyncQueue();
      debugPrint('Sync completed successfully.');
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
}
