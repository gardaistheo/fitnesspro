class QuizData {
  String? level;
  String? goal;
  String currentWeight;
  String targetWeight;
  List<String> availableDays;
  double hoursPerDay;
  String? location;
  List<String> equipment;
  int caloriesIn;
  int caloriesOut;

  QuizData({
    this.level,
    this.goal,
    this.currentWeight = '75',
    this.targetWeight = '70',
    List<String>? availableDays,
    this.hoursPerDay = 1.5,
    this.location,
    List<String>? equipment,
    this.caloriesIn = 2000,
    this.caloriesOut = 400,
  }) : availableDays = availableDays ?? ['Lun', 'Mer', 'Ven'],
       equipment = equipment ?? [];
}
