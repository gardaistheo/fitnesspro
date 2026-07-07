class WorkoutSessionProgram {
  final int id;
  final String name;
  final List<String> muscles;
  final int? duration;

  WorkoutSessionProgram({
    required this.id,
    required this.name,
    required this.muscles,
    this.duration,
  });

  factory WorkoutSessionProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionProgram(
      id: json['id'] as int,
      name: json['name'] as String,
      muscles: (json['muscles'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      duration: json['duration'] as int?,
    );
  }
}

class WorkoutSession {
  final int id;
  final int? programId;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final DateTime? completedAt;
  final String status;
  final WorkoutSessionProgram? program;

  WorkoutSession({
    required this.id,
    this.programId,
    required this.scheduledDate,
    this.scheduledTime,
    this.completedAt,
    required this.status,
    this.program,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as int,
      programId: json['program_id'] as int?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledTime: json['scheduled_time'] as String?,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      status: json['status'] as String,
      program: json['program'] != null
          ? WorkoutSessionProgram.fromJson(json['program'] as Map<String, dynamic>)
          : null,
    );
  }
}
