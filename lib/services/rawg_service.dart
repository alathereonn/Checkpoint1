import 'dart:convert';

import 'package:checkpoint/core/constants/api_constants.dart';
import 'package:checkpoint/models/game_model.dart';
import 'package:http/http.dart' as http;

class RawgService {
  const RawgService();

  Future<List<GameModel>> getGames({
    String? search,
    String ordering = '-added',
  }) async {
    final trimmedSearch = search?.trim() ?? '';
    final queryParameters = <String, String>{
      'key': ApiConstants.apiKey,
      'page_size': ApiConstants.pageSize.toString(),
      'ordering': ordering,
      if (trimmedSearch.isNotEmpty) 'search': trimmedSearch,
    };
    final uri = Uri.parse(ApiConstants.gamesEndpoint)
        .replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Unable to load games (${response.statusCode}).');
    }

    final decodedResponse = jsonDecode(response.body);
    if (decodedResponse is! Map<String, dynamic>) {
      throw const FormatException('Invalid games response.');
    }

    final results = decodedResponse['results'];
    if (results is! List) {
      throw const FormatException('Games list is missing from the response.');
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(GameModel.fromJson)
        .toList();
  }
}
