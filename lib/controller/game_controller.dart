import 'dart:async';

import 'package:checkpoint/enum/load_state.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/model/game_response.dart';
import 'package:checkpoint/model/game_sort.dart';
import 'package:checkpoint/service/rawg_service.dart';
import 'package:flutter/foundation.dart';

class GameController extends ChangeNotifier {
  GameController({RawgService? rawgService})
    : _rawgService = rawgService ?? const RawgService();

  final RawgService _rawgService;

  Timer? _debounce;
  final List<GameModel> _games = [];

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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
