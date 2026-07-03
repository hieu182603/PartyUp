class PlayerGroup {
  final int? id;
  final String name;
  final DateTime createdAt;

  PlayerGroup({
    this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PlayerGroup.fromMap(Map<String, dynamic> map) {
    return PlayerGroup(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
