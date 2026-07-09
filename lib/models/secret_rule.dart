class SecretRule {
  final int id;
  final String content;
  final String level;

  SecretRule({
    required this.id,
    required this.content,
    required this.level,
  });

  factory SecretRule.fromJson(Map<String, dynamic> json) {
    return SecretRule(
      id: json['id'] as int,
      content: json['content'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'level': level,
    };
  }
}
