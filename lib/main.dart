import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/core/theme/app_theme.dart';
import 'package:checkpoint/pages/game_detail_page.dart';
import 'package:checkpoint/pages/main_navigation_page.dart';
import 'package:checkpoint/pages/session_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final gameController = GameController();

  runApp(MyApp(gameController: gameController));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.gameController});

  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkpoint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigationPage(gameController: gameController),
      onGenerateRoute: (settings) {
        if (settings.name == GameDetailPage.routeName) {
          final arguments = settings.arguments! as GameDetailPageArguments;

          return MaterialPageRoute(
            builder: (_) => GameDetailPage(
              game: arguments.game,
              gameController: arguments.gameController,
            ),
          );
        }

        if (settings.name == SessionHistoryPage.routeName) {
          final gameController = settings.arguments! as GameController;

          return MaterialPageRoute(
            builder: (_) => SessionHistoryPage(
              gameController: gameController,
            ),
          );
        }

        return null;
      },
    );
  }
}
