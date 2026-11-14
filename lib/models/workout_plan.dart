class WorkoutPlan {
  final int id;
  final String name;
  final String? description;

  WorkoutPlan({
    required this.id,
    required this.name,
    this.description,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}
