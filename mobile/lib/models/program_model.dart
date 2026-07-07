class ProgramExerciseItem {
  final int exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final int order;

  ProgramExerciseItem({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.order,
  });

  factory ProgramExerciseItem.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] as Map<String, dynamic>? ?? {};
    return ProgramExerciseItem(
      exerciseId: json['id'] as int,
      exerciseName: json['name'] as String,
      sets: pivot['sets'] as int? ?? 0,
      reps: pivot['reps'] as int? ?? 0,
      order: pivot['order'] as int? ?? 0,
    );
  }
}

class Program {
  final int id;
  final String name;
  final List<String> muscles;
  final String difficulty;
  final int? duration;
  final String? description;
  final List<ProgramExerciseItem> exercises;

  Program({
    required this.id,
    required this.name,
    required this.muscles,
    required this.difficulty,
    this.duration,
    this.description,
    required this.exercises,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'] as List<dynamic>? ?? [];
    return Program(
      id: json['id'] as int,
      name: json['name'] as String,
      muscles: (json['muscles'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      difficulty: json['difficulty'] as String,
      duration: json['duration'] as int?,
      description: json['description'] as String?,
      exercises: exercisesJson
          .map((e) => ProgramExerciseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
