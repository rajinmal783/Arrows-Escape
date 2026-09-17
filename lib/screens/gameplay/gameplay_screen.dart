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

  void _checkEndgameModals(BuildContext context, GameState? gameState) {
    if (gameState == null || _dialogShown) return;

    if (gameState.isCompleted) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
      });
    } else if (gameState.isFailed) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check completion or game over dialog triggers
    _checkEndgameModals(context, gameState);

    if (gameState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
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
              onHint: () => ref.read(gameProvider.notifier).useHint(),
              onUndo: () => ref.read(gameProvider.notifier).useUndo(),
              onGridToggle: () => ref.read(gameProvider.notifier).toggleGrid(),
              onRestart: () => ref.read(gameProvider.notifier).restartLevel(),
            ),
          ],
        ),
      ),
    );
  }
}
