import 'package:checkpoint/enum/quest_status.dart';
import 'package:checkpoint/model/library_game.dart';

class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.libraryGame,
    required this.title,
    required this.description,
    required this.questDate,
    required this.status,
  });

  final String id;
  final LibraryGame libraryGame;
  final String title;
  final String description;
  final DateTime questDate;
  final QuestStatus status;

  DailyQuest copyWith({
    String? title,
    String? description,
    DateTime? questDate,
    QuestStatus? status,
  }) {
    return DailyQuest(
      id: id,
      libraryGame: libraryGame,
      title: title ?? this.title,
      description: description ?? this.description,
      questDate: questDate ?? this.questDate,
      status: status ?? this.status,
    );
  }
}
