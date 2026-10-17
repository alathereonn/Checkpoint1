import 'package:checkpoint/enum/load_state.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:flutter/material.dart';

class GameDetailPage extends StatefulWidget {
  const GameDetailPage({
    super.key,
    required this.game,
    required this.gameController,
  });

  final GameModel game;
  final GameController gameController;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.gameController.loadGameDetail(widget.game.id);
    });
  }

  String _englishDescription(String description) {
    final cleanDescription = _stripHtml(description);

    final spanishStart = cleanDescription.indexOf('Español');
    if (spanishStart == -1) {
      return cleanDescription;
    }

    return cleanDescription.substring(0, spanishStart).trim();
  }

  String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _showLibraryStatusSheet() async {
    final selectedStatus = await showModalBottomSheet<LibraryStatus>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Add to Library'),
                subtitle: Text('Choose the current game status'),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_outline_rounded),
                title: Text(LibraryStatus.backlog.label),
                subtitle: Text(LibraryStatus.backlog.description),
                onTap: () {
                  Navigator.pop(sheetContext, LibraryStatus.backlog);
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline_rounded),
                title: Text(LibraryStatus.playing.label),
                subtitle: Text(LibraryStatus.playing.description),
                onTap: () {
                  Navigator.pop(sheetContext, LibraryStatus.playing);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: Text(LibraryStatus.completed.label),
                subtitle: Text(LibraryStatus.completed.description),
                onTap: () {
                  Navigator.pop(sheetContext, LibraryStatus.completed);
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedStatus == null) {
      return;
    }

    widget.gameController.addToLibrary(widget.game, selectedStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.game.name} saved as ${selectedStatus.label}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _GameDetailCover(imageUrl: game.backgroundImage),
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
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(game.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Release date: ${game.released ?? '-'}'),
                  const SizedBox(height: 8),
                  Text(
                    game.genres.isEmpty
                        ? 'Genre: -'
                        : 'Genre: ${game.genres.join(', ')}',
                  ),
                  const SizedBox(height: 24),

                  ListenableBuilder(
                    listenable: widget.gameController,
                    builder: (context, _) {
                      final controller = widget.gameController;

                      if (controller.detailLoadState == LoadState.initial ||
                          controller.detailLoadState == LoadState.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (controller.detailLoadState == LoadState.error) {
                        return Text(
                          controller.detailError ??
                              'Could not load game detail.',
                          style: const TextStyle(color: Colors.red),
                        );
                      }

                      final detail = controller.gameDetail;
                      final isInLibrary = controller.isInLibrary(game.id);

                      if (detail == null) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'About',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(_englishDescription(detail.description)),

                          const SizedBox(height: 24),
                          Text(
                            'Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),

                          if (detail.platforms.isNotEmpty)
                            Text('Platforms: ${detail.platforms.join(', ')}'),

                          if (detail.developers.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Developer: ${detail.developers.join(', ')}'),
                          ],

                          if (detail.publishers.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Publisher: ${detail.publishers.join(', ')}'),
                          ],

                          if (detail.playtime != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Estimated playtime: ${detail.playtime} hours',
                            ),
                          ],

                          if (detail.metacritic != null) ...[
                            const SizedBox(height: 8),
                            Text('Metacritic: ${detail.metacritic}'),
                          ],

                          if (detail.esrbRating != null) ...[
                            const SizedBox(height: 8),
                            Text('Age rating: ${detail.esrbRating}'),
                          ],

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _showLibraryStatusSheet,
                              icon: Icon(
                                isInLibrary
                                    ? Icons.edit_outlined
                                    : Icons.add_circle_outline_rounded,
                              ),
                              label: Text(
                                isInLibrary
                                    ? 'Update Library Status'
                                    : 'Add to Library',
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'Game data and images provided by RAWG',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      );
                    },
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

class _GameDetailCover extends StatelessWidget {
  const _GameDetailCover({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.sports_esports_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: Icon(
            Icons.sports_esports_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
      ),
    );
  }
}
