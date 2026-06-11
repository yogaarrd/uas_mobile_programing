import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/workout_repository.dart';
import '../models/workout_template.dart';

// Provider untuk Repository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

// FutureProvider untuk mengambil list template (langsung menghandle state loading/error/data)
final workoutTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repository = ref.read(workoutRepositoryProvider);
  return repository.getWorkoutTemplates();
});