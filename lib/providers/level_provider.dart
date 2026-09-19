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
    
    // Sync when user logs in
    _ref.listen(authProvider, (previous, next) {
      if (next.user != null && previous?.user?.id != next.user!.id) {
        _ref.read(syncServiceProvider).syncAll().then((_) => loadProgress());
      }
    });
  }

  void loadProgress() {
    final storage = _ref.read(localStorageProvider);
    final all = storage.loadAllProgress();
    final map = {for (var p in all) p.levelId: p};

    int maxUnlocked = 1;
    int starsCount = 0;
    for (final p in all) {
      if (p.completed) {
        starsCount += p.stars;
        if (p.levelId + 1 > maxUnlocked) {
          maxUnlocked = p.levelId + 1;
        }
      }
    }

    state = LevelProgressState(
      progressMap: map,
      highestUnlockedLevel: maxUnlocked,
      totalStars: starsCount,
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

    // Save locally
    final storage = _ref.read(localStorageProvider);
    await storage.saveProgress(progress);

    // Update state
    final newMap = Map<int, LevelProgress>.from(state.progressMap)..[levelId] = progress;
    final newUnlocked = levelId + 1 > state.highestUnlockedLevel ? levelId + 1 : state.highestUnlockedLevel;
    int newTotalStars = 0;
    for (final p in newMap.values) {
      newTotalStars += p.stars;
    }

    state = LevelProgressState(
      progressMap: newMap,
      highestUnlockedLevel: newUnlocked,
      totalStars: newTotalStars,
    );

    // Push to Supabase if logged in
    final auth = _ref.read(authProvider);
    if (auth.user != null) {
      await _ref.read(supabaseServiceProvider).upsertLevelProgress(auth.user!.id, progress);
    }
  }
}

final levelProgressProvider = StateNotifierProvider<LevelProgressNotifier, LevelProgressState>((ref) {
  return LevelProgressNotifier(ref);
});
