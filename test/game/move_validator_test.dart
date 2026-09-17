import 'package:flutter_test/flutter_test.dart';
import 'package:arrows_escape_2/models/arrow.dart';
import 'package:arrows_escape_2/game/move_validator.dart';

void main() {
  group('MoveValidator Tests', () {
    test('Unblocked arrow pointing UP can escape to boundary', () {
      final arrow = const Arrow(
        id: 'a1',
        path: [GridPoint(2, 2), GridPoint(1, 2)],
        direction: ArrowDirection.up,
      );

      final canEscape = MoveValidator.canArrowEscape(
        arrow: arrow,
        activeArrows: [arrow],
        rows: 5,
        cols: 5,
      );

      expect(canEscape, isTrue);
    });

    test('Arrow pointing UP is blocked by another arrow above it', () {
      final arrow1 = const Arrow(
        id: 'a1',
        path: [GridPoint(3, 2), GridPoint(2, 2)],
        direction: ArrowDirection.up,
      );

      final blocker = const Arrow(
        id: 'a2',
        path: [GridPoint(0, 1), GridPoint(0, 2)],
        direction: ArrowDirection.right,
      );

      final canEscape = MoveValidator.canArrowEscape(
        arrow: arrow1,
        activeArrows: [arrow1, blocker],
        rows: 5,
        cols: 5,
      );

      expect(canEscape, isFalse);

      final obstruction = MoveValidator.findObstruction(
        arrow: arrow1,
        activeArrows: [arrow1, blocker],
        rows: 5,
        cols: 5,
      );

      expect(obstruction?.id, equals('a2'));
    });

    test('Arrow pointing RIGHT can escape if row to the right is clear', () {
      final arrow = const Arrow(
        id: 'a1',
        path: [GridPoint(2, 1), GridPoint(2, 2)],
        direction: ArrowDirection.right,
      );

      final canEscape = MoveValidator.canArrowEscape(
        arrow: arrow,
        activeArrows: [arrow],
        rows: 5,
        cols: 5,
      );

      expect(canEscape, isTrue);
    });

    test('Arrow pointing LEFT is blocked by another arrow to its left', () {
      final arrow = const Arrow(
        id: 'a1',
        path: [GridPoint(2, 3), GridPoint(2, 2)],
        direction: ArrowDirection.left,
      );

      final blocker = const Arrow(
        id: 'a2',
        path: [GridPoint(2, 1), GridPoint(2, 0)],
        direction: ArrowDirection.left,
      );

      final canEscape = MoveValidator.canArrowEscape(
        arrow: arrow,
        activeArrows: [arrow, blocker],
        rows: 5,
        cols: 5,
      );

      expect(canEscape, isFalse);
    });
  });
}
