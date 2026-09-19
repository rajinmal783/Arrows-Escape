import '../models/arrow.dart';
import 'move_validator.dart';

class SolverResult {
  final bool isSolvable;
  final List<String> solutionOrder;
  final int initialAvailableCount;
  final double averageBranchingFactor;
  final int dependencyDepth;

  const SolverResult({
    required this.isSolvable,
    this.solutionOrder = const [],
    this.initialAvailableCount = 0,
    this.averageBranchingFactor = 1.0,
    this.dependencyDepth = 0,
  });
}

class PuzzleSolver {
  /// Solves the puzzle using monotonic greedy clearance with cycle detection.
  /// Because removing an arrow only frees space and never introduces obstructions,
  /// clearing any available arrow is monotonically safe and optimal.
  static SolverResult solve({
    required List<Arrow> arrows,
    required int rows,
    required int cols,
    int maxIterations = 5000,
  }) {
    if (arrows.isEmpty) {
      return const SolverResult(isSolvable: true);
    }

    final remaining = List<Arrow>.from(arrows);
    final initialAvailable = MoveValidator.getAvailableArrows(
      activeArrows: remaining,
      rows: rows,
      cols: cols,
    );

    if (initialAvailable.isEmpty) {
      return const SolverResult(isSolvable: false);
    }

    final solutionOrder = <String>[];
    int totalAvailable = 0;
    int steps = 0;

    while (remaining.isNotEmpty && steps < maxIterations) {
      final available = MoveValidator.getAvailableArrows(
        activeArrows: remaining,
        rows: rows,
        cols: cols,
      );

      if (available.isEmpty) {
        // Mutual blocking cycle detected: puzzle is genuinely unsolvable
        return const SolverResult(isSolvable: false);
      }

      totalAvailable += available.length;
      steps++;

      // Greedily remove an unblocked arrow
      final nextArrow = available.first;
      remaining.removeWhere((a) => a.id == nextArrow.id);
      solutionOrder.add(nextArrow.id);
    }

    return SolverResult(
      isSolvable: remaining.isEmpty,
      solutionOrder: solutionOrder,
      initialAvailableCount: initialAvailable.length,
      averageBranchingFactor: steps > 0 ? totalAvailable / steps : 1.0,
      dependencyDepth: steps,
    );
  }
}
