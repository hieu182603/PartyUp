class Player {
  final int? id;
  final int groupId;
  final String name;
  final String? avatar;
  int score;
  int penalty;

  Player({
    this.id,
    required this.groupId,
    required this.name,
    this.avatar,
    this.score = 0,
    this.penalty = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'name': name,
      'avatar': avatar,
      'score': score,
      'penalty': penalty,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      groupId: map['group_id'],
      name: map['name'],
      avatar: map['avatar'],
      score: map['score'] ?? 0,
      penalty: map['penalty'] ?? 0,
    );
  }

  Player copyWith({
    int? id,
    int? groupId,
    String? name,
    String? avatar,
    int? score,
    int? penalty,
  }) {
    return Player(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      score: score ?? this.score,
      penalty: penalty ?? this.penalty,
    );
  }
}
