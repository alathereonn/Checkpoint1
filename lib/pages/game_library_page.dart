import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/pages/game_detail_page.dart';
import 'package:checkpoint/widgets/game_card.dart';
import 'package:checkpoint/widgets/game_search_bar.dart';
import 'package:checkpoint/widgets/rawg_attribution.dart';
import 'package:flutter/material.dart';

class GameLibraryPage extends StatefulWidget {
  const GameLibraryPage({super.key, required this.gameController});

  final GameController gameController;

  @override
  State<GameLibraryPage> createState() => _GameLibraryPageState();
}

class _GameLibraryPageState extends State<GameLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreOnScroll);
    widget.gameController.loadGames();
  }

  void _loadMoreOnScroll() {
    final controller = widget.gameController;
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 500 &&
        controller.loadMoreError == null) {
      controller.loadMoreGames();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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

                  if (widget.gameController.isLoadingGames) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.gameController.gamesError != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Could not load games. ${widget.gameController.gamesError}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => widget.gameController.loadGames(
                                forceRefresh: true,
                              ),
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Games',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                            ),
                            const RawgAttribution(compact: true),
                          ],
                        ),
                        SizedBox(height: 12 * scale),
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
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
                        if (widget.gameController.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (widget.gameController.loadMoreError != null)
                          Center(
                            child: TextButton(
                              onPressed: widget.gameController.loadMoreGames,
                              child: const Text('Gagal memuat game. Coba lagi'),
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
