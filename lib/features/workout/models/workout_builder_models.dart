import 'dart:math';
import 'exercise_models.dart';

// Fungsi bantuan agar tidak perlu menginstal package uuid eksternal
String generateUniqueId() => 
    '${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(10000)}';

class ExerciseSetFormData {
  int reps;
  double weight;
  int restSeconds;

  ExerciseSetFormData({
    this.reps = 10,
    this.weight = 0.0,
    this.restSeconds = 60,
  });

  ExerciseSetFormData copyWith({
    int? reps,
    double? weight,
    int? restSeconds,
  }) {
    return ExerciseSetFormData(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}

class TemplateExerciseFormData {
  final String uniqueId; // Dibutuhkan sebagai Key untuk ReorderableListView
  final ExerciseModel exercise;
  List<ExerciseSetFormData> sets;

  TemplateExerciseFormData({
    required this.uniqueId,
    required this.exercise,
    required this.sets,
  });
}