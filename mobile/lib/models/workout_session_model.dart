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
      muscles: (json['muscles'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'muscles': muscles, 'duration': duration};
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
    final rawTime = json['scheduled_time'] as String?;
    return WorkoutSession(
      id: json['id'] as int,
      programId: json['program_id'] as int?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      // Backend may return HH:mm:ss; the UI only ever needs HH:mm.
      scheduledTime: rawTime != null && rawTime.length >= 5
          ? rawTime.substring(0, 5)
          : rawTime,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      status: json['status'] as String,
      program: json['program'] != null
          ? WorkoutSessionProgram.fromJson(
              json['program'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_id': programId,
      'scheduled_date':
          '${scheduledDate.year.toString().padLeft(4, '0')}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}',
      'scheduled_time': scheduledTime,
      'completed_at': completedAt?.toIso8601String(),
      'status': status,
      'program': program?.toJson(),
    };
  }
}
