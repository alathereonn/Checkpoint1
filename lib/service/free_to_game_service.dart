import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:checkpoint/model/game_model.dart';

class FreeToGameService {
  FreeToGameService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static final Uri _gamesUri = Uri.parse(
    'https://www.freetogame.com/api/games',
  );

  Future<List<GameModel>> fetchGames() async {
    final response = await _client
        .get(_gamesUri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('FreeToGame returned HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Unexpected FreeToGame response format');
    }

    return decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid game entry in response');
      }

      return GameModel(
        id: value['id'] as int,
        name: value['title'] as String? ?? 'Unknown game',
        imageUrl: value['thumbnail'] as String?,
        rating: null,
        released: value['release_date'] as String?,
        genres: [if (value['genre'] is String) value['genre'] as String],
      );
    }).toList();
  }

  void close() => _client.close();
}
