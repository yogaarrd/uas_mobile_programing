import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise_models.dart';

class ExerciseRepository {
  final _supabase = Supabase.instance.client;

  Future<List<ExerciseModel>> getExercises() async {
    print("--- SEDANG MENGAMBIL DATA DARI SUPABASE ---");
    try {
      final response = await _supabase.from('exercises').select();
      print("--- BERHASIL! JUMLAH DATA: ${response.length} ---");
      
      return (response as List).map((e) => ExerciseModel.fromMap(e)).toList();
    } catch (e) {
      print("--- ERROR: $e ---");
      return [];
    }
  }
}