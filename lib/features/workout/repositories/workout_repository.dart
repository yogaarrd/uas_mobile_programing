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
    String? description, 
    required List<dynamic> exercises, 
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    String currentTemplateId;

    if (templateId == null) {
      final resp = await _supabase.from('workout_templates').insert({
        'user_id': userId,
        'name': name,
        'description': description, 
      }).select().single();
      currentTemplateId = resp['id'];
    } else {
      await _supabase.from('workout_templates').update({
        'name': name,
        'description': description, 
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

  // === FITUR BARU: HAPUS WORKOUT ===
  Future<void> deleteWorkoutTemplate(String templateId) async {
    // Relasi ON DELETE CASCADE di database akan otomatis menghapus 
    // data di template_exercises dan exercise_sets terkait
    await _supabase.from('workout_templates').delete().eq('id', templateId);
  }

  // === FITUR BARU: SIMPAN SESI & DETEKSI PR ===
  Future<Map<String, dynamic>> saveWorkoutSession({
    required String? templateId,
    required String name,
    required int durationSeconds,
    required double totalVolume,
    required List<Map<String, dynamic>> exercisesData,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    List<String> prMessages = [];

    // 1. DETEKSI PERSONAL RECORD (PR)
    for (var ex in exercisesData) {
      final exId = ex['exercise_id'];
      final currentMaxWeight = ex['max_weight'] as double;

      if (currentMaxWeight > 0) {
        // Ambil riwayat beban dari database untuk latihan & user ini
        final pastExercisesResp = await _supabase
            .from('session_exercises')
            .select('session_sets(weight, is_completed), workout_sessions!inner(user_id)')
            .eq('exercise_id', exId)
            .eq('workout_sessions.user_id', userId);

        double historicalMax = 0;
        for (var pe in pastExercisesResp) {
          for (var s in pe['session_sets']) {
            if (s['is_completed'] == true && s['weight'] != null) {
              final w = (s['weight'] as num).toDouble();
              if (w > historicalMax) historicalMax = w;
            }
          }
        }

        // Bandingkan beban sekarang dengan beban tertinggi sebelumnya
        if (currentMaxWeight > historicalMax) {
          String displayWeight = currentMaxWeight.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
          if (historicalMax == 0) {
            prMessages.add('Latihan Perdana! ${ex['exercise_name']} $displayWeight kg');
          } else {
            prMessages.add('New PR! ${ex['exercise_name']} $displayWeight kg 🏆');
          }
        }
      }
    }

    // 2. SIMPAN WORKOUT SESSION
    final sessionResp = await _supabase.from('workout_sessions').insert({
      'user_id': userId,
      'template_id': templateId,
      'name': name,
      'duration_seconds': durationSeconds,
      'total_volume_kg': totalVolume,
    }).select().single();

    final sessionId = sessionResp['id'];

    // 3. SIMPAN EXERCISES DAN SETS
    for (int i = 0; i < exercisesData.length; i++) {
      final ex = exercisesData[i];
      final seResp = await _supabase.from('session_exercises').insert({
        'session_id': sessionId,
        'exercise_id': ex['exercise_id'],
        'order_index': i
      }).select().single();

      final seId = seResp['id'];
      final sets = ex['sets'] as List;

      if (sets.isNotEmpty) {
        final setsToInsert = sets.map((s) => {
          'session_exercise_id': seId,
          'set_number': s['set_number'],
          'reps': s['reps'],
          'weight': s['weight'],
          'is_completed': s['is_completed'],
          'completed_at': s['is_completed'] ? DateTime.now().toIso8601String() : null,
        }).toList();
        await _supabase.from('session_sets').insert(setsToInsert);
      }
    }

    return {
      'session_id': sessionId,
      'pr_messages': prMessages,
    };
    
  }
  Future<void> syncTemplateWithSession(String templateId, List<Map<String, dynamic>> exercisesData) async {
    // 1. Hapus relasi latihan lama pada template tersebut (CASCADE akan menghapus sets otomatis)
    await _supabase.from('template_exercises').delete().eq('template_id', templateId);

    // 2. Insert relasi latihan dan set yang baru sesuai sesi terakhir
    for (int i = 0; i < exercisesData.length; i++) {
      final ex = exercisesData[i];
      final teResp = await _supabase.from('template_exercises').insert({
        'template_id': templateId,
        'exercise_id': ex['exercise_id'],
        'order_index': i,
      }).select().single();

      final teId = teResp['id'];
      final sets = ex['sets'] as List;

      if (sets.isNotEmpty) {
        final setsToInsert = sets.map((s) => {
          'template_exercise_id': teId,
          'set_number': s['set_number'],
          'reps': s['reps'],
          'weight': s['weight'],
          'rest_seconds': s['rest_seconds'] ?? 60, // Membawa waktu rest
        }).toList();
        await _supabase.from('exercise_sets').insert(setsToInsert);
      }
    }
  }
}