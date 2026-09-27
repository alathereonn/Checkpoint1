import 'dart:convert';

import 'package:checkpoint/core/constants/api_constants.dart';
import 'package:checkpoint/models/game_response.dart';
import 'package:http/http.dart' as http;

class RawgService {
  const RawgService();

  Future<GameResponse> getGames({
    String? search,
    String? ordering,
    int page = 1,
    int pageSize = ApiConstants.pageSize,
  }) async {
    final trimmedSearch = search?.trim() ?? '';
    final queryParameters = <String, String>{
      'key': ApiConstants.apiKey,
      'page_size': pageSize.toString(),
      'page': page.toString(),
      if (trimmedSearch.isNotEmpty) ...{
        'search': trimmedSearch,
        'search_precise': 'true',
      },
    };
    if (ordering != null) {
      queryParameters['ordering'] = ordering;
    }
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

    return GameResponse.fromJson(decodedResponse);
  }
}
