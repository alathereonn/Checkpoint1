import 'package:checkpoint/model/library_game.dart';

class GameSession {
  const GameSession({
    required this.id,
    required this.libraryGame,
    required this.startedAt,
    this.endedAt,
  });

  final String id;
  final LibraryGame libraryGame;
  final DateTime startedAt;
  final DateTime? endedAt;

  bool get isActive => endedAt == null;

  Duration get duration {
    return (endedAt ?? DateTime.now()).difference(startedAt);
  }

  GameSession finish(DateTime time) {
    return GameSession(
      id: id,
      libraryGame: libraryGame,
      startedAt: startedAt,
      endedAt: time,
    );
  }
}