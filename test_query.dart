import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  final db = await databaseFactory.openDatabase(inMemoryDatabasePath);

  await db.execute('''
      CREATE TABLE IF NOT EXISTS player_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
  ''');
  await db.execute('''
      CREATE TABLE IF NOT EXISTS players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        avatar TEXT,
        score INTEGER DEFAULT 0,
        penalty INTEGER DEFAULT 0
      )
  ''');
  await db.execute('''
      CREATE TABLE IF NOT EXISTS game_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        game_mode TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT
      )
  ''');
  await db.execute('''
      CREATE TABLE IF NOT EXISTS session_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        player_name TEXT NOT NULL,
        player_avatar TEXT,
        score INTEGER NOT NULL
      )
  ''');

  // Insert data
  await db.insert('player_groups', {'id': 1, 'name': 'Group 1', 'created_at': 'now'});
  await db.insert('players', {'group_id': 1, 'name': 'A', 'score': 10});
  await db.insert('game_sessions', {'id': 1, 'group_id': 1, 'game_mode': 'test', 'started_at': 'now', 'ended_at': 'now'});
  await db.insert('session_scores', {'session_id': 1, 'player_name': 'A', 'score': 50});

  try {
    final result = await db.rawQuery('''
      SELECT g.id, g.name, 
        (
          COALESCE((
            SELECT SUM(ss.score) 
            FROM session_scores ss 
            JOIN game_sessions s ON ss.session_id = s.id 
            WHERE s.group_id = g.id
          ), 0)
          +
          COALESCE((
            SELECT SUM(p.score) 
            FROM players p 
            WHERE p.group_id = g.id AND EXISTS (
              SELECT 1 FROM game_sessions s 
              WHERE s.group_id = g.id AND s.ended_at IS NULL
            )
          ), 0)
        ) as total_score
      FROM player_groups g
      ORDER BY total_score DESC
    ''');
    print('Result: \$result');
  } catch (e) {
    print('Error: \$e');
  }
}
