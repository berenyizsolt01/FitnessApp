class Exercise {
  final int id;
  final String nameHU;
  final String descriptionHU;
  final String targetMuscle;

  Exercise({
    required this.id,
    required this.nameHU,
    required this.descriptionHU,
    required this.targetMuscle,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      nameHU: json['nameHU'] ?? '',
      descriptionHU: json['descriptionHU'] ?? '',
      targetMuscle: json['targetMuscle'] ?? '',
    );
  }
}
