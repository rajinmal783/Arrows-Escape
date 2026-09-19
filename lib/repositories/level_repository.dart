import '../models/puzzle_level.dart';
import '../game/level_generator.dart';
import '../core/constants/app_constants.dart';

class LevelRepository {
  final Map<int, PuzzleLevel> _levelCache = {};

  /// Retrieves level [levelId] (1 to 500+)
  Future<PuzzleLevel> getLevel(int levelId) async {
    if (_levelCache.containsKey(levelId)) {
      return _levelCache[levelId]!;
    }

    // Generate deterministically and cache in-memory
    final level = LevelGenerator.generateLevel(levelId);
    _levelCache[levelId] = level;
    return level;
  }

  /// Generates the daily challenge puzzle based on the date seed
  Future<PuzzleLevel> getDailyChallengeLevel(DateTime date) async {
    final dateKey = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final seed = int.parse(dateKey);
    final dailyLevelId = 999000 + (seed % 1000);

    if (_levelCache.containsKey(dailyLevelId)) {
      return _levelCache[dailyLevelId]!;
    }

    final level = LevelGenerator.generateLevel(dailyLevelId);
    _levelCache[dailyLevelId] = level;
    return level;
  }

  int get totalLevelsCount => AppConstants.totalLevels;
}
