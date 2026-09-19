import 'package:flutter_test/flutter_test.dart';
import 'package:arrows_escape_2/game/level_generator.dart';
import 'package:arrows_escape_2/game/puzzle_solver.dart';

void main() {
  group('LevelGenerator Tests', () {
    test('Generates 100% solvable Beginner level', () {
      final level = LevelGenerator.generateLevel(1);

      expect(level.id, equals(1));
      expect(level.difficulty, equals('Beginner'));
      expect(level.arrows.isNotEmpty, isTrue);

      final solverResult = PuzzleSolver.solve(
        arrows: level.arrows,
        rows: level.rows,
        cols: level.columns,
      );

      expect(solverResult.isSolvable, isTrue);
      expect(solverResult.solutionOrder.length, equals(level.arrows.length));
    });

    test('Generates 100% solvable Normal level', () {
      final level = LevelGenerator.generateLevel(120);

      expect(level.id, equals(120));
      expect(level.difficulty, equals('Normal'));
      expect(level.arrows.length, greaterThanOrEqualTo(10));

      final solverResult = PuzzleSolver.solve(
        arrows: level.arrows,
        rows: level.rows,
        cols: level.columns,
      );

      expect(solverResult.isSolvable, isTrue);
    });

    test('Generates 100% solvable Hard level', () {
      final level = LevelGenerator.generateLevel(250);
      expect(level.difficulty, equals('Hard'));
      final solverResult = PuzzleSolver.solve(
        arrows: level.arrows,
        rows: level.rows,
        cols: level.columns,
      );
      expect(solverResult.isSolvable, isTrue);
    });

    test('Generates 100% solvable SuperHard level', () {
      final level = LevelGenerator.generateLevel(350);
      expect(level.difficulty, equals('Super Hard'));
      final solverResult = PuzzleSolver.solve(
        arrows: level.arrows,
        rows: level.rows,
        cols: level.columns,
      );
      expect(solverResult.isSolvable, isTrue);
    });

    test('Generates 100% solvable Master level (Level 500)', () {
      final level = LevelGenerator.generateLevel(500);
      expect(level.difficulty, equals('Master'));
      final solverResult = PuzzleSolver.solve(
        arrows: level.arrows,
        rows: level.rows,
        cols: level.columns,
      );
      expect(solverResult.isSolvable, isTrue);
    });

    test('Generates 100% solvable Daily Challenge puzzle (e.g. level 999719)', () {
      final level = LevelGenerator.generateLevel(999719);
      expect(level.difficulty, equals('Hard'));
      expect(level.arrows.length, inInclusiveRange(20, 24));
      final solverResult = PuzzleSolver.solve(
        arrows: level.arrows,
        rows: level.rows,
        cols: level.columns,
      );
      expect(solverResult.isSolvable, isTrue);
      expect(solverResult.solutionOrder.length, equals(level.arrows.length));
    });

    test('Deterministic generation produces identical arrows for identical level IDs', () {
      final levelA = LevelGenerator.generateLevel(42);
      final levelB = LevelGenerator.generateLevel(42);

      expect(levelA.arrows.length, equals(levelB.arrows.length));
      for (int i = 0; i < levelA.arrows.length; i++) {
        expect(levelA.arrows[i].id, equals(levelB.arrows[i].id));
        expect(levelA.arrows[i].direction, equals(levelB.arrows[i].direction));
        expect(levelA.arrows[i].path.length, equals(levelB.arrows[i].path.length));
      }
    });
  });
}
