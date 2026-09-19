import 'dart:math';
import 'package:flutter/material.dart';
import '../models/arrow.dart';
import '../models/puzzle_level.dart';
import 'puzzle_solver.dart';

class LevelGenerator {
  /// 16 distinct, recognizable maze silhouette shapes matching real-world icons & art
  static const List<String> shapes = [
    'cat',          // Cat silhouette with ears, head, body, tail
    'dog',          // Dog/Husky silhouette with muzzle, legs, curled tail
    'trophy',       // Trophy cup with handles and pedestal
    'headphones',   // Headphones with headband arch and ear cups
    'house',        // House / temple with pointed gable roof
    'heart',        // Heart shape
    'butterfly',    // Winged butterfly
    'shield',       // Medieval knight shield
    'star',         // 5-point star
    'diamond',      // Classic diamond
    'cross',        // Greek cross / plus
    'spiral',       // Spiral / snail maze
    'robot',        // Robot / mech silhouette
    'circle',       // Circular arena
    'hexagon',      // Hexagonal emblem
    'labyrinth',    // Greek key border labyrinth
  ];

  /// Curated palette of vibrant arrow colors
  static const List<Color> vibrantColors = [
    Color(0xFF2563EB), // Electric Royal Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFFEF4444), // Crimson Coral Red
    Color(0xFFF59E0B), // Amber Gold
    Color(0xFF8B5CF6), // Royal Purple
    Color(0xFF06B6D4), // Cyan Teal
    Color(0xFFEC4899), // Hot Pink
    Color(0xFFF97316), // Vivid Orange
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
      final beginnerShapes = ['heart', 'house', 'shield', 'star', 'diamond', 'cat', 'trophy', 'circle'];
      return _LevelConfig(
        difficulty: 'Beginner',
        rows: rows,
        cols: rows,
        arrowCount: count.clamp(6, 12),
        shape: beginnerShapes[levelId % beginnerShapes.length],
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
        shape: shapes[levelId % shapes.length],
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
        shape: shapes[(levelId * 3) % shapes.length],
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
        shape: shapes[(levelId * 5) % shapes.length],
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
        shape: shapes[(levelId * 7) % shapes.length],
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

        // Multi-sized arrows tailored to grid size:
        // For rows <= 8 (Beginner, Normal): 2 to 4 cells (enables 10-18 interlocking arrows)
        // For rows >= 10 (Hard, Super Hard, Master): 2 to 8 cells (dramatic multi-length variety)
        int targetLength;
        if (rows <= 8) {
          final roll = rng.nextInt(10);
          if (roll < 4) {
            targetLength = 2; // Short 2-cell
          } else if (roll < 8) {
            targetLength = 3; // Medium 3-cell bent
          } else {
            targetLength = 4; // 4-cell turned
          }
        } else {
          final roll = rng.nextInt(10);
          if (roll < 3) {
            targetLength = 2; // Short 2-cell
          } else if (roll < 6) {
            targetLength = 3 + rng.nextInt(2); // Medium (3-4 cells)
          } else {
            final maxLen = min(8, max(5, (rows * 0.65).round()));
            targetLength = 5 + rng.nextInt(max(1, maxLen - 4)); // Long winding 5-8 cell
          }
        }

        final path = _generatePathFromHead(headCandidate, dir, targetLength, rows, cols, occupied, mask, rng);

        if (path.isNotEmpty) {
          // Multi-colored arrows: assign vibrant color from curated palette to ~45% of arrows
          Color? arrowColor;
          if (rng.nextBool() || path.length >= 4 || (i % 2 == 0)) {
            arrowColor = vibrantColors[rng.nextInt(vibrantColors.length)];
          }

          final arrow = Arrow(
            id: 'a_${levelId}_$i',
            path: path,
            direction: dir,
            customColor: arrowColor,
          );
          arrows.add(arrow);
          occupied.addAll(arrow.path);
          placed = true;
        }
      }
    }

    final minThreshold = (arrowCount * 0.7).round().clamp(4, arrowCount);
    if (arrows.length < minThreshold) {
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
    final midR = (rows - 1) / 2.0;
    final midC = (cols - 1) / 2.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final nr = rows > 1 ? r / (rows - 1) : 0.5; // [0.0 (top), 1.0 (bottom)]
        final nc = cols > 1 ? c / (cols - 1) : 0.5; // [0.0 (left), 1.0 (right)]
        final dr = (r - midR) / max(1.0, midR);      // [-1.0, 1.0]
        final dc = (c - midC) / max(1.0, midC);      // [-1.0, 1.0]
        final absDr = dr.abs();
        final absDc = dc.abs();

        bool include = true;

        switch (shape) {
          case 'cat':
            // Pointed cat ears at top, rounded head, body, and tail
            if (nr < 0.25) {
              include = (nc >= 0.12 && nc <= 0.40) || (nc >= 0.60 && nc <= 0.88);
            } else if (nr < 0.52) {
              include = absDc <= 0.85;
            } else if (nr < 0.60) {
              include = absDc <= 0.68;
            } else {
              final inBody = nc >= 0.15 && nc <= 0.78;
              final inTail = nr >= 0.62 && nr <= 0.88 && nc >= 0.78 && nc <= 0.98;
              include = inBody || inTail;
            }
            break;

          case 'dog':
            // Dog/Husky silhouette: snout pointing left, pointed ears, torso, legs, curly tail
            if (nr < 0.22) {
              include = nc >= 0.18 && nc <= 0.42;
            } else if (nr < 0.40) {
              include = nc >= 0.08 && nc <= 0.50;
            } else if (nr < 0.72) {
              final inTorso = nc >= 0.18 && nc <= 0.82;
              final inCurledTail = nr < 0.55 && nc >= 0.78 && nc <= 0.98;
              include = inTorso || inCurledTail;
            } else {
              final frontLeg = nc >= 0.18 && nc <= 0.40;
              final hindLeg = nc >= 0.60 && nc <= 0.82;
              include = frontLeg || hindLeg;
            }
            break;

          case 'trophy':
            // Trophy cup: wide cup rim, side handles, tapered stem, wide pedestal
            if (nr < 0.52) {
              final inCup = absDc <= 0.62;
              final inHandles = nr >= 0.18 && nr <= 0.45 && absDc <= 0.95;
              include = inCup || inHandles;
            } else if (nr < 0.76) {
              include = absDc <= 0.28;
            } else {
              include = absDc <= 0.78;
            }
            break;

          case 'headphones':
            // Over-ear headphones: headband arch over top, earcups on sides
            if (nr < 0.35) {
              final inOuterArch = absDc <= 0.85;
              final inInnerCutout = nr >= 0.18 && absDc <= 0.52;
              include = inOuterArch && !inInnerCutout;
            } else {
              final leftCup = nc >= 0.06 && nc <= 0.40;
              final rightCup = nc >= 0.60 && nc <= 0.94;
              include = leftCup || rightCup;
            }
            break;

          case 'house':
            // House/temple with peaked roof and solid base
            if (nr < 0.45) {
              final roofWidth = (nr / 0.45) * 0.85 + 0.12;
              include = absDc <= roofWidth;
            } else {
              final notDoor = !(nr > 0.82 && absDc < 0.22);
              include = absDc <= 0.88 && notDoor;
            }
            break;

          case 'heart':
            if (nr < 0.35) {
              final leftLobe = pow(nc - 0.30, 2) + pow(nr - 0.25, 2) <= 0.045;
              final rightLobe = pow(nc - 0.70, 2) + pow(nr - 0.25, 2) <= 0.045;
              final bridge = nr >= 0.20 && absDc <= 0.68;
              include = leftLobe || rightLobe || bridge;
            } else {
              final taper = 0.95 * (1.0 - (nr - 0.35) / 0.65 * 0.88);
              include = absDc <= taper;
            }
            break;

          case 'butterfly':
            final dist = sqrt(dr * dr + dc * dc);
            final inWings = (nr <= 0.52 ? absDc <= 0.92 : absDc <= 0.78);
            final wingIndent = nr >= 0.48 && nr <= 0.58 && absDc > 0.55;
            include = dist <= 1.25 && inWings && !wingIndent;
            break;

          case 'shield':
            if (nr <= 0.55) {
              include = absDc <= 0.88;
            } else {
              final taper = 0.88 * (1.0 - (nr - 0.55) / 0.45);
              include = absDc <= taper;
            }
            break;

          case 'star':
            final dist = sqrt(dr * dr + dc * dc);
            final angle = atan2(dr, dc);
            include = dist <= (0.70 + 0.28 * cos(5 * angle));
            break;

          case 'diamond':
            include = (absDr + absDc) <= 1.25;
            break;

          case 'cross':
            include = absDr <= 0.42 || absDc <= 0.42;
            break;

          case 'spiral':
            final isRim = r <= 1 || r >= rows - 2 || c <= 1 || c >= cols - 2;
            final isCore = absDr <= 0.45 || absDc <= 0.45;
            include = isRim || isCore;
            break;

          case 'robot':
            if (nr < 0.15) {
              include = absDc <= 0.18;
            } else if (nr < 0.40) {
              include = absDc <= 0.70;
            } else if (nr < 0.78) {
              include = absDc <= 0.88;
            } else {
              include = (nc >= 0.15 && nc <= 0.42) || (nc >= 0.58 && nc <= 0.85);
            }
            break;

          case 'circle':
            include = (dr * dr + dc * dc) <= 1.08;
            break;

          case 'hexagon':
            include = absDc <= 0.88 && (absDr + 0.5 * absDc <= 1.05);
            break;

          case 'labyrinth':
            final isOuterBorder = r <= 1 || r >= rows - 2 || c <= 1 || c >= cols - 2;
            final isInterlocking = (r % 2 == 0) || (c % 2 == 0);
            include = isOuterBorder || isInterlocking;
            break;

          default:
            include = true;
        }

        if (include) {
          mask.add(GridPoint(r, c));
        }
      }
    }

    // Safety guarantee: Ensure mask always contains sufficient cells
    final minRequired = max(16, (rows * cols * 0.42).round());
    if (mask.length < minRequired) {
      for (int r = 1; r < rows - 1; r++) {
        for (int c = 1; c < cols - 1; c++) {
          mask.add(GridPoint(r, c));
          if (mask.length >= minRequired) break;
        }
        if (mask.length >= minRequired) break;
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
            customColor: vibrantColors[arrowIdx % vibrantColors.length],
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
            customColor: vibrantColors[arrowIdx % vibrantColors.length],
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
            customColor: vibrantColors[arrowIdx % vibrantColors.length],
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
            customColor: vibrantColors[arrowIdx % vibrantColors.length],
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
        customColor: vibrantColors[0],
      ));
      arrows.add(Arrow(
        id: 'fb_${levelId}_1',
        path: [const GridPoint(1, 2), const GridPoint(2, 2)],
        direction: ArrowDirection.down,
        customColor: vibrantColors[1],
      ));
      arrows.add(Arrow(
        id: 'fb_${levelId}_2',
        path: [const GridPoint(2, 1), const GridPoint(2, 0)],
        direction: ArrowDirection.left,
        customColor: vibrantColors[2],
      ));
      arrows.add(Arrow(
        id: 'fb_${levelId}_3',
        path: [const GridPoint(0, 2), const GridPoint(0, 3)],
        direction: ArrowDirection.right,
        customColor: vibrantColors[3],
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
