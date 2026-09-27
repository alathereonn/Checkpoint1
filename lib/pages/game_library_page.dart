import 'dart:async';

import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/models/game_model.dart';
import 'package:checkpoint/models/game_sort.dart';
import 'package:checkpoint/services/rawg_service.dart';
import 'package:checkpoint/widgets/game_card.dart';
import 'package:checkpoint/widgets/game_search_bar.dart';
import 'package:checkpoint/widgets/game_sort_button.dart';
import 'package:flutter/material.dart';

class GameLibraryPage extends StatefulWidget {
  const GameLibraryPage({super.key});

  @override
  State<GameLibraryPage> createState() => _GameLibraryPageState();
}

class _GameLibraryPageState extends State<GameLibraryPage> {
  final RawgService _rawgService = const RawgService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  List<GameModel> _games = const [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  GameSort _selectedSort = GameSort.popular;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    final requestVersion = ++_requestVersion;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final games = await _rawgService.getGames(
        search: _searchQuery,
        ordering: _selectedSort.rawgOrdering,
      );

      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _error = 'Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query.trim();
      _loadGames();
    });
  }

  void _onSearchSubmitted(String query) {
    _debounce?.cancel();
    _searchQuery = query.trim();
    _loadGames();
  }

  void _onSortChanged(GameSort sort) {
    _debounce?.cancel();
    _searchQuery = _searchController.text.trim();
    _selectedSort = sort;
    _loadGames();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Game detail coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: GameSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GameSortButton(
                    selectedSort: _selectedSort,
                    onChanged: _onSortChanged,
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading && _games.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _StatusMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load games',
        message: _error!,
        action: FilledButton.icon(
          onPressed: _loadGames,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      );
    }

    if (_games.isEmpty) {
      final title = _searchQuery.isEmpty
          ? 'No games found'
          : 'No games found for "$_searchQuery"';
      return _StatusMessage(
        icon: Icons.sports_esports_outlined,
        title: title,
        message: 'Try another search or sorting option.',
      );
    }

    return Stack(
      children: [
        _GameGrid(games: _games, onGameTap: _showComingSoon),
        if (_isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.background.withValues(alpha: 0.78),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _GameGrid extends StatelessWidget {
  const _GameGrid({required this.games, required this.onGameTap});

  final List<GameModel> games;
  final VoidCallback onGameTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Games', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.49,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) =>
                  GameCard(game: games[index], onTap: onGameTap),
            ),
          ),
        ],
      ),
    );
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
