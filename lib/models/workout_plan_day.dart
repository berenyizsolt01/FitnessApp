class WorkoutPlanDay {
  final int id;
  final int dayNumber;
  final String dayName;

  WorkoutPlanDay({
    required this.id,
    required this.dayNumber,
    required this.dayName,
  });

  factory WorkoutPlanDay.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanDay(
      id: json['id'],
      dayNumber: json['dayNumber'],
      dayName: json['dayName'] ?? '',
    );
  }
}
