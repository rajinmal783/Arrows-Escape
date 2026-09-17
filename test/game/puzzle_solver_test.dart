import 'package:flutter_test/flutter_test.dart';
import 'package:arrows_escape_2/models/arrow.dart';
import 'package:arrows_escape_2/game/puzzle_solver.dart';

void main() {
  group('PuzzleSolver Tests', () {
    test('Solves sequential 2-arrow dependency puzzle', () {
      // Arrow 2 blocks Arrow 1 from escaping UP.
      // Arrow 2 points RIGHT and is free to escape.
      // Expected solution order: [a2, a1]
      final arrow1 = const Arrow(
        id: 'a1',
        path: [GridPoint(3, 2), GridPoint(2, 2)],
        direction: ArrowDirection.up,
      );

      final arrow2 = const Arrow(
        id: 'a2',
        path: [GridPoint(1, 1), GridPoint(1, 2)],
        direction: ArrowDirection.right,
      );

      final result = PuzzleSolver.solve(
        arrows: [arrow1, arrow2],
        rows: 5,
        cols: 5,
      );

      expect(result.isSolvable, isTrue);
      expect(result.solutionOrder, equals(['a2', 'a1']));
      expect(result.initialAvailableCount, equals(1));
    });

    test('Correctly flags mutually blocking cyclical arrows as unsolvable', () {
      // Arrow 1 (at (2,2) pointing UP) blocked by Arrow 2 (at (1,2))
      // Arrow 2 (at (1,2) pointing DOWN) blocked by Arrow 1 (at (2,2))
      final arrow1 = const Arrow(
        id: 'a1',
        path: [GridPoint(2, 2)],
        direction: ArrowDirection.up,
      );

      final arrow2 = const Arrow(
        id: 'a2',
        path: [GridPoint(1, 2)],
        direction: ArrowDirection.down,
      );

      final result = PuzzleSolver.solve(
        arrows: [arrow1, arrow2],
        rows: 5,
        cols: 5,
      );

      expect(result.isSolvable, isFalse);
    });
  });
}
