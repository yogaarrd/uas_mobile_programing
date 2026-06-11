class WorkoutTemplate {
  final String id;
  final String name;
  final String? description;
  final int exerciseCount;
  final List<String> muscleGroups;

  WorkoutTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.exerciseCount,
    required this.muscleGroups,
  });

  // Mapping dari response JSON Supabase ke Object Dart
  factory WorkoutTemplate.fromMap(Map<String, dynamic> map) {
    int count = 0;
    Set<String> muscles = {};

    // Supabase mengembalikan relasi dalam bentuk List map
    if (map['template_exercises'] != null) {
      final exercises = map['template_exercises'] as List;
      count = exercises.length;
      
      // Mengekstrak muscle_group dari tabel exercises yang terhubung
      for (var ex in exercises) {
        if (ex['exercises'] != null && ex['exercises']['muscle_group'] != null) {
          muscles.add(ex['exercises']['muscle_group'].toString());
        }
      }
    }

    return WorkoutTemplate(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      exerciseCount: count,
      muscleGroups: muscles.toList(),
    );
  }
}