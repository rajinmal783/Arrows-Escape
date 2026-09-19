import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/arrow.dart';
import '../models/puzzle_level.dart';
import '../models/game_state.dart';
import '../game/move_validator.dart';
import 'storage_provider.dart';
import 'level_provider.dart';
import 'profile_provider.dart';

class GameNotifier extends StateNotifier<GameState?> {
  final Ref _ref;

  GameNotifier(this._ref) : super(null);

  Future<void> loadLevel(int levelId) async {
    final repo = _ref.read(levelRepositoryProvider);
    final level = await repo.getLevel(levelId);
    _startLevel(level);
  }

  Future<void> loadDailyChallenge(DateTime date) async {
    final repo = _ref.read(levelRepositoryProvider);
    final level = await repo.getDailyChallengeLevel(date);
    _startLevel(level);
  }

  void _startLevel(PuzzleLevel level) {
    final profile = _ref.read(profileProvider);
    state = GameState(
      level: level,
      activeArrows: List<Arrow>.from(level.arrows),
      clearedArrows: [],
      moves: 0,
      mistakes: 0,
      lives: 3,
      hintsRemaining: profile.hintsCount,
      undosRemaining: profile.undosCount,
      undoStack: [],
      isCompleted: false,
      isFailed: false,
      gridVisible: level.difficulty == 'Beginner' || level.difficulty == 'Normal',
    );
  }

  void restartLevel() {
    if (state == null) return;
    _startLevel(state!.level);
  }

  Future<void> tapArrow(String arrowId) async {
    final s = state;
    if (s == null || s.isCompleted || s.isFailed) return;

    // Prevent multiple arrows moving at once
    if (s.activeArrows.any((a) => a.state == ArrowState.moving)) return;

    final targetArrowIndex = s.activeArrows.indexWhere((a) => a.id == arrowId);
    if (targetArrowIndex < 0) return;
    final targetArrow = s.activeArrows[targetArrowIndex];

    if (targetArrow.state == ArrowState.cleared || targetArrow.state == ArrowState.moving) {
      return;
    }

    final canEscape = MoveValidator.canArrowEscape(
      arrow: targetArrow,
      activeArrows: s.activeArrows,
      rows: s.level.rows,
      cols: s.level.columns,
    );

    if (canEscape) {
      // --- SUCCESSFUL MOVE ---
      _ref.read(audioServiceProvider).playEscapeSuccess();

      // Push copy to undo stack
      final undoList = List<List<Arrow>>.from(s.undoStack)
        ..add(s.activeArrows.map((a) => a.copyWith()).toList());

      // Mark moving and animate escape with a fluid snake motion
      const int steps = 25;
      const int stepDuration = 16; // total ~400ms for a smoother slither

      for (int i = 0; i <= steps; i++) {
        final currentS = state;
        // Safety: If state was reset (e.g. restart level) or modified externally, stop animation
        if (currentS == null || currentS.level.id != s.level.id) break;
        if (!currentS.activeArrows.any((a) => a.id == targetArrow.id)) break;

        final progress = i / steps;
        final updatedArrows = currentS.activeArrows.map((a) {
          if (a.id == targetArrow.id) {
            return a.copyWith(
              state: ArrowState.moving,
              animationProgress: progress,
            );
          }
          return a;
        }).toList();

        state = currentS.copyWith(
          activeArrows: updatedArrows,
          // Update moves and undo stack only once at the beginning
          moves: i == 0 ? s.moves + 1 : currentS.moves,
          undoStack: i == 0 ? undoList : currentS.undoStack,
          clearHint: true,
          clearBlocked: true,
        );

        await Future.delayed(const Duration(milliseconds: stepDuration));
      }

      if (state == null) return;
      final updatedRemaining = state!.activeArrows
          .where((a) => a.id != targetArrow.id)
          .toList();
      final updatedCleared = [...state!.clearedArrows, targetArrow.copyWith(state: ArrowState.cleared)];

      final isAllCleared = updatedRemaining.isEmpty;
      int calculatedScore = 0;
      int calculatedStars = 0;

      if (isAllCleared) {
        _ref.read(audioServiceProvider).playLevelComplete();

        // Calculate score & stars
        final baseScore = 500;
        final movesBonus = (state!.level.parMoves - state!.moves) > 0
            ? (state!.level.parMoves - state!.moves) * 25
            : 0;
        final mistakesPenalty = state!.mistakes * 50;
        calculatedScore = (baseScore + movesBonus - mistakesPenalty).clamp(100, 2000);

        if (state!.mistakes == 0 && state!.moves <= state!.level.parMoves) {
          calculatedStars = 3;
        } else if (state!.mistakes <= 1) {
          calculatedStars = 2;
        } else {
          calculatedStars = 1;
        }

        // Record progress & award rewards
        await _ref.read(levelProgressProvider.notifier).recordLevelCompletion(
              levelId: state!.level.id,
              stars: calculatedStars,
              score: calculatedScore,
              moves: state!.moves,
              hintsUsed: 3 - state!.hintsRemaining,
            );

        await _ref.read(profileProvider.notifier).addRewards(
              xp: 100 * calculatedStars,
              coins: 20 * calculatedStars,
            );
      }

      state = state!.copyWith(
        activeArrows: updatedRemaining,
        clearedArrows: updatedCleared,
        isCompleted: isAllCleared,
        score: calculatedScore,
        stars: calculatedStars,
      );
    } else {
      // --- BLOCKED MOVE ---
      _ref.read(audioServiceProvider).playBlockedError();

      final obstruction = MoveValidator.findObstruction(
        arrow: targetArrow,
        activeArrows: s.activeArrows,
        rows: s.level.rows,
        cols: s.level.columns,
      );

      final newMistakes = s.mistakes + 1;
      final newLives = s.lives - 1;
      final isFailed = newLives <= 0;

      state = s.copyWith(
        mistakes: newMistakes,
        lives: newLives.clamp(0, 3),
        isFailed: isFailed,
        blockedArrowId: targetArrow.id,
        obstructingArrowId: obstruction?.id,
      );

      // Reset error highlight after shake effect
      Future.delayed(const Duration(milliseconds: 750), () {
        if (state != null && state!.blockedArrowId == targetArrow.id) {
          state = state!.copyWith(clearBlocked: true);
        }
      });
    }
  }

  void useHint() {
    final s = state;
    if (s == null || s.hintsRemaining <= 0 || s.isCompleted || s.isFailed) return;

    final available = MoveValidator.getAvailableArrows(
      activeArrows: s.activeArrows,
      rows: s.level.rows,
      cols: s.level.columns,
    );

    if (available.isEmpty) return;

    final recommended = available.first;
    state = s.copyWith(
      hintsRemaining: s.hintsRemaining - 1,
      hintArrowId: recommended.id,
    );
    _ref.read(profileProvider.notifier).useHint();
    _ref.read(audioServiceProvider).playTap();
  }

  void useUndo() {
    final s = state;
    if (s == null || s.undoStack.isEmpty || s.undosRemaining <= 0) return;

    final prevStack = List<List<Arrow>>.from(s.undoStack);
    final restoredArrows = prevStack.removeLast();

    state = s.copyWith(
      activeArrows: restoredArrows,
      undosRemaining: s.undosRemaining - 1,
      undoStack: prevStack,
      moves: (s.moves - 1).clamp(0, 999),
      clearHint: true,
      clearBlocked: true,
    );
    _ref.read(profileProvider.notifier).useUndo();
    _ref.read(audioServiceProvider).playTap();
  }

  void toggleGrid() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(gridVisible: !s.gridVisible);
    _ref.read(audioServiceProvider).playTap();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState?>((ref) {
  return GameNotifier(ref);
});
