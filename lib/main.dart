import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/core/theme/app_theme.dart';
import 'package:checkpoint/pages/main_navigation_page.dart';
import 'package:checkpoint/service/rawg_service.dart';
import 'package:flutter/material.dart';

void main() {
  final rawgService = const RawgService();
  final gameController = GameController(rawgService: rawgService)..loadGames(reset: true);

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
    );
  }
}
