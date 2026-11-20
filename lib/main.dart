import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/data/local_database.dart';
import 'package:checkpoint/core/theme/app_theme.dart';
import 'package:checkpoint/pages/game_detail_page.dart';
import 'package:checkpoint/pages/main_navigation_page.dart';
import 'package:checkpoint/pages/session_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    final database = await LocalDatabase.open();
    final gameController = GameController(database: database);
    await gameController.loadSavedData();
    runApp(MyApp(gameController: gameController));
  } catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Gagal membuka penyimpanan lokal: $error')),
        ),
      ),
    );
  }
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
        late final Widget page;

        switch (settings.name) {
          case '/game-detail':
            final arguments = settings.arguments! as GameDetailPageArguments;
            page = GameDetailPage(
              game: arguments.game,
              gameController: arguments.gameController,
            );
            break;
          case '/session-history':
            final controller = settings.arguments! as GameController;
            page = SessionHistoryPage(gameController: controller);
            break;
          default:
            return null;
        }

        return MaterialPageRoute(settings: settings, builder: (_) => page);
      },
    );
  }
}
