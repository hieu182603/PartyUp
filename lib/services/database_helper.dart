import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/player_group.dart';
import '../models/player.dart';
import '../models/game_content.dart';
import '../models/game_session.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('party_up.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Use web factory
      databaseFactory = databaseFactoryFfiWeb;
      final path = filePath; // Web uses local storage, just name is fine
      return await openDatabase(path, version: 13, onCreate: _createDB, onUpgrade: _onUpgrade);
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 13, onCreate: _createDB, onUpgrade: _onUpgrade);
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS global_players (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE NOT NULL,
          total_score INTEGER DEFAULT 0,
          total_penalty INTEGER DEFAULT 0,
          games_played INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS game_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          group_id INTEGER NOT NULL,
          game_mode TEXT NOT NULL,
          started_at TEXT NOT NULL,
          ended_at TEXT,
          FOREIGN KEY (group_id) REFERENCES player_groups (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add is_favorite column to game_contents
      try {
        await db.execute('ALTER TABLE game_contents ADD COLUMN is_favorite INTEGER DEFAULT 0');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 5) {
      // Add category column to game_contents
      try {
        await db.execute('ALTER TABLE game_contents ADD COLUMN category TEXT DEFAULT "Tổng hợp"');
      } catch (e) {}
    }
    if (oldVersion < 6) {
      // Add session_scores table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS session_scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            player_name TEXT NOT NULL,
            player_avatar TEXT,
            score INTEGER NOT NULL,
            FOREIGN KEY (session_id) REFERENCES game_sessions (id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {}
    }
    if (oldVersion < 12) {
      // Recreate game_contents table to ensure all new columns exist (penalty_text, points)
      await db.execute('DROP TABLE IF EXISTS game_contents');
      await db.execute('''
        CREATE TABLE game_contents (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,
          type TEXT NOT NULL,
          level TEXT NOT NULL,
          category TEXT DEFAULT 'Tổng hợp',
          is_custom INTEGER DEFAULT 0,
          is_active INTEGER DEFAULT 1,
          is_favorite INTEGER DEFAULT 0,
          penalty_text TEXT,
          points INTEGER
        )
      ''');
      await _insertDefaultGameContent(db);
    }
    if (oldVersion < 13) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS session_turns (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id INTEGER NOT NULL,
          round_number INTEGER NOT NULL,
          player_name TEXT NOT NULL,
          content TEXT NOT NULL,
          points_change INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (session_id) REFERENCES game_sessions (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS player_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS global_players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        total_score INTEGER DEFAULT 0,
        total_penalty INTEGER DEFAULT 0,
        games_played INTEGER DEFAULT 0,
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
        penalty INTEGER DEFAULT 0,
        FOREIGN KEY (group_id) REFERENCES player_groups (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_contents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        level TEXT NOT NULL,
        category TEXT DEFAULT 'Tổng hợp',
        is_custom INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        is_favorite INTEGER DEFAULT 0,
        penalty_text TEXT,
        points INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        game_mode TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        FOREIGN KEY (group_id) REFERENCES player_groups (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        player_name TEXT NOT NULL,
        player_avatar TEXT,
        score INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES game_sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_turns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        round_number INTEGER NOT NULL,
        player_name TEXT NOT NULL,
        content TEXT NOT NULL,
        points_change INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES game_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Bơm dữ liệu mẫu
    await _insertDefaultGameContent(db);
  }

  Future _insertDefaultGameContent(Database db) async {
    try {
      final String response = await rootBundle.loadString('assets/data/game_data.json');
      final data = await json.decode(response);

      // Helper function to map category
      String mapCategory(String rawCat) {
        switch(rawCat) {
          case 'Funny': return 'Hài hước';
          case 'Friend': return 'Tình bạn';
          case 'School': 
          case 'University': return 'Học đường';
          case 'Food': return 'Ẩm thực';
          case 'Love': 
          case 'Couple': return 'Tình yêu';
          case 'Lifestyle': return 'Lifestyle';
          case 'Office': return 'Công việc';
          case 'Travel': return 'Du lịch';
          case 'Movie': return 'Phim ảnh';
          default: return 'Tổng hợp';
        }
      }

      // Helper function to insert items
      Future<void> insertItems(List<dynamic> items, String defaultType) async {
        for (var item in items) {
          final type = item['type'] ?? defaultType;
          final category = mapCategory(item['category'] ?? 'Tổng hợp');
          final content = item['content'] ?? '';
          final penaltyText = item['penalty'] ?? '';
          final level = item['difficulty'] ?? 'vui';
          final point = item['point'] ?? 10;
          
          await db.insert('game_contents', {
            'content': content,
            'type': type,
            'level': level,
            'category': category,
            'penalty_text': penaltyText,
            'points': point,
            'is_active': 1,
          });
        }
      }

      if (data['truths'] != null) await insertItems(data['truths'], 'truth');
      if (data['dares'] != null) await insertItems(data['dares'], 'dare');
      if (data['secret_rules'] != null) await insertItems(data['secret_rules'], 'rule');

    } catch (e) {
      print('Error loading game_data.json: $e');
    }
  }

  // Group Operations
  Future<int> createGroup(PlayerGroup group) async {
    final db = await instance.database;
    return await db.insert('player_groups', group.toMap());
  }

  Future<void> updateGroup(PlayerGroup group) async {
    final db = await instance.database;
    await db.update(
      'player_groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<List<PlayerGroup>> getGroups() async {
    final db = await instance.database;
    final result = await db.query('player_groups', orderBy: 'created_at DESC');
    return result.map((json) => PlayerGroup.fromMap(json)).toList();
  }

  Future<int> deleteGroup(int id) async {
    final db = await instance.database;
    return await db.delete('player_groups', where: 'id = ?', whereArgs: [id]);
  }

  // Player Operations
  Future<int> createPlayer(Player player) async {
    final db = await instance.database;
    return await db.insert('players', player.toMap());
  }

  Future<List<Player>> getPlayersByGroup(int groupId) async {
    final db = await instance.database;
    final result = await db.query('players', where: 'group_id = ?', whereArgs: [groupId]);
    return result.map((json) => Player.fromMap(json)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await instance.database;
    return await db.update('players', player.toMap(), where: 'id = ?', whereArgs: [player.id]);
  }

  Future<int> deletePlayer(int id) async {
    final db = await instance.database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  // Game Session Operations
  Future<int> createGameSession(GameSession session) async {
    final db = await instance.database;
    return await db.insert('game_sessions', session.toMap());
  }

  Future<void> endSession(int sessionId, List<Player> finalPlayers) async {
    final db = await database;
    await db.update(
      'game_sessions',
      {'ended_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    
    // Lưu lại điểm số của người chơi cho ván này
    for (var player in finalPlayers) {
      await db.insert('session_scores', {
        'session_id': sessionId,
        'player_name': player.name,
        'player_avatar': player.avatar ?? '',
        'score': player.score,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getGameHistory({String? gameMode}) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (gameMode != null) {
      whereClause = 'WHERE s.game_mode = ?';
      whereArgs = [gameMode];
    }
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        s.id, 
        s.group_id,
        s.game_mode,
        s.started_at, 
        s.ended_at, 
        g.name as group_name,
        (SELECT COUNT(id) FROM players WHERE group_id = s.group_id) as player_count,
        CASE 
          WHEN (SELECT COUNT(*) FROM session_scores WHERE session_id = s.id) > 0
            THEN (SELECT SUM(score) FROM session_scores WHERE session_id = s.id)
          ELSE (SELECT SUM(score) FROM players WHERE group_id = s.group_id)
        END as total_points,
        (SELECT COUNT(*) FROM session_scores WHERE session_id = s.id) as has_session_scores
      FROM game_sessions s
      JOIN player_groups g ON s.group_id = g.id
      $whereClause
      ORDER BY s.started_at DESC
    ''', whereArgs);
    return maps;
  }

  Future<void> deleteSession(int sessionId) async {
    await deleteSessions([sessionId]);
  }

  Future<void> deleteSessions(List<int> sessionIds) async {
    if (sessionIds.isEmpty) return;
    final db = await instance.database;

    Set<int> affectedGroupIds = {};

    for (final sessionId in sessionIds) {
      // Find the group_id before deleting
      final sessionData = await db.query('game_sessions', where: 'id = ?', whereArgs: [sessionId]);
      if (sessionData.isNotEmpty) {
        affectedGroupIds.add(sessionData.first['group_id'] as int);
      }

      // Deduct points from global_players
      final List<Map<String, dynamic>> sessionTurns = await db.query(
          'session_turns',
          where: 'session_id = ?',
          whereArgs: [sessionId]);
      Map<String, int> scoresToDeduct = {};
      Map<String, int> penaltiesToDeduct = {};

      for (var turn in sessionTurns) {
        final player = turn['player_name'] as String;
        final pointsChange = turn['points_change'] as int;
        if (pointsChange > 0) {
          scoresToDeduct[player] = (scoresToDeduct[player] ?? 0) + pointsChange;
        } else if (pointsChange < 0) {
          penaltiesToDeduct[player] =
              (penaltiesToDeduct[player] ?? 0) + pointsChange.abs();
        }
      }

      for (var player in {...scoresToDeduct.keys, ...penaltiesToDeduct.keys}) {
        final score = scoresToDeduct[player] ?? 0;
        final penalty = penaltiesToDeduct[player] ?? 0;
        await db.rawUpdate('''
          UPDATE global_players
          SET total_score = MAX(0, total_score - ?),
              total_penalty = MAX(0, total_penalty - ?)
          WHERE name = ?
        ''', [score, penalty, player]);
      }

      await db.delete('session_turns',
          where: 'session_id = ?', whereArgs: [sessionId]);
      await db.delete('session_scores',
          where: 'session_id = ?', whereArgs: [sessionId]);
      await db.delete('game_sessions',
          where: 'id = ?', whereArgs: [sessionId]);
    }

    // Clean up empty global players
    await db.delete('global_players',
        where: 'total_score = 0 AND total_penalty = 0');

    // Clean up groups that no longer have any sessions
    for (final groupId in affectedGroupIds) {
      final remaining = await db.query('game_sessions', where: 'group_id = ?', whereArgs: [groupId]);
      if (remaining.isEmpty) {
        await db.delete('player_groups', where: 'id = ?', whereArgs: [groupId]);
      }
    }
  }

  Future<void> clearAllHistory() async {
    final db = await instance.database;
    await db.delete('session_turns');
    await db.delete('session_scores');
    await db.delete('game_sessions');
    await db.delete('global_players');
    await db.delete('player_groups');
  }

  Future<List<Map<String, dynamic>>> getSessionScores(int sessionId) async {
    final db = await database;
    return await db.query(
      'session_scores',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'score DESC',
    );
  }

  // Session Turns
  Future<void> insertSessionTurn(int sessionId, int roundNumber, String playerName, String content, int pointsChange) async {
    final db = await database;
    await db.insert('session_turns', {
      'session_id': sessionId,
      'round_number': roundNumber,
      'player_name': playerName,
      'content': content,
      'points_change': pointsChange,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSessionTurns(int sessionId) async {
    final db = await database;
    return await db.query(
      'session_turns',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
  }

  // Leaderboards


  Future<List<Map<String, dynamic>>> getGroupLeaderboard() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT g.id, g.name,
        COALESCE(SUM(st.points_change), 0) as total_score
      FROM player_groups g
      INNER JOIN game_sessions s ON s.group_id = g.id AND s.ended_at IS NOT NULL
      LEFT JOIN session_turns st ON st.session_id = s.id
      GROUP BY g.id, g.name
      ORDER BY total_score DESC, g.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getGroupLeaderboardByMode(String gameMode) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT g.id, g.name,
        COALESCE(SUM(st.points_change), 0) as total_score
      FROM player_groups g
      INNER JOIN game_sessions s ON s.group_id = g.id AND s.ended_at IS NOT NULL
      LEFT JOIN session_turns st ON st.session_id = s.id
      WHERE s.game_mode = ?
      GROUP BY g.id, g.name
      ORDER BY total_score DESC, g.name ASC
    ''', [gameMode]);
  }

  Future<List<Player>> getPlayersWithTotalScoreByGroup(int groupId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT p.id, p.group_id, p.name, p.avatar, p.penalty,
             COALESCE(SUM(st.points_change), 0) as score
      FROM players p
      LEFT JOIN game_sessions s ON s.group_id = p.group_id AND s.ended_at IS NOT NULL
      LEFT JOIN session_turns st ON st.session_id = s.id AND st.player_name = p.name
      WHERE p.group_id = ?
      GROUP BY p.id, p.group_id, p.name, p.avatar, p.penalty
      ORDER BY score DESC, p.penalty ASC, p.name ASC
    ''', [groupId]);
    return result.map((json) => Player.fromMap(json)).toList();
  }

  // Game Content Operations
  Future<List<GameContent>> getContentsByType(String type) async {
    final db = await instance.database;
    final result = await db.query(
      'game_contents',
      where: 'type = ? AND is_active = 1',
      whereArgs: [type],
    );
    return result.map((json) => GameContent.fromMap(json)).toList();
  }

  Future<void> toggleFavoriteGameContent(int id, bool isFavorite) async {
    final db = await instance.database;
    await db.update(
      'game_contents',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<GameContent>> getFavoriteContents() async {
    final db = await instance.database;
    final result = await db.query(
      'game_contents',
      where: 'is_favorite = 1 AND is_active = 1',
    );
    return result.map((json) => GameContent.fromMap(json)).toList();
  }

  // Global Player Operations
  Future<int> createGlobalPlayer(String name) async {
    final db = await instance.database;
    final data = {
      'name': name,
      'total_score': 0,
      'total_penalty': 0,
      'games_played': 0,
      'created_at': DateTime.now().toIso8601String(),
    };
    return await db.insert('global_players', data, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> addPointsToGlobalPlayer(String name, int scoreToAdd, int penaltyToAdd) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE global_players 
      SET total_score = total_score + ?, 
          total_penalty = total_penalty + ?
      WHERE name = ?
    ''', [scoreToAdd, penaltyToAdd, name]);
  }

  Future<List<Map<String, dynamic>>> getGlobalLeaderboard() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT g.* FROM global_players g
      WHERE EXISTS (
        SELECT 1 FROM players p WHERE p.name = g.name
      )
      ORDER BY g.total_score DESC, g.total_penalty ASC, g.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getGlobalLeaderboardByMode(String gameMode) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT st.player_name as name, SUM(st.points_change) as total_score
      FROM session_turns st
      JOIN game_sessions s ON st.session_id = s.id
      WHERE s.game_mode = ?
      GROUP BY st.player_name
      ORDER BY total_score DESC
    ''', [gameMode]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
