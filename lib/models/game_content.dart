class GameContent {
  final int? id;
  final String content;
  final String type; // 'truth', 'dare', 'rule'
  final String level; // 'nhẹ', 'vui', 'lầy'
  final String category; // 'Tổng hợp', 'Tình yêu', 'Tình bạn'...
  final bool isCustom;
  final bool isActive;
  final bool isFavorite;
  final String? penaltyText;
  final int points;

  GameContent({
    this.id,
    required this.content,
    required this.type,
    required this.level,
    this.category = 'Tổng hợp',
    this.isCustom = false,
    this.isActive = true,
    this.isFavorite = false,
    this.penaltyText,
    int? points,
  }) : points = points ?? 20;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'level': level,
      'category': category,
      'is_custom': isCustom ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'penalty_text': penaltyText,
      'points': points,
    };
  }

  factory GameContent.fromMap(Map<String, dynamic> map) {
    return GameContent(
      id: map['id'],
      content: map['content'] as String,
      type: map['type'] as String,
      level: map['level'] as String,
      category: map['category'] as String? ?? 'Tổng hợp',
      isCustom: (map['is_custom'] as int?) == 1,
      isActive: (map['is_active'] as int?) == 1,
      isFavorite: map['is_favorite'] == 1,
      penaltyText: map['penalty_text'],
      points: map['points'],
    );
  }
}
