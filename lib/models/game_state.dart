import 'arrow.dart';
import 'puzzle_level.dart';

class GameState {
  final PuzzleLevel level;
  final List<Arrow> activeArrows;
  final List<Arrow> clearedArrows;
  final int moves;
  final int mistakes;
  final int lives;
  final int maxLives;
  final int hintsRemaining;
  final int undosRemaining;
  final List<List<Arrow>> undoStack;
  final String? hintArrowId;
  final String? blockedArrowId;
  final String? obstructingArrowId;
  final bool isCompleted;
  final bool isFailed;
  final int score;
  final int stars;
  final bool gridVisible;

  const GameState({
    required this.level,
    required this.activeArrows,
    this.clearedArrows = const [],
    this.moves = 0,
    this.mistakes = 0,
    this.lives = 3,
    this.maxLives = 3,
    this.hintsRemaining = 3,
    this.undosRemaining = 3,
    this.undoStack = const [],
    this.hintArrowId,
    this.blockedArrowId,
    this.obstructingArrowId,
    this.isCompleted = false,
    this.isFailed = false,
    this.score = 0,
    this.stars = 0,
    this.gridVisible = false,
  });

  GameState copyWith({
    PuzzleLevel? level,
    List<Arrow>? activeArrows,
    List<Arrow>? clearedArrows,
    int? moves,
    int? mistakes,
    int? lives,
    int? maxLives,
    int? hintsRemaining,
    int? undosRemaining,
    List<List<Arrow>>? undoStack,
    String? hintArrowId,
    String? blockedArrowId,
    String? obstructingArrowId,
    bool? isCompleted,
    bool? isFailed,
    int? score,
    int? stars,
    bool? gridVisible,
    bool clearHint = false,
    bool clearBlocked = false,
  }) {
    return GameState(
      level: level ?? this.level,
      activeArrows: activeArrows ?? this.activeArrows,
      clearedArrows: clearedArrows ?? this.clearedArrows,
      moves: moves ?? this.moves,
      mistakes: mistakes ?? this.mistakes,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      undosRemaining: undosRemaining ?? this.undosRemaining,
      undoStack: undoStack ?? this.undoStack,
      hintArrowId: clearHint ? null : (hintArrowId ?? this.hintArrowId),
      blockedArrowId: clearBlocked ? null : (blockedArrowId ?? this.blockedArrowId),
      obstructingArrowId: clearBlocked ? null : (obstructingArrowId ?? this.obstructingArrowId),
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
      score: score ?? this.score,
      stars: stars ?? this.stars,
      gridVisible: gridVisible ?? this.gridVisible,
    );
  }
}
