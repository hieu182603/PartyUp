class GlobalPlayer {
  final int? id;
  final String name;
  final int totalScore;
  final int totalPenalty;
  final int gamesPlayed;
  final String createdAt;

  GlobalPlayer({
    this.id,
    required this.name,
    this.totalScore = 0,
    this.totalPenalty = 0,
    this.gamesPlayed = 0,
    required this.createdAt,
  });

  factory GlobalPlayer.fromMap(Map<String, dynamic> map) {
    return GlobalPlayer(
      id: map['id'],
      name: map['name'],
      totalScore: map['total_score'] ?? 0,
      totalPenalty: map['total_penalty'] ?? 0,
      gamesPlayed: map['games_played'] ?? 0,
      createdAt: map['created_at'],
    );
  }
}
