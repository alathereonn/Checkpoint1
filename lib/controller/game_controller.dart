import 'package:checkpoint/data/dummy_games.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/enum/quest_status.dart';
import 'package:checkpoint/model/daily_quest.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/model/game_session.dart';
import 'package:checkpoint/model/library_game.dart';
import 'package:flutter/foundation.dart';

class GameController extends ChangeNotifier {
  final List<GameModel> _games = [...dummyGames];
  final List<LibraryGame> _libraryGames = [];
  final List<DailyQuest> _dailyQuests = [];
  final List<GameSession> _gameSessions = [];

  String _searchQuery = '';

  List<GameModel> get games => List.unmodifiable(_games);
  List<LibraryGame> get libraryGames => List.unmodifiable(_libraryGames);
  List<DailyQuest> get dailyQuests => List.unmodifiable(_dailyQuests);
  List<GameSession> get gameSessions => List.unmodifiable(_gameSessions);
  String get searchQuery => _searchQuery;

  List<LibraryGame> get questEligibleLibraryGames {
    return _libraryGames
        .where((game) => game.status == LibraryStatus.playing)
        .toList();
  }

  GameSession? get activeGameSession {
    for (final session in _gameSessions) {
      if (session.isActive) return session;
    }
    return null;
  }

  bool isInLibrary(int gameId) {
    return _libraryGames.any((item) => item.game.id == gameId);
  }

  void searchGames(String query) {
    _searchQuery = query.trim();
    final queryLowercase = _searchQuery.toLowerCase();

    final matchingGames = dummyGames.where((game) {
      final gameText = '${game.name} ${game.genres.join(' ')}'.toLowerCase();
      return gameText.contains(queryLowercase);
    }).toList();

    _games
      ..clear()
      ..addAll(matchingGames);

    notifyListeners();
  }

  void addToLibrary(GameModel game, LibraryStatus status) {
    final gameIndex = _libraryGames.indexWhere(
      (item) => item.game.id == game.id,
    );

    if (gameIndex == -1) {
      _libraryGames.add(
        LibraryGame(game: game, status: status, addedAt: DateTime.now()),
      );
    } else {
      _libraryGames[gameIndex] = _libraryGames[gameIndex].copyWith(
        status: status,
      );
    }

    notifyListeners();
  }

  bool startGameSession(LibraryGame libraryGame) {
    final gameIsPlaying = _libraryGames.any(
      (item) =>
          item.game.id == libraryGame.game.id &&
          item.status == LibraryStatus.playing,
    );

    if (!gameIsPlaying || activeGameSession != null) {
      return false;
    }

    final session = GameSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      libraryGame: libraryGame,
      startedAt: DateTime.now(),
    );

    _gameSessions.add(session);
    notifyListeners();
    return true;
  }

  bool endGameSession(String sessionId) {
    final sessionIndex = _gameSessions.indexWhere(
      (session) => session.id == sessionId && session.isActive,
    );

    if (sessionIndex == -1) return false;

    _gameSessions[sessionIndex] = _gameSessions[sessionIndex].finish(
      DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  bool addDailyQuest({
    required LibraryGame libraryGame,
    required String title,
    required String description,
    required DateTime questDate,
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return false;

    final gameIndex = _libraryGames.indexWhere(
      (item) =>
          item.game.id == libraryGame.game.id &&
          item.status == LibraryStatus.playing,
    );
    if (gameIndex == -1) return false;

    final quest = DailyQuest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      libraryGame: _libraryGames[gameIndex],
      title: cleanTitle,
      description: description.trim(),
      questDate: questDate,
      status: QuestStatus.pending,
    );

    _dailyQuests.add(quest);
    notifyListeners();
    return true;
  }

  void updateQuestStatus(String questId, QuestStatus status) {
    final questIndex = _dailyQuests.indexWhere((quest) => quest.id == questId);
    if (questIndex == -1) return;

    _dailyQuests[questIndex] = _dailyQuests[questIndex].copyWith(
      status: status,
    );
    notifyListeners();
  }

  void deleteDailyQuest(String questId) {
    _dailyQuests.removeWhere((quest) => quest.id == questId);
    notifyListeners();
  }
}
