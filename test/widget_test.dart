import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/pages/library_page.dart';
import 'package:checkpoint/pages/quest_page.dart';
import 'package:checkpoint/main.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/service/rawg_service.dart';
import 'package:checkpoint/pages/session_history_page.dart';
import 'package:checkpoint/widgets/rawg_attribution.dart';
import 'package:flutter/material.dart'
    show GridView, TextField, Size, Offset, MaterialApp, ListView, Scrollable;
import 'package:flutter_test/flutter_test.dart';

class FakeRawgService extends RawgService {
  @override
  Future<RawgGamesPage> fetchGames({int page = 1, String search = ''}) async {
    return const RawgGamesPage(
      games: [
        GameModel(
          id: 1,
          name: 'Test game',
          rating: null,
          released: null,
          genres: [],
        ),
      ],
      hasMore: false,
    );
  }
}

class PaginatedRawgService extends RawgService {
  final pages = <int>[];

  @override
  Future<RawgGamesPage> fetchGames({int page = 1, String search = ''}) async {
    pages.add(page);
    return RawgGamesPage(
      games: List.generate(
        18,
        (i) => GameModel(
          id: page * 100 + i,
          name: 'Game $page-$i',
          rating: null,
          released: null,
          genres: const [],
        ),
      ),
      hasMore: page < 2,
    );
  }
}

void main() {
  testWidgets('app starts with the main navigation page', (tester) async {
    final controller = GameController(rawgService: FakeRawgService());
    addTearDown(controller.dispose);
    await tester.pumpWidget(MyApp(gameController: controller));
    await tester.pump();
    expect(controller.games, hasLength(1));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('navigation and attribution fit a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(rawgService: FakeRawgService());
    addTearDown(controller.dispose);
    await tester.pumpWidget(MyApp(gameController: controller));
    await tester.pumpAndSettle();
    expect(find.text('RAWG'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact attribution is available on each metadata page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(rawgService: FakeRawgService());
    addTearDown(controller.dispose);
    await tester.pumpWidget(MyApp(gameController: controller));
    await tester.pumpAndSettle();
    expect(find.text('RAWG'), findsOneWidget);
    await tester.tapAt(tester.getCenter(find.text('Library')));
    await tester.pumpAndSettle();
    expect(find.text('RAWG'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tapAt(tester.getCenter(find.text('Quest')));
    await tester.pumpAndSettle();
    expect(find.text('RAWG'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      MaterialApp(home: SessionHistoryPage(gameController: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RawgAttribution), findsOneWidget);
    expect(find.text('RAWG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog pagination retains visible attribution', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = PaginatedRawgService();
    final controller = GameController(rawgService: service);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MyApp(gameController: controller));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(GridView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    expect(service.pages, containsAll([1, 2]));
    expect(controller.games, hasLength(36));
    expect(find.text('RAWG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(360, 800)]) {
    testWidgets('long library and quest lists expose footer at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = GameController(rawgService: FakeRawgService());
      addTearDown(controller.dispose);
      for (var i = 0; i < 12; i++) {
        final game = GameModel(
          id: i,
          name: 'Game $i',
          rating: null,
          released: null,
          genres: const [],
        );
        await controller.addToLibrary(game, LibraryStatus.playing);
        await controller.addDailyQuest(
          libraryGame: controller.libraryGames.last,
          title: 'Quest $i',
          description: '',
          questDate: DateTime(2026),
        );
      }
      await tester.pumpWidget(
        MaterialApp(home: LibraryPage(gameController: controller)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(RawgAttribution),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('RAWG'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        MaterialApp(home: QuestPage(gameController: controller)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(RawgAttribution),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('RAWG'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('long history exposes footer at 320 by 640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = GameController(rawgService: FakeRawgService());
    addTearDown(controller.dispose);
    for (var i = 0; i < 10; i++) {
      final game = GameModel(
        id: i,
        name: 'Game $i',
        rating: null,
        released: null,
        genres: const [],
      );
      await controller.addToLibrary(game, LibraryStatus.playing);
      await controller.startGameSession(controller.libraryGames.last);
      await controller.endGameSession(controller.activeGameSession!.id);
    }
    await tester.pumpWidget(
      MaterialApp(home: SessionHistoryPage(gameController: controller)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(RawgAttribution),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('RAWG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
