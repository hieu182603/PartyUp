class GameSession {
  final int? id;
  final int groupId;
  final String gameMode; // 'truth_or_dare', 'secret_rule'
  final DateTime startedAt;
  final DateTime? endedAt;

  GameSession({
    this.id,
    required this.groupId,
    required this.gameMode,
    DateTime? startedAt,
    this.endedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'game_mode': gameMode,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'],
      groupId: map['group_id'],
      gameMode: map['game_mode'],
      startedAt: DateTime.parse(map['started_at']),
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at']) : null,
    );
  }
}
