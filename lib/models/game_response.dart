import 'package:checkpoint/models/game_model.dart';

class GameResponse {
  const GameResponse({required this.games, required this.next});

  final List<GameModel> games;
  final String? next;

  bool get hasNext => next != null;

  factory GameResponse.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    if (results is! List) {
      throw const FormatException('Games list is missing from the response.');
    }

    return GameResponse(
      games: results
          .whereType<Map<String, dynamic>>()
          .map(GameModel.fromJson)
          .toList(),
      next: json['next'] as String?,
    );
  }
}
