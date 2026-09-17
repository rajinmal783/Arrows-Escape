import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrows_escape_2/widgets/heart_indicator.dart';
import 'package:arrows_escape_2/widgets/booster_bar.dart';

void main() {
  testWidgets('HeartIndicator displays correct filled and unfilled hearts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeartIndicator(lives: 2, maxLives: 3),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsNWidgets(2));
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('BoosterBar displays hint and undo counts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BoosterBar(
            hints: 3,
            undos: 2,
            gridVisible: false,
            onHint: () {},
            onUndo: () {},
            onGridToggle: () {},
            onRestart: () {},
          ),
        ),
      ),
    );

    expect(find.text('Hint'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
