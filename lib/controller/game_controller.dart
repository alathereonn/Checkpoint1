import 'dart:async';

import 'package:checkpoint/data/local_database.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/enum/quest_status.dart';
import 'package:checkpoint/model/daily_quest.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/model/game_session.dart';
import 'package:checkpoint/model/library_game.dart';
import 'package:checkpoint/service/rawg_service.dart';
import 'package:flutter/foundation.dart';

class GameController extends ChangeNotifier {
  GameController({RawgService? rawgService, this._database})
    : _rawgService = rawgService ?? RawgService();

  final RawgService _rawgService;
  final LocalDatabase? _database;
  bool _saving = false;

  Future<void> loadSavedData() async {
    final database = _database;
    if (database == null) return;
    final library = await database.loadLibrary();
    final byId = {for (final item in library) item.game.id: item};
    final quests = await database.loadQuests(byId);
    final sessions = await database.loadSessions(byId);
    _libraryGames
      ..clear()
      ..addAll(library);
    _dailyQuests
      ..clear()
      ..addAll(quests);
    _gameSessions
      ..clear()
      ..addAll(sessions);
    if (!_disposed) notifyListeners();
  }

  Future<void> refreshSavedData() async {
    if (_saving || _disposed) return;
    await _save(loadSavedData);
  }

  Future<T> _save<T>(Future<T> Function() action) async {
    if (_saving) throw StateError('Penyimpanan sedang digunakan. Coba lagi.');
    _saving = true;
    try {
      return await action();
    } finally {
      _saving = false;
    }
  }

  final List<GameModel> _games = [];
  final List<LibraryGame> _libraryGames = [];
  final List<DailyQuest> _dailyQuests = [];
  final List<GameSession> _gameSessions = [];

  String _searchQuery = '';
  bool _isLoadingGames = false;
  String? _gamesError;
  bool _isLoadingMore = false;
  bool _hasMoreGames = true;
  String? _loadMoreError;
  int _page = 0;
  int _requestVersion = 0;
  Timer? _searchTimer;
  bool _disposed = false;

  List<GameModel> get games => List.unmodifiable(_games);
  List<LibraryGame> get libraryGames => List.unmodifiable(_libraryGames);
  List<DailyQuest> get dailyQuests => List.unmodifiable(_dailyQuests);
  List<GameSession> get gameSessions => List.unmodifiable(_gameSessions);
  String get searchQuery => _searchQuery;
  bool get isLoadingGames => _isLoadingGames;
  String? get gamesError => _gamesError;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreGames => _hasMoreGames;
  String? get loadMoreError => _loadMoreError;

  Future<void> loadGames({bool forceRefresh = false}) async {
    if (!forceRefresh && (_isLoadingGames || _games.isNotEmpty)) return;

    final version = ++_requestVersion;
    _isLoadingGames = true;
    _isLoadingMore = false;
    _gamesError = null;
    _loadMoreError = null;
    _hasMoreGames = false;
    _page = 0;
    _games.clear();
    notifyListeners();

    try {
      final result = await _rawgService.fetchGames(search: _searchQuery);
      if (_disposed || version != _requestVersion) return;
      _games.addAll(result.games);
      _page = 1;
      _hasMoreGames = result.hasMore;
    } catch (error) {
      if (_disposed || version != _requestVersion) return;
      _gamesError = error.toString();
    } finally {
      if (!_disposed && version == _requestVersion) {
        _isLoadingGames = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreGames() async {
    if (_isLoadingGames || _isLoadingMore || !_hasMoreGames) return;
    final version = _requestVersion;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();
    try {
      final result = await _rawgService.fetchGames(
        page: _page + 1,
        search: _searchQuery,
      );
      if (_disposed || version != _requestVersion) return;
      final existingIds = _games.map((game) => game.id).toSet();
      _games.addAll(result.games.where((game) => existingIds.add(game.id)));
      _page++;
      _hasMoreGames = result.hasMore;
    } catch (error) {
      if (_disposed || version != _requestVersion) return;
      _loadMoreError = error.toString();
    } finally {
      if (!_disposed && version == _requestVersion) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

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
    _searchTimer?.cancel();
    ++_requestVersion;
    _isLoadingGames = true;
    _isLoadingMore = false;
    _gamesError = null;
    _loadMoreError = null;
    _hasMoreGames = false;
    notifyListeners();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      loadGames(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> addToLibrary(GameModel game, LibraryStatus status) =>
      _save(() async {
        final gameIndex = _libraryGames.indexWhere(
          (item) => item.game.id == game.id,
        );

        final item = gameIndex == -1
            ? LibraryGame(game: game, status: status, addedAt: DateTime.now())
            : _libraryGames[gameIndex].copyWith(status: status);
        await _database?.saveLibrary(item);
        if (gameIndex == -1) {
          _libraryGames.add(item);
        } else {
          _libraryGames[gameIndex] = item;
        }

        notifyListeners();
      });

  Future<bool> startGameSession(LibraryGame libraryGame) => _save(() async {
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

    await _database?.saveSession(session);
    _gameSessions.add(session);
    notifyListeners();
    return true;
  });

  Future<bool> endGameSession(String sessionId) => _save(() async {
    final sessionIndex = _gameSessions.indexWhere(
      (session) => session.id == sessionId && session.isActive,
    );

    if (sessionIndex == -1) return false;

    final finished = _gameSessions[sessionIndex].finish(DateTime.now());
    await _database?.saveSession(finished);
    _gameSessions[sessionIndex] = finished;
    notifyListeners();
    return true;
  });

  Future<bool> addDailyQuest({
    required LibraryGame libraryGame,
    required String title,
    required String description,
    required DateTime questDate,
  }) => _save(() async {
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

    await _database?.saveQuest(quest);
    _dailyQuests.add(quest);
    notifyListeners();
    return true;
  });

  Future<void> updateQuestStatus(String questId, QuestStatus status) =>
      _save(() async {
        final questIndex = _dailyQuests.indexWhere(
          (quest) => quest.id == questId,
        );
        if (questIndex == -1) return;

        final updated = _dailyQuests[questIndex].copyWith(status: status);
        await _database?.saveQuest(updated);
        _dailyQuests[questIndex] = updated;
        notifyListeners();
      });

  Future<void> deleteDailyQuest(String questId) => _save(() async {
    await _database?.deleteQuest(questId);
    _dailyQuests.removeWhere((quest) => quest.id == questId);
    notifyListeners();
  });
}
