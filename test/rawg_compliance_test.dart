import 'dart:convert';

import 'package:checkpoint/service/rawg_service.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/pages/game_detail_page.dart';
import 'package:checkpoint/widgets/rawg_attribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class DetailService extends RawgService {
  DetailService(this.rating);
  final String? rating;

  @override
  Future<GameModel> fetchGameDetail(int id) async => GameModel(
    id: id,
    name: 'Game',
    rating: 4,
    released: null,
    genres: const [],
    esrbRating: rating,
  );
}

void main() {
  test('RAWG parses ESRB, missing metadata, search and pagination', () async {
    final requests = <Uri>[];
    final service = RawgService(
      apiKey: 'test-key',
      client: MockClient((request) async {
        requests.add(request.url);
        final game = {
          'id': 1,
          'name': 'Game',
          'rating': 4.0,
          'released': null,
          'genres': [],
          'esrb_rating': {'name': 'Teen'},
        };
        if (request.url.path.endsWith('/1')) {
          return http.Response(
            jsonEncode({
              ...game,
              'esrb_rating': {'name': 'Mature 17+'},
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'next': 'next-page',
            'results': [
              game,
              {...game, 'id': 2, 'esrb_rating': {}},
              {...game, 'id': 3, 'esrb_rating': null},
            ],
          }),
          200,
        );
      }),
    );
    final page = await service.fetchGames(page: 2, search: 'demo');
    expect(page.hasMore, isTrue);
    expect(page.games.map((g) => g.esrbRating), ['Teen', null, null]);
    expect(requests.single.queryParameters['page'], '2');
    expect(requests.single.queryParameters['search'], 'demo');
    expect((await service.fetchGameDetail(1)).esrbRating, 'Mature 17+');
  });

  testWidgets('attribution activates the RAWG link', (tester) async {
    Uri? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RawgAttribution(
            openUrl: (url) async {
              opened = url;
              return true;
            },
          ),
        ),
      ),
    );
    expect(find.text('Game data by '), findsOneWidget);
    expect(find.text('RAWG'), findsOneWidget);
    await tester.tap(find.text('RAWG'));
    expect(opened.toString(), 'https://rawg.io');
  });

  for (final rating in ['Teen', null]) {
    testWidgets('detail shows age rating: $rating', (tester) async {
      final controller = GameController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: GameDetailPage(
            game: const GameModel(
              id: 1,
              name: 'Game',
              rating: 4,
              released: null,
              genres: [],
            ),
            gameController: controller,
            rawgService: DetailService(rating),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Age Rating: ${rating ?? 'Age rating unavailable'}'),
        findsOneWidget,
      );
      final attribution = find.byType(RawgAttribution);
      expect(attribution, findsOneWidget);
      await tester.ensureVisible(attribution);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(attribution).dy,
        greaterThan(tester.getTopLeft(find.text('Developer: -')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
