import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';
import 'auth_provider.dart';
import '../models/level_progress.dart';

class LevelProgressState {
  final Map<int, LevelProgress> progressMap;
  final int highestUnlockedLevel;
  final int totalStars;

  const LevelProgressState({
    required this.progressMap,
    this.highestUnlockedLevel = 1,
    this.totalStars = 0,
  });

  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    return levelId <= highestUnlockedLevel;
  }

  LevelProgress? getProgress(int levelId) => progressMap[levelId];
}

class LevelProgressNotifier extends StateNotifier<LevelProgressState> {
  final Ref _ref;

  LevelProgressNotifier(this._ref)
      : super(const LevelProgressState(progressMap: {})) {
    loadProgress();
    
    // Sync when user logs in or reset when guest
    _ref.listen(authProvider, (previous, next) {
      if (next.user != null && previous?.user?.id != next.user!.id) {
        _ref.read(syncServiceProvider).syncAll().then((_) => loadProgress());
      } else if (next.user == null) {
        resetToLevelOne();
      }
    });
  }

  void loadProgress() {
    final auth = _ref.read(authProvider);
    if (auth.user == null) {
      // Guest always starts at Level 1 with 0 saved history
      resetToLevelOne();
      return;
    }

    final storage = _ref.read(localStorageProvider);
    final all = storage.loadAllProgress(userId: auth.user!.id);
    final map = {for (var p in all) p.levelId: p};

    int maxUnlocked = 1;
    int starsCount = 0;
    for (final p in all) {
      if (p.completed) {
        starsCount += p.stars;
      }
    }

    // Minimum 2-Star Rule: Level L unlocks L+1 iff Level L is completed with >= 2 stars
    while (true) {
      final p = map[maxUnlocked];
      if (p != null && p.completed && p.stars >= 2) {
        maxUnlocked++;
      } else {
        break;
      }
    }

    state = LevelProgressState(
      progressMap: map,
      highestUnlockedLevel: maxUnlocked,
      totalStars: starsCount,
    );
  }

  void resetToLevelOne() {
    state = const LevelProgressState(
      progressMap: {},
      highestUnlockedLevel: 1,
      totalStars: 0,
    );
  }

  Future<void> recordLevelCompletion({
    required int levelId,
    required int stars,
    required int score,
    required int moves,
    required int hintsUsed,
  }) async {
    final existing = state.progressMap[levelId];
    final newStars = existing != null && existing.stars > stars ? existing.stars : stars;
    final newBestScore = existing != null && existing.bestScore > score ? existing.bestScore : score;
    final newBestMoves = existing != null && existing.bestMoves != null && existing.bestMoves! < moves
        ? existing.bestMoves
        : moves;

    final progress = LevelProgress(
      levelId: levelId,
      completed: true,
      stars: newStars,
      bestScore: newBestScore,
      bestMoves: newBestMoves,
      attempts: (existing?.attempts ?? 0) + 1,
      hintsUsed: (existing?.hintsUsed ?? 0) + hintsUsed,
      completedAt: DateTime.now(),
    );

    // Update in-memory state so user or guest can progress to the next level
    final newMap = Map<int, LevelProgress>.from(state.progressMap)..[levelId] = progress;
    
    // Minimum 2-Star Rule: Calculate sequentially unlocked levels
    int newUnlocked = 1;
    while (true) {
      final p = newMap[newUnlocked];
      if (p != null && p.completed && p.stars >= 2) {
        newUnlocked++;
      } else {
        break;
      }
    }

    int newTotalStars = 0;
    for (final p in newMap.values) {
      newTotalStars += p.stars;
    }

    state = LevelProgressState(
      progressMap: newMap,
      highestUnlockedLevel: newUnlocked,
      totalStars: newTotalStars,
    );

    // Persist to storage and Supabase Cloud ONLY for authenticated Google users
    final auth = _ref.read(authProvider);
    if (auth.user != null) {
      final storage = _ref.read(localStorageProvider);
      await storage.saveProgress(progress, userId: auth.user!.id);
      await _ref.read(supabaseServiceProvider).upsertLevelProgress(auth.user!.id, progress);
      await _ref.read(supabaseServiceProvider).updateLeaderboardScore(
        userId: auth.user!.id,
        periodType: 'all_time',
        periodKey: 'global',
        score: newTotalStars * 1000,
        stars: newTotalStars,
      );
    }
  }
}

final levelProgressProvider = StateNotifierProvider<LevelProgressNotifier, LevelProgressState>((ref) {
  return LevelProgressNotifier(ref);
});
