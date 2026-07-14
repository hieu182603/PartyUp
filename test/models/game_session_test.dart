import 'package:flutter_test/flutter_test.dart';
import 'package:party_up/models/game_session.dart';

void main() {
  group('GameSession Model Tests', () {
    test('GameSession creation should set startedAt automatically if not provided', () {
      final session = GameSession(
        groupId: 1,
        gameMode: 'truth_or_dare',
      );

      expect(session.groupId, 1);
      expect(session.gameMode, 'truth_or_dare');
      expect(session.id, isNull);
      expect(session.endedAt, isNull);
      expect(session.startedAt, isNotNull);
      expect(session.startedAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });

    test('toMap() should return correct map representation without endedAt', () {
      final date = DateTime(2023, 1, 1, 12, 0, 0);
      final session = GameSession(
        id: 1,
        groupId: 10,
        gameMode: 'truth_or_dare',
        startedAt: date,
      );

      final map = session.toMap();

      expect(map['id'], 1);
      expect(map['group_id'], 10);
      expect(map['game_mode'], 'truth_or_dare');
      expect(map['started_at'], date.toIso8601String());
      expect(map['ended_at'], isNull);
    });

    test('toMap() should return correct map representation with endedAt', () {
      final startDate = DateTime(2023, 1, 1, 12, 0, 0);
      final endDate = DateTime(2023, 1, 1, 13, 0, 0);
      final session = GameSession(
        id: 2,
        groupId: 20,
        gameMode: 'secret_rule',
        startedAt: startDate,
        endedAt: endDate,
      );

      final map = session.toMap();

      expect(map['id'], 2);
      expect(map['group_id'], 20);
      expect(map['game_mode'], 'secret_rule');
      expect(map['started_at'], startDate.toIso8601String());
      expect(map['ended_at'], endDate.toIso8601String());
    });

    test('fromMap() should create GameSession from map without endedAt', () {
      final dateString = '2023-12-25T10:00:00.000';
      final map = {
        'id': 3,
        'group_id': 30,
        'game_mode': 'truth_or_dare',
        'started_at': dateString,
      };

      final session = GameSession.fromMap(map);

      expect(session.id, 3);
      expect(session.groupId, 30);
      expect(session.gameMode, 'truth_or_dare');
      expect(session.startedAt, DateTime.parse(dateString));
      expect(session.endedAt, isNull);
    });

    test('fromMap() should create GameSession from map with endedAt', () {
      final startDateString = '2023-12-25T10:00:00.000';
      final endDateString = '2023-12-25T11:00:00.000';
      final map = {
        'id': 4,
        'group_id': 40,
        'game_mode': 'secret_rule',
        'started_at': startDateString,
        'ended_at': endDateString,
      };

      final session = GameSession.fromMap(map);

      expect(session.id, 4);
      expect(session.groupId, 40);
      expect(session.gameMode, 'secret_rule');
      expect(session.startedAt, DateTime.parse(startDateString));
      expect(session.endedAt, DateTime.parse(endDateString));
    });
  });
}
