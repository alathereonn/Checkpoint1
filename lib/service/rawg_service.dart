import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/game_model.dart';

class RawgGamesPage {
  const RawgGamesPage({required this.games, required this.hasMore});
  final List<GameModel> games;
  final bool hasMore;
}

class RawgService {
  RawgService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? _configuredKey;

  final http.Client _client;
  final String _apiKey;
  static const _configuredKey = String.fromEnvironment(
    'RAWG_API_KEY',
    defaultValue: '',
  );

  Future<http.Response> _get(Uri uri) async {
    try {
      return await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (_) {
      throw Exception('Unable to contact RAWG');
    }
  }

  static String? _esrbName(dynamic value) {
    if (value is! Map) return null;
    final name = value['name'];
    return name is String && name.trim().isNotEmpty ? name.trim() : null;
  }

  Future<RawgGamesPage> fetchGames({int page = 1, String search = ''}) async {
    final uri = Uri.https('api.rawg.io', '/api/games', {
      'key': _apiKey,
      'page_size': '15',
      'page': '$page',
      if (search.isNotEmpty) 'search': search,
    });

    final response = await _get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil game: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    final games = results.map((item) {
      final game = item as Map<String, dynamic>;

      return GameModel(
        id: game['id'] as int,
        name: game['name'] as String,
        imageUrl: game['background_image'] as String?,
        esrbRating: _esrbName(game['esrb_rating']),
        rating: (game['rating'] as num?)?.toDouble(),
        released: game['released'] as String?,
        genres: (game['genres'] as List<dynamic>? ?? [])
            .map((genre) => genre['name'] as String)
            .toList(),
      );
    }).toList();
    return RawgGamesPage(games: games, hasMore: data['next'] != null);
  }

  Future<GameModel> fetchGameDetail(int id) async {
    final uri = Uri.https('api.rawg.io', '/api/games/$id', {'key': _apiKey});
    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil detail: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return GameModel(
      id: data['id'] as int,
      name: data['name'] as String,
      imageUrl: data['background_image'] as String?,
      esrbRating: _esrbName(data['esrb_rating']),
      rating: (data['rating'] as num?)?.toDouble(),
      released: data['released'] as String?,
      genres: (data['genres'] as List<dynamic>? ?? [])
          .map((item) => item['name'] as String)
          .toList(),
      description: data['description_raw'] as String?,
      platforms: (data['platforms'] as List<dynamic>? ?? [])
          .map((item) => item['platform']['name'] as String)
          .toList(),
      developers: (data['developers'] as List<dynamic>? ?? [])
          .map((item) => item['name'] as String)
          .toList(),
    );
  }
}
