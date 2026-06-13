class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final List<String> secondaryMuscles;
  final String equipment;
  final String instructions;
  final String? imageUrl;
  final bool isCustom;
  final String? createdBy;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.secondaryMuscles,
    required this.equipment,
    required this.instructions,
    this.imageUrl,
    required this.isCustom,
    this.createdBy,
  });

  // Mapping dari response JSON Supabase ke Object Dart
  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'].toString(), 
      name: map['name'] ?? 'Unknown',
      muscleGroup: map['muscle_group'] ?? 'other',
      secondaryMuscles: List<String>.from(map['secondary_muscles'] ?? []),
      equipment: map['equipment'] ?? 'bodyweight',
      instructions: map['instructions'] ?? '',
      imageUrl: map['image_url'],
      isCustom: map['is_custom'] ?? false,
      createdBy: map['created_by'],
    );
  }
}