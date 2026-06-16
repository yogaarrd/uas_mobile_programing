class SessionSetDetail {
  final int setNumber;
  final int reps;
  final double weight;

  SessionSetDetail({
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  factory SessionSetDetail.fromJson(Map<String, dynamic> json) {
    return SessionSetDetail(
      setNumber: json['set_number'] as int,
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SessionExerciseDetail {
  final String exerciseName;
  final List<SessionSetDetail> sets;

  SessionExerciseDetail({
    required this.exerciseName,
    required this.sets,
  });
}