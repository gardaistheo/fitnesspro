class Meal {
  final int id;
  final String name;
  final int calories;
  final int proteins;
  final int carbs;
  final int fats;
  final DateTime loggedAt;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.loggedAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as int,
      name: json['name'] as String,
      calories: json['calories'] as int,
      proteins: json['proteins'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fats: json['fats'] as int? ?? 0,
      loggedAt: DateTime.parse(json['logged_at'] as String),
    );
  }
}
