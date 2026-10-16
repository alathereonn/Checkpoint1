import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts with the main navigation page', (
    WidgetTester tester,
  ) async {
    final gameController = GameController();
    addTearDown(gameController.dispose);

    await tester.pumpWidget(MyApp(gameController: gameController));

    expect(find.text('Games'), findsOneWidget);
  });
}
