import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/enum/quest_status.dart';
import 'package:checkpoint/model/library_game.dart';
import 'package:checkpoint/model/daily_quest.dart';
import 'package:flutter/material.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key, required this.gameController});

  final GameController gameController;

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  QuestStatus _selectedStatus = QuestStatus.pending;

  GameController get _gameController => widget.gameController;

  Future<void> _showCreateQuestSheet() async {
    final libraryGames = _gameController.libraryGames;
    final eligibleGames = _gameController.questEligibleLibraryGames;

    if (libraryGames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a game to your Library first.')),
      );
      return;
    }

    if (eligibleGames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Change a game to Playing in Library before creating a quest.',
          ),
        ),
      );
      return;
    }

    final draft = await showDialog<_QuestDraft>(
      context: context,
      builder: (_) => _CreateQuestDialog(libraryGames: eligibleGames),
    );

    if (!mounted || draft == null) {
      return;
    }

    final wasAdded = _gameController.addDailyQuest(
      libraryGame: draft.libraryGame,
      title: draft.title,
      description: draft.description,
      questDate: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasAdded
              ? 'Daily quest created.'
              : 'Only games with Playing status can have daily quests.',
        ),
      ),
    );
  }

  Future<void> _confirmDeleteQuest(DailyQuest quest) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete quest?'),
          content: Text('Remove "${quest.title}" from your daily quests?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    _gameController.deleteDailyQuest(quest.id);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Quest deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Quest')),
      body: ListenableBuilder(
        listenable: _gameController,
        builder: (context, _) {
          final quests = _gameController.dailyQuests
              .where((quest) => quest.status == _selectedStatus)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: QuestStatus.values.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.label),
                        selected: status == _selectedStatus,
                        onSelected: (_) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: quests.isEmpty
                    ? Center(child: Text(_selectedStatus.emptyMessage))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: quests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _QuestCard(
                            quest: quests[index],
                            onStatusChanged: (status) {
                              _gameController.updateQuestStatus(
                                quests[index].id,
                                status,
                              );
                            },
                            onDelete: () => _confirmDeleteQuest(quests[index]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateQuestSheet,
        icon: const Icon(Icons.add),
        label: const Text('Create Quest'),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final DailyQuest quest;
  final ValueChanged<QuestStatus> onStatusChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == QuestStatus.completed;

    return Card(
      child: ListTile(
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
        contentPadding: const EdgeInsets.all(12),
        leading: Checkbox(
          value: isCompleted,
          onChanged: (isChecked) {
            onStatusChanged(
              isChecked == true ? QuestStatus.completed : QuestStatus.pending,
            );
          },
        ),
        title: Text(
          quest.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(quest.libraryGame.game.name),
            if (quest.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(quest.description),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestDraft {
  const _QuestDraft({
    required this.libraryGame,
    required this.title,
    required this.description,
  });

  final LibraryGame libraryGame;
  final String title;
  final String description;
}

class _CreateQuestDialog extends StatefulWidget {
  const _CreateQuestDialog({required this.libraryGames});

  final List<LibraryGame> libraryGames;

  @override
  State<_CreateQuestDialog> createState() => _CreateQuestDialogState();
}

class _CreateQuestDialogState extends State<_CreateQuestDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _titleError;
  late LibraryGame _selectedGame;

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.libraryGames.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Quest title is required.';
      });
      return;
    }

    Navigator.of(context).pop(
      _QuestDraft(
        libraryGame: _selectedGame,
        title: title,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Daily Quest'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<LibraryGame>(
              initialValue: _selectedGame,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Game',
                border: OutlineInputBorder(),
              ),
              items: widget.libraryGames.map((libraryGame) {
                return DropdownMenuItem(
                  value: libraryGame,
                  child: Text(
                    libraryGame.game.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (libraryGame) {
                if (libraryGame == null) {
                  return;
                }

                setState(() {
                  _selectedGame = libraryGame;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() {
                    _titleError = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Quest title',
                hintText: 'Example: Finish one main mission',
                errorText: _titleError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Quest date: Today'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Create'),
        ),
      ],
    );
  }
}
