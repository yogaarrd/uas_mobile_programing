import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_template.dart';

class WorkoutRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<WorkoutTemplate>> getWorkoutTemplates() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    // Mengambil data template sekaligus JOIN dengan tabel relasinya
    final response = await _supabase
        .from('workout_templates')
        .select('''
          id,
          name,
          description,
          template_exercises (
            id,
            exercises (
              muscle_group
            )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    // Map setiap row menjadi object WorkoutTemplate
    return (response as List).map((e) => WorkoutTemplate.fromMap(e)).toList();
  }
}