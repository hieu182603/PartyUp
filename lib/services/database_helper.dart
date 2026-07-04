import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/player_group.dart';
import '../models/player.dart';
import '../models/game_content.dart';

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
      return await openDatabase(path, version: 1, onCreate: _createDB);
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE player_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE players (
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
      CREATE TABLE game_contents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        level TEXT NOT NULL,
        is_custom INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        penalty_text TEXT,
        points INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE game_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        game_mode TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        FOREIGN KEY (group_id) REFERENCES player_groups (id) ON DELETE CASCADE
      )
    ''');

    // Bơm dữ liệu mẫu
    await _insertDefaultGameContent(db);
  }

  Future _insertDefaultGameContent(Database db) async {
    final contents = [
      // THẬT (Truth)
      GameContent(
        content: 'Trong nhóm này, bạn tin tưởng ai nhất?',
        type: 'truth',
        level: 'fun',
        penaltyText: 'Hát một bài hát thiếu nhi trong 30 giây',
        points: 20,
      ),
      GameContent(
        content: 'Lần xấu hổ nhất của bạn là gì?',
        type: 'truth',
        level: 'fun',
        penaltyText: 'Nhảy lò cò và kêu cục ta cục tác 5 lần',
        points: 20,
      ),
      GameContent(
        content: 'Bạn đã từng tỏ tình thất bại bao giờ chưa?',
        type: 'truth',
        level: 'fun',
        penaltyText: 'Đứng nghiêm chào kiểu bộ đội trong 20 giây',
        points: 20,
      ),
      GameContent(
        content: 'Có ai trong nhóm này mà bạn từng crush chưa?',
        type: 'truth',
        level: 'hardcore',
        penaltyText: 'Nhắn tin cho crush hoặc người yêu cũ "Em/Anh nhớ anh/em"',
        points: 20,
      ),
      GameContent(
        content: 'Nói ra một bí mật mà bạn giấu bố mẹ.',
        type: 'truth',
        level: 'hardcore',
        penaltyText: 'Múa quạt hoặc nhảy Tiktok trong 15 giây',
        points: 20,
      ),
      GameContent(
        content: 'Tật xấu lớn nhất của bạn khi ngủ là gì?',
        type: 'truth',
        level: 'fun',
        penaltyText: 'Làm động tác như đang ngủ say và ngáy ngủ to 10 giây',
        points: 20,
      ),
      GameContent(
        content: 'Bạn từng giả vờ ốm để trốn học/trốn làm chưa?',
        type: 'truth',
        level: 'light',
        penaltyText: 'Khen 3 người trong nhóm một câu chân thành nhất',
        points: 20,
      ),
      GameContent(
        content: 'Hãy kể về một lần bạn "bốc phét" bị phát hiện.',
        type: 'truth',
        level: 'fun',
        penaltyText: 'Cho người bên phải bẹo má trong 10 giây',
        points: 20,
      ),
      
      // THÁCH (Dare)
      GameContent(
        content: 'Hát một bài hát thiếu nhi bằng giọng "chảy nước".',
        type: 'dare',
        level: 'fun',
        penaltyText: 'Uống hết một cốc nước lọc liên tục không nghỉ',
        points: 20,
      ),
      GameContent(
        content: 'Múa quạt hoặc nhảy Tiktok trong 15 giây.',
        type: 'dare',
        level: 'fun',
        penaltyText: 'Chống đẩy 10 cái tại chỗ',
        points: 20,
      ),
      GameContent(
        content: 'Chụp một tấm ảnh tự sướng làm mặt xấu nhất có thể và gửi vào group chat.',
        type: 'dare',
        level: 'hardcore',
        penaltyText: 'Uống một hớp nước mắm hoặc ngậm chanh trong 10 giây',
        points: 20,
      ),
      GameContent(
        content: 'Khen từng người trong nhóm một câu (không được giả trân).',
        type: 'dare',
        level: 'light',
        penaltyText: 'Đứng lò cò một chân trong 30 giây tiếp theo',
        points: 20,
      ),
      GameContent(
        content: 'Đổi avatar Facebook thành hình dìm của mình trong 1 ngày.',
        type: 'dare',
        level: 'hardcore',
        penaltyText: 'Đứng dậy hô to "Tôi là kẻ ngốc nhất thế gian!" 3 lần',
        points: 20,
      ),
      GameContent(
        content: 'Nhắn tin cho người yêu cũ (hoặc crush) với nội dung "Em/Anh dạo này ổn không?".',
        type: 'dare',
        level: 'hardcore',
        penaltyText: 'Mát-xa vai cho người ngồi bên phải trong 1 phút',
        points: 20,
      ),
      GameContent(
        content: 'Uống một ly nước lọc pha với một chút... nước mắm (hoặc chanh).',
        type: 'dare',
        level: 'hardcore',
        penaltyText: 'Hát một đoạn nhạc rap bất kỳ',
        points: 20,
      ),
      GameContent(
        content: 'Đứng lên, chắp tay và hô to: "Tôi là kẻ ngốc nhất thế gian!" 3 lần.',
        type: 'dare',
        level: 'fun',
        penaltyText: 'Để người bên trái vẽ một nét mực mèo lên má',
        points: 20,
      ),
      GameContent(
        content: 'Đưa điện thoại của bạn cho người bên phải, họ được quyền xem lịch sử duyệt web trong 30 giây.',
        type: 'dare',
        level: 'hardcore',
        penaltyText: 'Kể chuyện cười hoặc làm trò cười trong 30 giây',
        points: 20,
      ),

      // LUẬT BÍ MẬT (Rule)
      GameContent(
        content: 'Không được nói từ "Không".',
        type: 'rule',
        level: 'fun',
        penaltyText: 'Nhảy múa tự do trong 15 giây',
        points: 20,
      ),
      GameContent(
        content: 'Phải kết thúc mỗi câu nói bằng từ "meo".',
        type: 'rule',
        level: 'fun',
        penaltyText: 'Kêu tiếng mèo kêu meo meo 5 lần',
        points: 20,
      ),
      GameContent(
        content: 'Chỉ được dùng câu hỏi để giao tiếp.',
        type: 'rule',
        level: 'hardcore',
        penaltyText: 'Đọc bảng chữ cái từ Z về A trong 20 giây',
        points: 20,
      ),
      GameContent(
        content: 'Khi ai đó gọi tên, bạn phải làm động tác chào cờ.',
        type: 'rule',
        level: 'fun',
        penaltyText: 'Chống đẩy 5 cái',
        points: 20,
      ),
      GameContent(
        content: 'Không được cười lộ răng.',
        type: 'rule',
        level: 'hardcore',
        penaltyText: 'Đóng vai một con khỉ trong 15 giây',
        points: 20,
      ),
    ];

    for (var content in contents) {
      await db.insert('game_contents', content.toMap());
    }
  }

  // Group Operations
  Future<int> createGroup(PlayerGroup group) async {
    final db = await instance.database;
    return await db.insert('player_groups', group.toMap());
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

  // Game Content Operations
  Future<List<GameContent>> getContentsByType(String type) async {
    final db = await instance.database;
    final result = await db.query('game_contents', where: 'type = ? AND is_active = 1', whereArgs: [type]);
    return result.map((json) => GameContent.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
