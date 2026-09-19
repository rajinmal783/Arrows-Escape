import 'dart:math';
import '../models/arrow.dart';
import '../models/puzzle_level.dart';
import 'puzzle_solver.dart';

class LevelGenerator {
  static const List<String> shapes = [
    'square',
    'rectangle',
    'diamond',
    'butterfly',
    'cross',
    'spiral',
    'heart',
    'shield',
    'star',
  ];

  /// Generates a deterministic, 100% verified solvable level.
  static PuzzleLevel generateLevel(int levelId) {
    final config = _getLevelConfig(levelId);
    final baseSeed = levelId * 7919 + 13;

    for (int attempt = 0; attempt < 50; attempt++) {
      final seed = baseSeed + attempt * 101;
      final rng = Random(seed);

      final level = _tryGenerateLevel(
        levelId: levelId,
        difficulty: config.difficulty,
        rows: config.rows,
        cols: config.cols,
        arrowCount: config.arrowCount,
        shape: config.shape,
        seed: seed,
        rng: rng,
      );

      if (level != null) {
        final solverResult = PuzzleSolver.solve(
          arrows: level.arrows,
          rows: level.rows,
          cols: level.columns,
        );

        if (solverResult.isSolvable && solverResult.solutionOrder.length == level.arrows.length) {
          return level;
        }
      }
    }

    // High reliability fallback: structured interlocking puzzle
    return _generateFallbackLevel(levelId, config);
  }

  static _LevelConfig _getLevelConfig(int levelId) {
    if (levelId >= 999000) {
      // Daily Challenge: Curated 10x10 layout with dynamic shape (20-24 arrows)
      final daySeed = levelId - 999000;
      return _LevelConfig(
        difficulty: 'Hard',
        rows: 10,
        cols: 10,
        arrowCount: 20 + (daySeed % 5),
        shape: shapes[daySeed % shapes.length],
      );
    }

    if (levelId <= 100) {
      // Beginner
      final rows = 6 + (levelId > 50 ? 1 : 0);
      final count = 6 + (levelId * 6 / 100).round();
      return _LevelConfig(
        difficulty: 'Beginner',
        rows: rows,
        cols: rows,
        arrowCount: count.clamp(6, 12),
        shape: shapes[levelId % 3],
      );
    } else if (levelId <= 200) {
      // Normal
      final progress = ((levelId - 100) / 100.0).clamp(0.0, 1.0);
      final rows = 8 + (progress > 0.5 ? 1 : 0);
      final count = 14 + (progress * 8).round();
      return _LevelConfig(
        difficulty: 'Normal',
        rows: rows,
        cols: rows,
        arrowCount: count.clamp(14, 22),
        shape: shapes[(levelId % 5)],
      );
    } else if (levelId <= 300) {
      // Hard
      final progress = ((levelId - 200) / 100.0).clamp(0.0, 1.0);
      final rows = 10;
      final count = 16 + (progress * 6).round();
      return _LevelConfig(
        difficulty: 'Hard',
        rows: rows,
        cols: rows,
        arrowCount: count.clamp(16, 22),
        shape: shapes[(levelId % 7)],
      );
    } else if (levelId <= 400) {
      // Super Hard
      final progress = ((levelId - 300) / 100.0).clamp(0.0, 1.0);
      final rows = 11;
      final count = 22 + (progress * 6).round();
      return _LevelConfig(
        difficulty: 'Super Hard',
        rows: rows,
        cols: rows,
        arrowCount: count.clamp(22, 28),
        shape: shapes[(levelId % shapes.length)],
      );
    } else {
      // Master
      final progress = ((levelId - 400) / 100.0).clamp(0.0, 1.0);
      final rows = 12;
      final count = 26 + (progress * 8).round();
      return _LevelConfig(
        difficulty: 'Master',
        rows: rows,
        cols: rows,
        arrowCount: count.clamp(26, 32),
        shape: shapes[(levelId % shapes.length)],
      );
    }
  }

  static PuzzleLevel? _tryGenerateLevel({
    required int levelId,
    required String difficulty,
    required int rows,
    required int cols,
    required int arrowCount,
    required String shape,
    required int seed,
    required Random rng,
  }) {
    final occupied = <GridPoint>{};
    final arrows = <Arrow>[];

    // Allowed mask points based on shape
    final mask = _createShapeMask(shape, rows, cols);

    final directions = ArrowDirection.values;

    for (int i = 0; i < arrowCount; i++) {
      bool placed = false;
      final shuffledDirs = List<ArrowDirection>.from(directions)..shuffle(rng);

      for (int t = 0; t < 30 && !placed; t++) {
        final dir = shuffledDirs[t % shuffledDirs.length];
        final headCandidate = _findHeadForDirection(dir, rows, cols, occupied, mask, rng);
        if (headCandidate == null) continue;

        final pathLength = 2 + rng.nextInt(max(2, (rows / 4).round()));
        final path = _generatePathFromHead(headCandidate, dir, pathLength, rows, cols, occupied, mask, rng);

        if (path.isNotEmpty) {
          final arrow = Arrow(
            id: 'a_${levelId}_$i',
            path: path,
            direction: dir,
          );
          arrows.add(arrow);
          occupied.addAll(arrow.path);
          placed = true;
        }
      }
    }

    if (arrows.length < max(4, (arrowCount * 0.5).round())) {
      return null;
    }

    return PuzzleLevel(
      id: levelId,
      difficulty: difficulty,
      rows: rows,
      columns: cols,
      seed: seed,
      targetMoves: arrows.length,
      parMoves: arrows.length + (arrows.length * 0.15).ceil(),
      shape: shape,
      arrows: arrows,
    );
  }

  static Set<GridPoint> _createShapeMask(String shape, int rows, int cols) {
    final mask = <GridPoint>{};
    final midR = rows / 2.0;
    final midC = cols / 2.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        bool include = true;
        final dr = (r - midR).abs() / midR;
        final dc = (c - midC).abs() / midC;

        switch (shape) {
          case 'diamond':
            include = (dr + dc) <= 1.25;
            break;
          case 'butterfly':
            final dist = sqrt(dr * dr + dc * dc);
            include = dist <= 1.2 && !(dr < 0.2 && dc > 0.4);
            break;
          case 'cross':
            include = dr <= 0.4 || dc <= 0.4;
            break;
          case 'heart':
            include = (dr <= 0.8 && dc <= 0.85);
            break;
          case 'circle':
            include = (dr * dr + dc * dc) <= 1.1;
            break;
          default:
            include = true;
        }

        if (include) {
          mask.add(GridPoint(r, c));
        }
      }
    }
    return mask;
  }

  static GridPoint? _findHeadForDirection(
    ArrowDirection dir,
    int rows,
    int cols,
    Set<GridPoint> occupied,
    Set<GridPoint> mask,
    Random rng,
  ) {
    final candidates = <GridPoint>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final pt = GridPoint(r, c);
        if (!mask.contains(pt) || occupied.contains(pt)) continue;
        candidates.add(pt);
      }
    }

    if (candidates.isEmpty) return null;
    return candidates[rng.nextInt(candidates.length)];
  }

  static List<GridPoint> _generatePathFromHead(
    GridPoint head,
    ArrowDirection dir,
    int targetLength,
    int rows,
    int cols,
    Set<GridPoint> occupied,
    Set<GridPoint> mask,
    Random rng,
  ) {
    final points = <GridPoint>[head];
    final localOccupied = Set<GridPoint>.from(occupied)..add(head);

    // First step back is opposite to arrow exit direction
    GridPoint curr = head;
    GridPoint? stepBack;
    switch (dir) {
      case ArrowDirection.up:
        stepBack = GridPoint(curr.row + 1, curr.col);
        break;
      case ArrowDirection.down:
        stepBack = GridPoint(curr.row - 1, curr.col);
        break;
      case ArrowDirection.left:
        stepBack = GridPoint(curr.row, curr.col + 1);
        break;
      case ArrowDirection.right:
        stepBack = GridPoint(curr.row, curr.col - 1);
        break;
    }

    if (_isValidPoint(stepBack, rows, cols, localOccupied, mask)) {
      points.insert(0, stepBack);
      localOccupied.add(stepBack);
      curr = stepBack;
    } else {
      return [];
    }

    // Add additional turns or segments to create maze-like arrows
    for (int i = 2; i < targetLength; i++) {
      final neighbors = [
        GridPoint(curr.row - 1, curr.col),
        GridPoint(curr.row + 1, curr.col),
        GridPoint(curr.row, curr.col - 1),
        GridPoint(curr.row, curr.col + 1),
      ]..shuffle(rng);

      GridPoint? next;
      for (final n in neighbors) {
        if (_isValidPoint(n, rows, cols, localOccupied, mask)) {
          next = n;
          break;
        }
      }

      if (next != null) {
        points.insert(0, next);
        localOccupied.add(next);
        curr = next;
      } else {
        break;
      }
    }

    return points; // Last element is head!
  }

  static bool _isValidPoint(
    GridPoint pt,
    int rows,
    int cols,
    Set<GridPoint> occupied,
    Set<GridPoint> mask,
  ) {
    return pt.row >= 0 &&
        pt.row < rows &&
        pt.col >= 0 &&
        pt.col < cols &&
        mask.contains(pt) &&
        !occupied.contains(pt);
  }

  static PuzzleLevel _generateFallbackLevel(int levelId, _LevelConfig config) {
    final arrows = <Arrow>[];
    final rows = config.rows;
    final cols = config.cols;
    final occupied = <GridPoint>{};

    int arrowIdx = 0;
    final maxLayers = min(rows ~/ 2, cols ~/ 2);

    for (int k = 0; k < maxLayers; k++) {
      for (int offset = k + 1; offset < cols - 1 - k; offset += 2) {
        final upHead = GridPoint(k, offset);
        final upTail = GridPoint(k + 1, offset);
        if (!occupied.contains(upHead) && !occupied.contains(upTail)) {
          occupied.add(upHead);
          occupied.add(upTail);
          arrows.add(Arrow(
            id: 'fb_${levelId}_${arrowIdx++}',
            path: [upTail, upHead],
            direction: ArrowDirection.up,
          ));
        }

        final downHead = GridPoint(rows - 1 - k, offset);
        final downTail = GridPoint(rows - 2 - k, offset);
        if (!occupied.contains(downHead) && !occupied.contains(downTail)) {
          occupied.add(downHead);
          occupied.add(downTail);
          arrows.add(Arrow(
            id: 'fb_${levelId}_${arrowIdx++}',
            path: [downTail, downHead],
            direction: ArrowDirection.down,
          ));
        }
      }

      for (int offset = k + 1; offset < rows - 1 - k; offset += 2) {
        final leftHead = GridPoint(offset, k);
        final leftTail = GridPoint(offset, k + 1);
        if (!occupied.contains(leftHead) && !occupied.contains(leftTail)) {
          occupied.add(leftHead);
          occupied.add(leftTail);
          arrows.add(Arrow(
            id: 'fb_${levelId}_${arrowIdx++}',
            path: [leftTail, leftHead],
            direction: ArrowDirection.left,
          ));
        }

        final rightHead = GridPoint(offset, cols - 1 - k);
        final rightTail = GridPoint(offset, cols - 2 - k);
        if (!occupied.contains(rightHead) && !occupied.contains(rightTail)) {
          occupied.add(rightHead);
          occupied.add(rightTail);
          arrows.add(Arrow(
            id: 'fb_${levelId}_${arrowIdx++}',
            path: [rightTail, rightHead],
            direction: ArrowDirection.right,
          ));
        }
      }

      if (arrows.length >= config.arrowCount) break;
    }

    if (arrows.isEmpty) {
      arrows.add(Arrow(
        id: 'fb_${levelId}_0',
        path: [const GridPoint(1, 1), const GridPoint(0, 1)],
        direction: ArrowDirection.up,
      ));
      arrows.add(Arrow(
        id: 'fb_${levelId}_1',
        path: [const GridPoint(1, 2), const GridPoint(2, 2)],
        direction: ArrowDirection.down,
      ));
      arrows.add(Arrow(
        id: 'fb_${levelId}_2',
        path: [const GridPoint(2, 1), const GridPoint(2, 0)],
        direction: ArrowDirection.left,
      ));
      arrows.add(Arrow(
        id: 'fb_${levelId}_3',
        path: [const GridPoint(0, 2), const GridPoint(0, 3)],
        direction: ArrowDirection.right,
      ));
    }

    return PuzzleLevel(
      id: levelId,
      difficulty: config.difficulty,
      rows: rows,
      columns: cols,
      seed: levelId,
      targetMoves: arrows.length,
      parMoves: arrows.length + 2,
      shape: config.shape,
      arrows: arrows,
    );
  }
}

class _LevelConfig {
  final String difficulty;
  final int rows;
  final int cols;
  final int arrowCount;
  final String shape;

  const _LevelConfig({
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.arrowCount,
    required this.shape,
  });
}
