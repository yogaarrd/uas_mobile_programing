import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_template.dart';

class WorkoutRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<WorkoutTemplate>> getWorkoutTemplates() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    final response = await _supabase
        .from('workout_templates')
        .select('id, name, description, template_exercises (id, exercises (muscle_group))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => WorkoutTemplate.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> getWorkoutTemplateById(String id) async {
    return await _supabase
        .from('workout_templates')
        .select('id, name, description, template_exercises (id, order_index, exercises (*), exercise_sets (*))')
        .eq('id', id)
        .single();
  }

  Future<void> saveWorkoutTemplate({
    String? templateId,
    required String name,
    String? description, // TAMBAHAN: Kolom deskripsi
    required List<dynamic> exercises, 
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    String currentTemplateId;

    if (templateId == null) {
      final resp = await _supabase.from('workout_templates').insert({
        'user_id': userId,
        'name': name,
        'description': description, // TAMBAHAN
      }).select().single();
      currentTemplateId = resp['id'];
    } else {
      await _supabase.from('workout_templates').update({
        'name': name,
        'description': description, // TAMBAHAN
      }).eq('id', templateId);
      currentTemplateId = templateId;
      await _supabase.from('template_exercises').delete().eq('template_id', templateId);
    }

    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      final teResp = await _supabase.from('template_exercises').insert({
        'template_id': currentTemplateId,
        'exercise_id': ex.exercise.id,
        'order_index': i,
      }).select().single();

      final teId = teResp['id'];

      final setsData = ex.sets.asMap().entries.map((entry) => {
        'template_exercise_id': teId,
        'set_number': entry.key + 1,
        'reps': entry.value.reps,
        'weight': entry.value.weight,
        'rest_seconds': entry.value.restSeconds,
      }).toList();

      if (setsData.isNotEmpty) {
        await _supabase.from('exercise_sets').insert(setsData);
      }
    }
  }
}