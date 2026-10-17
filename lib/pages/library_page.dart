import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key, required this.gameController});

  final GameController gameController;

  Color _statusColor(LibraryStatus status) {
    switch (status) {
      case LibraryStatus.backlog:
        return Colors.orange;
      case LibraryStatus.playing:
        return Colors.blue;
      case LibraryStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListenableBuilder(
        listenable: gameController,
        builder: (context, _) {
          final libraryGames = gameController.libraryGames;

          if (libraryGames.isEmpty) {
            return const Center(
              child: Text('Your saved games will appear here.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: libraryGames.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final libraryGame = libraryGames[index];
              final game = libraryGame.game;
              final statusColor = _statusColor(libraryGame.status);

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 72,
                      child: game.backgroundImage == null
                          ? const ColoredBox(
                              color: Colors.black12,
                              child: Icon(Icons.sports_esports_rounded),
                            )
                          : Image.network(
                              game.backgroundImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: Colors.black12,
                                child: Icon(Icons.sports_esports_rounded),
                              ),
                            ),
                    ),
                  ),
                  title: Text(game.name),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Rating: ${game.rating.toStringAsFixed(1)}'),
                  ),
                  trailing: Chip(
                    label: Text(libraryGame.status.label),
                    labelStyle: TextStyle(color: statusColor),
                    side: BorderSide(color: statusColor),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
