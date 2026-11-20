import 'dart:convert';

import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/enum/quest_status.dart';
import 'package:checkpoint/model/daily_quest.dart';
import 'package:checkpoint/model/game_model.dart';
import 'package:checkpoint/model/game_session.dart';
import 'package:checkpoint/model/library_game.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase(this.db);
  final Database db;

  static Future<LocalDatabase> open() async {
    final db = await openDatabase(
      path.join(await getDatabasesPath(), 'checkpoint.db'),
      version: 2,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE games ADD COLUMN esrb_rating TEXT');
        }
      },
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE games (id INTEGER PRIMARY KEY, rawg_id INTEGER NOT NULL UNIQUE, title TEXT NOT NULL, cover_url TEXT, genre TEXT NOT NULL, rating REAL, released TEXT, esrb_rating TEXT)',
        );
        await db.execute(
          'CREATE TABLE backlogs (id INTEGER PRIMARY KEY, game_id INTEGER NOT NULL UNIQUE REFERENCES games(id), platform TEXT, status TEXT NOT NULL, created_at TEXT NOT NULL, started_at TEXT, completed_at TEXT)',
        );
        await db.execute(
          'CREATE TABLE quest (id TEXT PRIMARY KEY, backlogs_id INTEGER NOT NULL REFERENCES backlogs(id), title TEXT NOT NULL, description TEXT NOT NULL, quest_date TEXT NOT NULL, status TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE play_sessions (id TEXT PRIMARY KEY, backlogs_id INTEGER NOT NULL REFERENCES backlogs(id), started_at TEXT NOT NULL, ended_at TEXT, duration_sec INTEGER, status TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE sessions_quest (id INTEGER PRIMARY KEY, session_id TEXT NOT NULL REFERENCES play_sessions(id), quest_id TEXT NOT NULL REFERENCES quest(id) ON DELETE CASCADE, result_status TEXT, UNIQUE(session_id, quest_id))',
        );
      },
    );
    return LocalDatabase(db);
  }

  Future<List<LibraryGame>> loadLibrary() async {
    final rows = await db.rawQuery(
      'SELECT games.rawg_id, games.title, games.cover_url, games.genre, games.rating, games.released, games.esrb_rating, backlogs.status, backlogs.created_at FROM backlogs JOIN games ON games.id = backlogs.game_id ORDER BY backlogs.created_at',
    );
    return rows
        .map(
          (row) => LibraryGame(
            game: GameModel(
              id: row['rawg_id'] as int,
              name: row['title'] as String,
              imageUrl: row['cover_url'] as String?,
              rating: (row['rating'] as num?)?.toDouble(),
              esrbRating: row['esrb_rating'] as String?,
              released: row['released'] as String?,
              genres: (jsonDecode(row['genre'] as String) as List)
                  .cast<String>(),
            ),
            status: LibraryStatus.values.byName(row['status'] as String),
            addedAt: DateTime.parse(row['created_at'] as String),
          ),
        )
        .toList();
  }

  Future<List<DailyQuest>> loadQuests(Map<int, LibraryGame> library) async {
    final rows = await db.rawQuery(
      'SELECT quest.*, games.rawg_id FROM quest JOIN backlogs ON quest.backlogs_id = backlogs.id JOIN games ON backlogs.game_id = games.id',
    );
    return rows
        .map(
          (row) => DailyQuest(
            id: row['id'] as String,
            libraryGame: library[row['rawg_id'] as int]!,
            title: row['title'] as String,
            description: row['description'] as String,
            questDate: DateTime.parse(row['quest_date'] as String),
            status: QuestStatus.values.byName(row['status'] as String),
          ),
        )
        .toList();
  }

  Future<List<GameSession>> loadSessions(Map<int, LibraryGame> library) async {
    final rows = await db.rawQuery(
      'SELECT play_sessions.*, games.rawg_id FROM play_sessions JOIN backlogs ON play_sessions.backlogs_id = backlogs.id JOIN games ON backlogs.game_id = games.id ORDER BY play_sessions.started_at',
    );
    return rows
        .map(
          (row) => GameSession(
            id: row['id'] as String,
            libraryGame: library[row['rawg_id'] as int]!,
            startedAt: DateTime.parse(row['started_at'] as String),
            endedAt: row['ended_at'] == null
                ? null
                : DateTime.parse(row['ended_at'] as String),
          ),
        )
        .toList();
  }

  Future<void> saveLibrary(LibraryGame item) async {
    await db.transaction((txn) async {
      final game = item.game;
      await txn.insert('games', {
        'id': game.id,
        'rawg_id': game.id,
        'title': game.name,
        'cover_url': game.imageUrl,
        'genre': jsonEncode(game.genres),
        'rating': game.rating,
        'released': game.released,
        'esrb_rating': game.esrbRating,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.update(
        'games',
        {
          'title': game.name,
          'cover_url': game.imageUrl,
          'genre': jsonEncode(game.genres),
          'rating': game.rating,
          'released': game.released,
          'esrb_rating': game.esrbRating,
        },
        where: 'rawg_id = ?',
        whereArgs: [game.id],
      );
      final now = DateTime.now().toIso8601String();
      await txn.insert('backlogs', {
        'id': game.id,
        'game_id': game.id,
        'status': item.status.name,
        'created_at': item.addedAt.toIso8601String(),
        'started_at': item.status == LibraryStatus.playing ? now : null,
        'completed_at': item.status == LibraryStatus.completed ? now : null,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.rawUpdate(
        'UPDATE backlogs SET status = ?, started_at = CASE WHEN ? = ? THEN COALESCE(started_at, ?) ELSE started_at END, completed_at = CASE WHEN ? = ? THEN COALESCE(completed_at, ?) ELSE NULL END WHERE game_id = ?',
        [
          item.status.name,
          item.status.name,
          LibraryStatus.playing.name,
          now,
          item.status.name,
          LibraryStatus.completed.name,
          now,
          game.id,
        ],
      );
    });
  }

  Future<void> saveQuest(DailyQuest quest) async {
    final values = {
      'id': quest.id,
      'backlogs_id': quest.libraryGame.game.id,
      'title': quest.title,
      'description': quest.description,
      'quest_date': quest.questDate.toIso8601String(),
      'status': quest.status.name,
    };
    await db.insert(
      'quest',
      values,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.update('quest', values, where: 'id = ?', whereArgs: [quest.id]);
  }

  Future<void> deleteQuest(String id) async =>
      db.delete('quest', where: 'id = ?', whereArgs: [id]);

  Future<void> saveSession(GameSession session) async {
    final values = {
      'id': session.id,
      'backlogs_id': session.libraryGame.game.id,
      'started_at': session.startedAt.toIso8601String(),
      'ended_at': session.endedAt?.toIso8601String(),
      'duration_sec': session.endedAt == null
          ? null
          : session.duration.inSeconds,
      'status': session.isActive ? 'active' : 'completed',
    };
    await db.insert(
      'play_sessions',
      values,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.update(
      'play_sessions',
      values,
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }
}
