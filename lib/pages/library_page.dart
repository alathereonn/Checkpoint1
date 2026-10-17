import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/enum/library_filter.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/model/library_game.dart';
import 'package:checkpoint/widgets/library_status_sheet.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.gameController});

  final GameController gameController;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  GameController get gameController => widget.gameController;
  LibraryFilter _selectedFilter = LibraryFilter.all;

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

  Future<void> _updateStatus(
    BuildContext context,
    LibraryGame libraryGame,
  ) async {
    final selectedStatus = await showLibraryStatusSheet(context);
    if (selectedStatus == null || selectedStatus == libraryGame.status) {
      return;
    }

    gameController.addToLibrary(libraryGame.game, selectedStatus);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${libraryGame.game.name} changed to ${selectedStatus.label}',
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        itemCount: LibraryFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = LibraryFilter.values[index];

          return ChoiceChip(
            label: Text(filter.label),
            selected: filter == _selectedFilter,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListenableBuilder(
        listenable: gameController,
        builder: (context, _) {
          final libraryGames = gameController.libraryGames;
          final filteredGames = libraryGames.where((libraryGame) {
            final selectedStatus = _selectedFilter.status;

            return selectedStatus == null ||
                libraryGame.status == selectedStatus;
          }).toList();

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: filteredGames.isEmpty
                    ? Center(
                        child: Text(
                          _selectedFilter == LibraryFilter.all
                              ? 'Your saved games will appear here.'
                              : 'No ${_selectedFilter.label.toLowerCase()} games yet.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredGames.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final libraryGame = filteredGames[index];
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
                                          child: Icon(
                                            Icons.sports_esports_rounded,
                                          ),
                                        )
                                      : Image.network(
                                          game.backgroundImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const ColoredBox(
                                                color: Colors.black12,
                                                child: Icon(
                                                  Icons.sports_esports_rounded,
                                                ),
                                              ),
                                        ),
                                ),
                              ),
                              title: Text(game.name),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Rating: ${game.rating.toStringAsFixed(1)}',
                                ),
                              ),
                              trailing: ActionChip(
                                avatar: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: statusColor,
                                ),
                                label: Text(libraryGame.status.label),
                                labelStyle: TextStyle(color: statusColor),
                                side: BorderSide(color: statusColor),
                                onPressed: () =>
                                    _updateStatus(context, libraryGame),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
