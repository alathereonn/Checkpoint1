import 'package:cached_network_image/cached_network_image.dart';
import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/service/rawg_service.dart';
import 'package:flutter/material.dart';
import 'package:checkpoint/widgets/rawg_attribution.dart';

class GameDetailPage extends StatefulWidget {
  static const routeName = '/game-detail';

  const GameDetailPage({
    super.key,
    required this.game,
    required this.gameController,
    this.rawgService,
  });

  final GameModel game;
  final GameController gameController;
  final RawgService? rawgService;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  late Future<GameModel> _gameDetail;
  GameModel? _loadedDetail;

  Future<GameModel> _loadDetail() async {
    final detail = await (widget.rawgService ?? RawgService()).fetchGameDetail(
      game.id,
    );
    _loadedDetail = detail.esrbRating == null && game.esrbRating != null
        ? game
        : detail;
    return detail;
  }

  GameModel get game => widget.game;
  GameController get gameController => widget.gameController;

  String englishDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Description unavailable';
    }

    final otherLanguage = RegExp(
      r'^\s*(Español|Spanish|Deutsch|Français|Português|Русский)\s*$',
      caseSensitive: false,
      multiLine: true,
    );
    final match = otherLanguage.firstMatch(description);
    final result =
        (match == null ? description : description.substring(0, match.start))
            .trim();
    return result.isEmpty ? 'Description unavailable' : result;
  }

  @override
  void initState() {
    super.initState();
    _gameDetail = _loadDetail();
  }

  Future<void> _addToLibrary(BuildContext context) async {
    try {
      await gameController.addToLibrary(
        _loadedDetail ?? game,
        LibraryStatus.backlog,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${game.name} added to Backlog')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: game.imageUrl == null
                  ? const ColoredBox(
                      color: AppColors.surfaceLight,
                      child: Center(
                        child: Icon(
                          Icons.sports_esports_rounded,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: game.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ColoredBox(
                        color: AppColors.surfaceLight,
                        child: Center(
                          child: Icon(Icons.sports_esports_rounded),
                        ),
                      ),
                      errorWidget: (_, _, _) => const ColoredBox(
                        color: AppColors.surfaceLight,
                        child: Center(child: Icon(Icons.broken_image_outlined)),
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
                            if (game.rating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(game.rating!.toStringAsFixed(1)),
                                ],
                              ),
                            const SizedBox(height: 12),
                            FutureBuilder<GameModel>(
                              future: _gameDetail,
                              builder: (context, snapshot) => Text(
                                'Age Rating: ${snapshot.data?.esrbRating ?? game.esrbRating ?? 'Age rating unavailable'}',
                              ),
                            ),
                            const SizedBox(height: 8),
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
                  FutureBuilder<GameModel>(
                    future: _gameDetail,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gagal memuat detail game.'),
                            TextButton(
                              onPressed: () => setState(() {
                                _gameDetail = _loadDetail();
                              }),
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        );
                      }
                      final detail = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            englishDescription(detail.description),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Platform: ${detail.platforms.isEmpty ? '-' : detail.platforms.join(', ')}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Developer: ${detail.developers.isEmpty ? '-' : detail.developers.join(', ')}',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const RawgAttribution(),
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
