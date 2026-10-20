import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/main.dart';
import 'package:flutter/material.dart' show GridView, TextField;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts with the main navigation page', (
    WidgetTester tester,
  ) async {
    final gameController = GameController();
    addTearDown(gameController.dispose);

    await tester.pumpWidget(MyApp(gameController: gameController));

    expect(gameController.games, hasLength(6));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
