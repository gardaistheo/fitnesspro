class Exercise {
  final int id;
  final String name;
  final String category;
  final List<String> muscles;
  final String difficulty;
  final String? description;
  final List<String> instructions;
  final String? youtubeUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscles,
    required this.difficulty,
    this.description,
    required this.instructions,
    this.youtubeUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      muscles: (json['muscles'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      difficulty: json['difficulty'] as String,
      description: json['description'] as String?,
      instructions: (json['instructions'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      youtubeUrl: json['youtube_url'] as String?,
    );
  }
}
