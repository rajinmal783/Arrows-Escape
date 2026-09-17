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
  /// Solves the puzzle using state search with cycle detection and memoization.
  static SolverResult solve({
    required List<Arrow> arrows,
    required int rows,
    required int cols,
    int maxIterations = 5000,
  }) {
    if (arrows.isEmpty) {
      return const SolverResult(isSolvable: true);
    }

    final initialRemaining = List<Arrow>.from(arrows);
    final initialAvailable = MoveValidator.getAvailableArrows(
      activeArrows: initialRemaining,
      rows: rows,
      cols: cols,
    );

    if (initialAvailable.isEmpty) {
      return const SolverResult(isSolvable: false);
    }

    // BFS Search for solution path
    final queue = <_SearchNode>[
      _SearchNode(
        remainingArrows: initialRemaining,
        clearedOrder: [],
        depth: 0,
      ),
    ];

    final visitedStates = <String>{};
    visitedStates.add(_hashState(initialRemaining));

    int totalBranching = 0;
    int decisions = 0;
    int iterations = 0;

    while (queue.isNotEmpty && iterations < maxIterations) {
      iterations++;
      final current = queue.removeAt(0);

      if (current.remainingArrows.isEmpty) {
        return SolverResult(
          isSolvable: true,
          solutionOrder: current.clearedOrder,
          initialAvailableCount: initialAvailable.length,
          averageBranchingFactor: decisions > 0 ? totalBranching / decisions : 1.0,
          dependencyDepth: current.depth,
        );
      }

      final available = MoveValidator.getAvailableArrows(
        activeArrows: current.remainingArrows,
        rows: rows,
        cols: cols,
      );

      if (available.isEmpty) {
        // Dead end on this branch
        continue;
      }

      totalBranching += available.length;
      decisions++;

      for (final nextArrow in available) {
        final nextRemaining = current.remainingArrows
            .where((a) => a.id != nextArrow.id)
            .toList();
        final stateHash = _hashState(nextRemaining);

        if (!visitedStates.contains(stateHash)) {
          visitedStates.add(stateHash);
          queue.add(_SearchNode(
            remainingArrows: nextRemaining,
            clearedOrder: [...current.clearedOrder, nextArrow.id],
            depth: current.depth + 1,
          ));
        }
      }
    }

    return const SolverResult(isSolvable: false);
  }

  static String _hashState(List<Arrow> arrows) {
    final ids = arrows.map((a) => a.id).toList()..sort();
    return ids.join(',');
  }
}

class _SearchNode {
  final List<Arrow> remainingArrows;
  final List<String> clearedOrder;
  final int depth;

  const _SearchNode({
    required this.remainingArrows,
    required this.clearedOrder,
    required this.depth,
  });
}
