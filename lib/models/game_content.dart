class GameContent {
  final int? id;
  final String content;
  final String type; // 'truth', 'dare', 'rule'
  final String level; // 'light', 'fun', 'hardcore'
  final bool isCustom;
  final bool isActive;

  GameContent({
    this.id,
    required this.content,
    required this.type,
    required this.level,
    this.isCustom = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'level': level,
      'is_custom': isCustom ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory GameContent.fromMap(Map<String, dynamic> map) {
    return GameContent(
      id: map['id'],
      content: map['content'],
      type: map['type'],
      level: map['level'],
      isCustom: map['is_custom'] == 1,
      isActive: map['is_active'] == 1,
    );
  }
}
