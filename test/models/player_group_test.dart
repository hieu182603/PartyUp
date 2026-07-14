import 'package:flutter_test/flutter_test.dart';
import 'package:party_up/models/player_group.dart';

void main() {
  group('PlayerGroup Model Tests', () {
    test('PlayerGroup creation should set createdAt automatically if not provided', () {
      final group = PlayerGroup(
        name: 'My Group',
      );

      expect(group.name, 'My Group');
      expect(group.id, isNull);
      expect(group.createdAt, isNotNull);
      // It should be created very recently
      expect(group.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });

    test('toMap() should return correct map representation', () {
      final date = DateTime(2023, 1, 1, 12, 0, 0);
      final group = PlayerGroup(
        id: 1,
        name: 'Friends',
        createdAt: date,
      );

      final map = group.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Friends');
      expect(map['created_at'], date.toIso8601String());
    });

    test('fromMap() should create PlayerGroup from map', () {
      final dateString = '2023-12-25T10:00:00.000';
      final map = {
        'id': 2,
        'name': 'Family',
        'created_at': dateString,
      };

      final group = PlayerGroup.fromMap(map);

      expect(group.id, 2);
      expect(group.name, 'Family');
      expect(group.createdAt, DateTime.parse(dateString));
    });
  });
}
