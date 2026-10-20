import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/pages/game_detail_page.dart';
import 'package:checkpoint/widgets/game_card.dart';
import 'package:checkpoint/widgets/game_search_bar.dart';
import 'package:flutter/material.dart';

class GameLibraryPage extends StatefulWidget {
  const GameLibraryPage({super.key, required this.gameController});

  final GameController gameController;

  @override
  State<GameLibraryPage> createState() => _GameLibraryPageState();
}

class _GameLibraryPageState extends State<GameLibraryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openGame(GameModel game) {
    Navigator.pushNamed(
      context,
      GameDetailPage.routeName,
      arguments: GameDetailPageArguments(
        game: game,
        gameController: widget.gameController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 360).clamp(0.85, 1.15);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                16 * scale,
                12 * scale,
                0,
              ),
              child: GameSearchBar(
                controller: _searchController,
                onChanged: widget.gameController.searchGames,
                scale: scale,
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.gameController,
                builder: (context, _) {
                  final games = widget.gameController.games;

                  if (games.isEmpty) {
                    return const Center(child: Text('No games found.'));
                  }

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      12 * scale,
                      18 * scale,
                      12 * scale,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Games',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 12 * scale),
                        Expanded(
                          child: GridView.builder(
                            itemCount: games.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 12 * scale,
                                  crossAxisSpacing: 10 * scale,
                                  childAspectRatio: 0.49,
                                ),
                            itemBuilder: (context, index) {
                              final game = games[index];
                              return GameCard(
                                game: game,
                                scale: scale,
                                onTap: () => _openGame(game),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
