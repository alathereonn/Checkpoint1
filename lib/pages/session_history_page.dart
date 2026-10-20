import 'dart:async';

import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/model/game_session.dart';
import 'package:flutter/material.dart';

class SessionHistoryPage extends StatelessWidget {
  static const routeName = '/session-history';

  const SessionHistoryPage({
    super.key,
    required this.gameController,
  });

  final GameController gameController;

  String _formatDateTime(DateTime dateTime) {
    final date = dateTime.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}'
        ' • ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${duration.inMinutes}m ${seconds}s';
  }

  Widget _buildSummary(
    BuildContext context, {
    required int completedCount,
    required Duration totalPlaytime,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total playtime', style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(totalPlaytime),
                    style: textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completed sessions', style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('$completedCount', style: textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameGroup(List<GameSession> sessions) {
    final game = sessions.first.libraryGame.game;
    final completedSessions = sessions.where((session) => !session.isActive);
    final totalPlaytime = completedSessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + session.duration,
    );

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.sports_esports_rounded),
        title: Text(game.name),
        subtitle: Text(
          '${completedSessions.length} completed • '
          '${_formatDuration(totalPlaytime)} played',
        ),
        children: sessions.map(_buildSessionTile).toList(),
      ),
    );
  }

  Widget _buildSessionTile(GameSession session) {
    return ListTile(
      key: ValueKey(session.id),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(
        session.isActive
            ? Icons.play_circle_outline_rounded
            : Icons.check_circle_outline_rounded,
      ),
      title: Text(
        session.isActive
            ? 'Session in progress'
            : 'Session on ${_formatDateTime(session.startedAt)}',
      ),
      subtitle: session.isActive
          ? Text('Started ${_formatDateTime(session.startedAt)}')
          : null,
      trailing: session.isActive
          ? _LiveSessionDuration(
              startedAt: session.startedAt,
              formatDuration: _formatDuration,
            )
          : Text(_formatDuration(session.duration)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: ListenableBuilder(
        listenable: gameController,
        builder: (context, _) {
          final sessions = gameController.gameSessions;

          if (sessions.isEmpty) {
            return const Center(
              child: Text('Your game sessions will appear here.'),
            );
          }

          final sessionsByGame = <int, List<GameSession>>{};
          for (final session in sessions) {
            sessionsByGame
                .putIfAbsent(session.libraryGame.game.id, () => [])
                .add(session);
          }

          final gameGroups = sessionsByGame.values.toList();
          for (final group in gameGroups) {
            group.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          }
          gameGroups.sort(
            (a, b) => b.first.startedAt.compareTo(a.first.startedAt),
          );

          final completedSessions = sessions.where(
            (session) => !session.isActive,
          );
          final totalPlaytime = completedSessions.fold<Duration>(
            Duration.zero,
            (total, session) => total + session.duration,
          );

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: gameGroups.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildSummary(
                  context,
                  completedCount: completedSessions.length,
                  totalPlaytime: totalPlaytime,
                );
              }

              return _buildGameGroup(gameGroups[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _LiveSessionDuration extends StatefulWidget {
  const _LiveSessionDuration({
    required this.startedAt,
    required this.formatDuration,
  });

  final DateTime startedAt;
  final String Function(Duration) formatDuration;

  @override
  State<_LiveSessionDuration> createState() => _LiveSessionDurationState();
}

class _LiveSessionDurationState extends State<_LiveSessionDuration> {
  late Duration _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _duration = DateTime.now().difference(widget.startedAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _duration = DateTime.now().difference(widget.startedAt);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('${widget.formatDuration(_duration)} • Active');
  }
}
