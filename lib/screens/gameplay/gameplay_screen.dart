import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../widgets/hud_header.dart';
import '../../widgets/booster_bar.dart';
import '../../widgets/puzzle_board_widget.dart';
import '../../widgets/level_complete_dialog.dart';
import '../../widgets/level_failed_dialog.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final int levelId;
  final bool isDaily;

  const GameplayScreen({
    super.key,
    required this.levelId,
    this.isDaily = false,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isDaily) {
        ref.read(gameProvider.notifier).loadDailyChallenge(DateTime.now());
      } else {
        ref.read(gameProvider.notifier).loadLevel(widget.levelId);
      }
    });
  }

  void _showLevelComplete(BuildContext context, GameState gameState) {
    _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => LevelCompleteDialog(
        levelId: gameState.level.id,
        stars: gameState.stars,
        score: gameState.score,
        moves: gameState.moves,
        xpEarned: 100 * gameState.stars,
        coinsEarned: 20 * gameState.stars,
        onNext: () {
          Navigator.of(dialogCtx).pop();
          _dialogShown = false;
          if (widget.isDaily) {
            context.go('/home');
          } else {
            final nextId = widget.levelId + 1;
            context.go('/game/$nextId');
            ref.read(gameProvider.notifier).loadLevel(nextId);
          }
        },
        onReplay: () {
          Navigator.of(dialogCtx).pop();
          _dialogShown = false;
          ref.read(gameProvider.notifier).restartLevel();
        },
        onHome: () {
          Navigator.of(dialogCtx).pop();
          _dialogShown = false;
          context.go('/home');
        },
      ),
    );
  }

  void _showLevelFailed(BuildContext context, GameState gameState) {
    _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => LevelFailedDialog(
        onRetry: () {
          Navigator.of(dialogCtx).pop();
          _dialogShown = false;
          ref.read(gameProvider.notifier).restartLevel();
        },
        onHome: () {
          Navigator.of(dialogCtx).pop();
          _dialogShown = false;
          context.go('/home');
        },
        onLevels: () {
          Navigator.of(dialogCtx).pop();
          _dialogShown = false;
          context.go('/levels');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use ref.listen to handle one-time side effects like showing dialogs
    ref.listen(gameProvider, (previous, next) {
      if (next == null || _dialogShown) return;

      if (next.isCompleted && (previous == null || !previous.isCompleted)) {
        _showLevelComplete(context, next);
      } else if (next.isFailed && (previous == null || !previous.isFailed)) {
        _showLevelFailed(context, next);
      }
    });

    if (gameState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Top HUD
                HudHeader(
                  levelId: gameState.level.id,
                  difficulty: gameState.level.difficulty,
                  lives: gameState.lives,
                  isDaily: widget.isDaily,
                  onBack: () => context.go('/home'),
                  onSettings: () => context.push('/settings'),
                ),

                // Center Puzzle Canvas
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: PuzzleBoardWidget(
                      arrows: gameState.activeArrows,
                      rows: gameState.level.rows,
                      cols: gameState.level.columns,
                      difficulty: gameState.level.difficulty,
                      isDark: isDark,
                      showGrid: gameState.gridVisible,
                      hintArrowId: gameState.hintArrowId,
                      blockedArrowId: gameState.blockedArrowId,
                      obstructingArrowId: gameState.obstructingArrowId,
                      onArrowTapped: (id) => ref.read(gameProvider.notifier).tapArrow(id),
                    ),
                  ),
                ),

                // Bottom Booster Bar
                BoosterBar(
                  hints: gameState.hintsRemaining,
                  undos: gameState.undosRemaining,
                  gridVisible: gameState.gridVisible,
                  showGridToggle: gameState.level.difficulty == 'Beginner' || 
                                 gameState.level.difficulty == 'Normal',
                  onHint: () => ref.read(gameProvider.notifier).useHint(),
                  onUndo: () => ref.read(gameProvider.notifier).useUndo(),
                  onGridToggle: () => ref.read(gameProvider.notifier).toggleGrid(),
                  onRestart: () => ref.read(gameProvider.notifier).restartLevel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
