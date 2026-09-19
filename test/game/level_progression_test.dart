import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrows_escape_2/providers/level_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Level Progression 2-Star Requirement Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Level 1 is unlocked initially, Level 2 is locked', () {
      final state = container.read(levelProgressProvider);
      expect(state.isLevelUnlocked(1), isTrue);
      expect(state.isLevelUnlocked(2), isFalse);
    });

    test('Completing Level 1 with only 1 star does NOT unlock Level 2', () async {
      final notifier = container.read(levelProgressProvider.notifier);

      await notifier.recordLevelCompletion(
        levelId: 1,
        stars: 1,
        score: 500,
        moves: 12,
        hintsUsed: 0,
      );

      final state = container.read(levelProgressProvider);
      expect(state.progressMap[1]?.completed, isTrue);
      expect(state.progressMap[1]?.stars, equals(1));
      expect(state.highestUnlockedLevel, equals(1));
      expect(state.isLevelUnlocked(2), isFalse);
    });

    test('Replaying Level 1 and achieving 2 stars unlocks Level 2', () async {
      final notifier = container.read(levelProgressProvider.notifier);

      // 1-star completion first
      await notifier.recordLevelCompletion(
        levelId: 1,
        stars: 1,
        score: 500,
        moves: 12,
        hintsUsed: 0,
      );
      expect(container.read(levelProgressProvider).isLevelUnlocked(2), isFalse);

      // Replay with 2 stars
      await notifier.recordLevelCompletion(
        levelId: 1,
        stars: 2,
        score: 800,
        moves: 8,
        hintsUsed: 0,
      );

      final state = container.read(levelProgressProvider);
      expect(state.progressMap[1]?.stars, equals(2));
      expect(state.highestUnlockedLevel, equals(2));
      expect(state.isLevelUnlocked(2), isTrue);
    });

    test('Sequential lock chain respects 2-star rule across multiple levels', () async {
      final notifier = container.read(levelProgressProvider.notifier);

      // Level 1: 3 stars -> unlocks Level 2
      await notifier.recordLevelCompletion(levelId: 1, stars: 3, score: 1000, moves: 5, hintsUsed: 0);
      expect(container.read(levelProgressProvider).isLevelUnlocked(2), isTrue);

      // Level 2: 2 stars -> unlocks Level 3
      await notifier.recordLevelCompletion(levelId: 2, stars: 2, score: 900, moves: 7, hintsUsed: 0);
      expect(container.read(levelProgressProvider).isLevelUnlocked(3), isTrue);

      // Level 3: 1 star -> does NOT unlock Level 4
      await notifier.recordLevelCompletion(levelId: 3, stars: 1, score: 400, moves: 14, hintsUsed: 0);
      expect(container.read(levelProgressProvider).isLevelUnlocked(3), isTrue);
      expect(container.read(levelProgressProvider).isLevelUnlocked(4), isFalse);
      expect(container.read(levelProgressProvider).highestUnlockedLevel, equals(3));
    });
  });
}
