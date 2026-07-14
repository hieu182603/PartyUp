import 'package:flutter_test/flutter_test.dart';
import 'package:party_up/models/player.dart';

void main() {
  group('Player Model Tests', () {
    test('Player creation should set default values correctly', () {
      final player = Player(
        groupId: 1,
        name: 'Alice',
      );

      expect(player.groupId, 1);
      expect(player.name, 'Alice');
      expect(player.score, 0);
      expect(player.penalty, 0);
      expect(player.id, isNull);
      expect(player.avatar, isNull);
    });

    test('toMap() should return correct map representation', () {
      final player = Player(
        id: 1,
        groupId: 10,
        name: 'Bob',
        avatar: 'avatar.png',
        score: 5,
        penalty: 2,
      );

      final map = player.toMap();

      expect(map['id'], 1);
      expect(map['group_id'], 10);
      expect(map['name'], 'Bob');
      expect(map['avatar'], 'avatar.png');
      expect(map['score'], 5);
      expect(map['penalty'], 2);
    });

    test('fromMap() should create Player from map', () {
      final map = {
        'id': 2,
        'group_id': 20,
        'name': 'Charlie',
        'avatar': 'charlie.png',
        'score': 10,
        'penalty': 1,
      };

      final player = Player.fromMap(map);

      expect(player.id, 2);
      expect(player.groupId, 20);
      expect(player.name, 'Charlie');
      expect(player.avatar, 'charlie.png');
      expect(player.score, 10);
      expect(player.penalty, 1);
    });
    
    test('fromMap() should handle missing score and penalty with defaults', () {
      final map = {
        'id': 3,
        'group_id': 30,
        'name': 'Dave',
      };

      final player = Player.fromMap(map);

      expect(player.score, 0);
      expect(player.penalty, 0);
    });

    test('copyWith() should update specified fields and retain others', () {
      final player = Player(
        id: 1,
        groupId: 10,
        name: 'Eve',
        score: 0,
        penalty: 0,
      );

      final updatedPlayer = player.copyWith(
        score: 10,
        avatar: 'eve.png',
      );

      expect(updatedPlayer.id, 1);
      expect(updatedPlayer.groupId, 10);
      expect(updatedPlayer.name, 'Eve');
      expect(updatedPlayer.score, 10);
      expect(updatedPlayer.penalty, 0);
      expect(updatedPlayer.avatar, 'eve.png');
    });
  });
}
