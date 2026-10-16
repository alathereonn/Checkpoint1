import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/enum/load_state.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/model/game_sort.dart';
import 'package:checkpoint/widgets/game_card.dart';
import 'package:checkpoint/widgets/game_search_bar.dart';
import 'package:checkpoint/widgets/game_sort_button.dart';
import 'package:flutter/material.dart';

class GameLibraryPage extends StatefulWidget {
  const GameLibraryPage({super.key, required this.gameController});

  final GameController gameController;

  @override
  State<GameLibraryPage> createState() => _GameLibraryPageState();
}

class _GameLibraryPageState extends State<GameLibraryPage> {
  GameController get _gameController => widget.gameController;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _gameController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _gameController.removeListener(_onControllerChanged);
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }

    if (_gameController.isInitialLoading && _gameController.games.isEmpty) {
      _scrollToTop();
    }
    setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _gameController.isInitialLoading ||
        _gameController.isLoadingMore ||
        !_gameController.hasMore) {
      return;
    }

    final position = _scrollController.position;
    if (position.maxScrollExtent > 0 &&
        position.pixels >= position.maxScrollExtent * 0.85) {
      _gameController.loadGames();
    }
  }

  void _onSearchChanged(String query) {
    _gameController.onSearchChanged(query);
  }

  void _onSearchSubmitted(String query) {
    _gameController.onSearchSubmitted(query);
  }

  void _onSortChanged(GameSort sort) {
    _gameController.onSortChanged(sort, _searchController.text);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Game detail coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = (media.size.width / 360.0).clamp(0.85, 1.15);

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              _SearchAndSortSection(
                controller: _searchController,
                selectedSort: _gameController.selectedSort,
                onSearchChanged: _onSearchChanged,
                onSearchSubmitted: _onSearchSubmitted,
                onSortChanged: _onSortChanged,
                scale: scale,
              ),
              Expanded(
                child: Container(
                  color: AppColors.background,
                  child: _buildContent(context, scale),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double scale) {
    if (_gameController.initialLoadState == LoadState.initial ||
        _gameController.initialLoadState == LoadState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gameController.initialLoadState == LoadState.error) {
      return _StatusMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load games',
        message:
            _gameController.error ?? 'Check your connection and try again.',
        action: FilledButton.icon(
          onPressed: () => _gameController.loadGames(reset: true),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      );
    }

    if (_gameController.games.isEmpty) {
      final title = _gameController.searchQuery.isEmpty
          ? 'No games found'
          : 'No games found for "${_gameController.searchQuery}"';
      return _StatusMessage(
        icon: Icons.sports_esports_outlined,
        title: title,
        message: 'Try another search or sorting option.',
      );
    }

    return _GameGrid(
      games: _gameController.games,
      scrollController: _scrollController,
      loadMoreState: _gameController.loadMoreState,
      loadMoreError: _gameController.loadMoreError,
      hasMore: _gameController.hasMore,
      onRetryLoadMore: _gameController.loadGames,
      onGameTap: _showComingSoon,
      scale: scale,
    );
  }
}

class _SearchAndSortSection extends StatelessWidget {
  const _SearchAndSortSection({
    required this.controller,
    required this.selectedSort,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onSortChanged,
    required this.scale,
  });

  final TextEditingController controller;
  final GameSort selectedSort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<GameSort> onSortChanged;
  final double scale;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(s(12), s(16), s(12), 0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GameSearchBar(
              controller: controller,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
              scale: scale,
            ),
          ),
          SizedBox(width: s(8)),
          Expanded(
            child: GameSortButton(
              selectedSort: selectedSort,
              onChanged: onSortChanged,
              scale: scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameGrid extends StatelessWidget {
  const _GameGrid({
    required this.games,
    required this.scrollController,
    required this.loadMoreState,
    required this.loadMoreError,
    required this.hasMore,
    required this.onRetryLoadMore,
    required this.onGameTap,
    required this.scale,
  });

  final List<GameModel> games;
  final ScrollController scrollController;
  final LoadState loadMoreState;
  final String? loadMoreError;
  final bool hasMore;
  final VoidCallback onRetryLoadMore;
  final VoidCallback onGameTap;
  final double scale;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(s(12), s(18), s(12), 0),
      child: Container(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GamesTitleSection(scale: scale),
            Expanded(
              child: _GameGridSection(
                games: games,
                scrollController: scrollController,
                loadMoreState: loadMoreState,
                loadMoreError: loadMoreError,
                hasMore: hasMore,
                onRetryLoadMore: onRetryLoadMore,
                onGameTap: onGameTap,
                scale: scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesTitleSection extends StatelessWidget {
  const _GamesTitleSection({required this.scale});

  final double scale;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: s(12)),
      child: Row(
        children: [
          Text(
            'Games',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontSize: s(28).clamp(24.0, 32.0)),
          ),
        ],
      ),
    );
  }
}

class _GameGridSection extends StatelessWidget {
  const _GameGridSection({
    required this.games,
    required this.scrollController,
    required this.loadMoreState,
    required this.loadMoreError,
    required this.hasMore,
    required this.onRetryLoadMore,
    required this.onGameTap,
    required this.scale,
  });

  final List<GameModel> games;
  final ScrollController scrollController;
  final LoadState loadMoreState;
  final String? loadMoreError;
  final bool hasMore;
  final VoidCallback onRetryLoadMore;
  final VoidCallback onGameTap;
  final double scale;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: s(12),
            crossAxisSpacing: s(10),
            childAspectRatio: 0.49,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                GameCard(game: games[index], onTap: onGameTap, scale: scale),
            childCount: games.length,
          ),
        ),
        SliverToBoxAdapter(
          child: _LoadMoreFooter(
            loadState: loadMoreState,
            error: loadMoreError,
            hasMore: hasMore,
            onRetry: onRetryLoadMore,
            scale: scale,
          ),
        ),
      ],
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.loadState,
    required this.error,
    required this.hasMore,
    required this.onRetry,
    required this.scale,
  });

  final LoadState loadState;
  final String? error;
  final bool hasMore;
  final VoidCallback onRetry;
  final double scale;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    if (loadState == LoadState.loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: s(20)),
        child: Center(
          child: SizedBox(
            width: s(24),
            height: s(24),
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (loadState == LoadState.error && error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: s(12)),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(error!),
          ),
        ),
      );
    }

    return SizedBox(height: s(hasMore ? 16 : 24));
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 42),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
