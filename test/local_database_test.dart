import 'dart:io';

import 'package:checkpoint/controller/game_controller.dart';
import 'package:checkpoint/data/local_database.dart';
import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/enum/quest_status.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('backlog, quest and active session survive reopening', () async {
    final dir = await Directory.systemTemp.createTemp(
      'checkpoint_sqlite_test_',
    );
    await databaseFactory.setDatabasesPath(dir.path);
    final db = await LocalDatabase.open();
    final controller = GameController(database: db);
    const game = GameModel(
      id: 42,
      name: 'Test game',
      esrbRating: 'Teen',
      rating: 4.0,
      released: null,
      genres: ['RPG'],
    );
    await controller.addToLibrary(game, LibraryStatus.playing);
    final item = controller.libraryGames.single;
    expect(
      await controller.addDailyQuest(
        libraryGame: item,
        title: 'Quest',
        description: 'Play',
        questDate: DateTime(2026, 1, 2),
      ),
      isTrue,
    );
    await controller.updateQuestStatus(
      controller.dailyQuests.single.id,
      QuestStatus.completed,
    );
    expect(await controller.startGameSession(item), isTrue);
    controller.dispose();
    await db.db.close();

    final reopened = await LocalDatabase.open();
    final restored = GameController(database: reopened);
    await restored.loadSavedData();
    expect(restored.libraryGames.single.game.name, 'Test game');
    expect(restored.libraryGames.single.game.esrbRating, 'Teen');
    expect(restored.dailyQuests.single.status, QuestStatus.completed);
    expect(restored.activeGameSession, isNotNull);
    expect(
      await restored.endGameSession(restored.activeGameSession!.id),
      isTrue,
    );
    await restored.deleteDailyQuest(restored.dailyQuests.single.id);
    restored.dispose();
    await reopened.db.close();

    final finalDb = await LocalDatabase.open();
    final finalController = GameController(database: finalDb);
    await finalController.loadSavedData();
    expect(finalController.dailyQuests, isEmpty);
    expect(finalController.activeGameSession, isNull);
    expect(finalController.gameSessions.single.endedAt, isNotNull);
    finalController.dispose();
    await finalDb.db.close();
    await dir.delete(recursive: true);
  });

  test('version 1 database migrates without losing saved games', () async {
    final dir = await Directory.systemTemp.createTemp('checkpoint_migration_');
    await databaseFactory.setDatabasesPath(dir.path);
    final old = await openDatabase(
      '${dir.path}/checkpoint.db',
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE games (id INTEGER PRIMARY KEY, rawg_id INTEGER NOT NULL UNIQUE, title TEXT NOT NULL, cover_url TEXT, genre TEXT NOT NULL, rating REAL, released TEXT)',
        );
        await db.execute(
          'CREATE TABLE backlogs (id INTEGER PRIMARY KEY, game_id INTEGER NOT NULL UNIQUE REFERENCES games(id), platform TEXT, status TEXT NOT NULL, created_at TEXT NOT NULL, started_at TEXT, completed_at TEXT)',
        );
        await db.insert('games', {
          'id': 9,
          'rawg_id': 9,
          'title': 'Old game',
          'genre': '[]',
        });
        await db.insert('backlogs', {
          'id': 9,
          'game_id': 9,
          'status': 'backlog',
          'created_at': '2026-01-01T00:00:00.000',
        });
      },
    );
    await old.close();
    final migrated = await LocalDatabase.open();
    final restored = await migrated.loadLibrary();
    expect(restored.single.game.name, 'Old game');
    expect(restored.single.game.esrbRating, isNull);
    await migrated.db.close();
    await dir.delete(recursive: true);
  });
}
