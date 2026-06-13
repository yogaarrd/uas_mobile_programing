import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/exercise_repository.dart';
// Pastikan nama import modelnya sesuai dengan file kamu (pakai 's' atau tidak)
import '../models/exercise_models.dart'; 

// 1. Provider untuk Repository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

// 2. FutureProvider HANYA bertugas mengambil data mentah dari Supabase
final exercisesFutureProvider = FutureProvider<List<ExerciseModel>>((ref) async {
  final repository = ref.read(exerciseRepositoryProvider);
  return repository.getExercises();
});