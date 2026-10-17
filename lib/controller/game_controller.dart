import 'dart:async';

import 'package:checkpoint/enum/load_state.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/enum/quest_status.dart';
import 'package:checkpoint/model/daily_quest.dart';
import 'package:checkpoint/model/game_detail_model.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/model/game_response.dart';
import 'package:checkpoint/model/game_sort.dart';
import 'package:checkpoint/model/library_game.dart';
import 'package:checkpoint/service/rawg_service.dart';
import 'package:flutter/foundation.dart';

class GameController extends ChangeNotifier {
  GameController({RawgService? rawgService})
    : _rawgService = rawgService ?? const RawgService();

  final RawgService _rawgService;

  Timer? _debounce;
  final List<GameModel> _games = [];
  final List<LibraryGame> _libraryGames = [];
  final List<DailyQuest> _dailyQuests = [];
  final ValueNotifier<int> _questRevision = ValueNotifier(0);

  LoadState _detailLoadState = LoadState.initial;
  GameDetailModel? _gameDetail;
  String? _detailError;
  int _detailRequestVersion = 0;

  Future<void> loadGameDetail(int gameId) async {
    final requestVersion = ++_detailRequestVersion;
    _detailLoadState = LoadState.loading;
    _gameDetail = null;
    _detailError = null;
    notifyListeners();

    try {
      final detail = await _rawgService.getGameDetail(gameId);
      if (requestVersion != _detailRequestVersion) {
        return;
      }

      _gameDetail = detail;
      _detailLoadState = LoadState.success;
    } catch (_) {
      if (requestVersion != _detailRequestVersion) {
        return;
      }

      _detailError = 'Could not load game detail.';
      _detailLoadState = LoadState.error;
    }

    notifyListeners();
  }

  LoadState initialLoadState = LoadState.initial;
  LoadState loadMoreState = LoadState.initial;
  bool hasMore = true;
  bool _hasManuallySelectedSort = false;
  int _currentPage = 1;
  int _requestVersion = 0;
  String _searchQuery = '';
  String? error;
  String? loadMoreError;
  GameSort selectedSort = GameSort.popular;

  List<GameModel> get games => List.unmodifiable(_games);
  List<LibraryGame> get libraryGames => List.unmodifiable(_libraryGames);
  List<LibraryGame> get questEligibleLibraryGames => List.unmodifiable(
    _libraryGames.where(
      (libraryGame) => libraryGame.status == LibraryStatus.playing,
    ),
  );
  List<DailyQuest> get dailyQuests => List.unmodifiable(_dailyQuests);
  ValueListenable<int> get questRevision => _questRevision;
  LoadState get detailLoadState => _detailLoadState;
  GameDetailModel? get gameDetail => _gameDetail;
  String? get detailError => _detailError;

  bool isInLibrary(int gameId) {
    return _libraryGames.any((libraryGame) => libraryGame.game.id == gameId);
  }

  void addToLibrary(GameModel game, LibraryStatus status) {
    final existingIndex = _libraryGames.indexWhere(
      (libraryGame) => libraryGame.game.id == game.id,
    );

    if (existingIndex == -1) {
      _libraryGames.add(
        LibraryGame(game: game, status: status, addedAt: DateTime.now()),
      );
    } else {
      _libraryGames[existingIndex] = _libraryGames[existingIndex].copyWith(
        game: game,
        status: status,
      );
    }

    notifyListeners();
  }

  String get searchQuery => _searchQuery;

  bool get isInitialLoading => initialLoadState == LoadState.loading;
  bool get isLoadingMore => loadMoreState == LoadState.loading;

  String? get _ordering {
    if (_searchQuery.isNotEmpty && !_hasManuallySelectedSort) {
      return null;
    }
    return selectedSort.rawgOrdering;
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _applySearchQuery(query);
    });
  }

  void onSearchSubmitted(String query) {
    _debounce?.cancel();
    _applySearchQuery(query);
  }

  void onSortChanged(GameSort sort, String searchQuery) {
    _debounce?.cancel();
    _searchQuery = searchQuery.trim();
    selectedSort = sort;
    _hasManuallySelectedSort = true;
    loadGames(reset: true);
  }

  Future<void> loadGames({bool reset = false}) async {
    if (!reset && (isInitialLoading || isLoadingMore || !hasMore)) {
      return;
    }

    final requestVersion = reset ? ++_requestVersion : _requestVersion;
    final pageToLoad = reset ? 1 : _currentPage + 1;

    if (reset) {
      _games.clear();
      _currentPage = 1;
      hasMore = true;
      initialLoadState = LoadState.loading;
      loadMoreState = LoadState.initial;
      error = null;
      loadMoreError = null;
    } else {
      loadMoreState = LoadState.loading;
      loadMoreError = null;
    }
    notifyListeners();

    try {
      final response = await _rawgService.getGames(
        search: _searchQuery,
        ordering: _ordering,
        page: pageToLoad,
      );

      if (requestVersion != _requestVersion) {
        return;
      }

      _applyResponse(response, reset: reset, page: pageToLoad);
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }

      if (reset) {
        error = 'Check your connection and try again.';
        initialLoadState = LoadState.error;
      } else {
        loadMoreError = 'Could not load more games.';
        loadMoreState = LoadState.error;
      }
      notifyListeners();
    }
  }

  void _applySearchQuery(String query) {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      selectedSort = GameSort.popular;
      _hasManuallySelectedSort = false;
    }
    loadGames(reset: true);
  }

  void _applyResponse(
    GameResponse response, {
    required bool reset,
    required int page,
  }) {
    if (reset) {
      _games
        ..clear()
        ..addAll(response.games);
      initialLoadState = LoadState.success;
      loadMoreState = LoadState.initial;
    } else {
      _games.addAll(response.games);
      loadMoreState = LoadState.success;
    }

    _currentPage = page;
    hasMore = response.hasNext && response.games.isNotEmpty;
    notifyListeners();
  }

  bool addDailyQuest({
    required LibraryGame libraryGame,
    required String title,
    required String description,
    required DateTime questDate,
  }) {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      return false;
    }

    LibraryGame? currentLibraryGame;
    for (final item in _libraryGames) {
      if (item.game.id == libraryGame.game.id) {
        currentLibraryGame = item;
        break;
      }
    }

    if (currentLibraryGame == null ||
        currentLibraryGame.status != LibraryStatus.playing) {
      return false;
    }

    _dailyQuests.add(
      DailyQuest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        libraryGame: currentLibraryGame,
        title: cleanTitle,
        description: description.trim(),
        questDate: questDate,
        status: QuestStatus.pending,
      ),
    );

    _notifyQuestListeners();
    return true;
  }

  void updateQuestStatus(String questId, QuestStatus status) {
    final questIndex = _dailyQuests.indexWhere((quest) => quest.id == questId);

    if (questIndex == -1) {
      return;
    }

    _dailyQuests[questIndex] = _dailyQuests[questIndex].copyWith(
      status: status,
    );

    _notifyQuestListeners();
  }

  void deleteDailyQuest(String questId) {
    _dailyQuests.removeWhere((quest) => quest.id == questId);
    _notifyQuestListeners();
  }

  void _notifyQuestListeners() {
    _questRevision.value++;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _questRevision.dispose();
    super.dispose();
  }
}
