import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:flutter/material.dart';

class GameDetailPage extends StatelessWidget {
  static const routeName = '/game-detail';

  const GameDetailPage({
    super.key,
    required this.game,
    required this.gameController,
  });

  final GameModel game;
  final GameController gameController;

  void _addToLibrary(BuildContext context) {
    gameController.addToLibrary(game, LibraryStatus.backlog);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${game.name} added to Backlog')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: AppColors.surfaceLight,
                child: Center(
                  child: Icon(
                    Icons.sports_esports_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(game.rating.toStringAsFixed(1)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Release date: ${game.released ?? '-'}'),
                            const SizedBox(height: 8),
                            Text('Genre: ${game.genres.join(', ')}'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ListenableBuilder(
                        listenable: gameController,
                        builder: (context, _) {
                          final isInLibrary = gameController.isInLibrary(
                            game.id,
                          );

                          return FilledButton.icon(
                            onPressed: isInLibrary
                                ? null
                                : () => _addToLibrary(context),
                            icon: Icon(
                              isInLibrary
                                  ? Icons.check_rounded
                                  : Icons.add_circle_outline_rounded,
                            ),
                            label: Text(isInLibrary ? 'In Library' : 'Add'),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is sample information about ${game.name}.',
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text('Platform: PC'),
                  const SizedBox(height: 8),
                  const Text('Developer: Demo Studio'),
                  const SizedBox(height: 24),
                  const Text(
                    'Sample game data',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameDetailPageArguments {
  const GameDetailPageArguments({
    required this.game,
    required this.gameController,
  });

  final GameModel game;
  final GameController gameController;
}
