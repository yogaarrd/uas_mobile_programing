import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// TODO: Sesuaikan path modelmu
import '../models/session_detail_model.dart';

// Menggunakan .family karena kita butuh melempar ID sesi yang di-klik
final sessionDetailProvider = FutureProvider.family<List<SessionExerciseDetail>, String>((ref, sessionId) async {
  final supabase = Supabase.instance.client;
  
  // Melakukan JOIN otomatis ke tabel exercises dan session_sets
  final response = await supabase
      .from('session_exercises')
      .select('''
        id,
        order_index,
        exercises ( name ),
        session_sets ( set_number, reps, weight )
      ''')
      .eq('session_id', sessionId)
      .order('order_index', ascending: true);

  return (response as List).map((exData) {
    // Ambil nama latihan
    final exerciseName = exData['exercises']['name'] as String;
    
    // Ambil dan petakan data set
    final setsRaw = exData['session_sets'] as List<dynamic>;
    final sets = setsRaw.map((setData) => SessionSetDetail.fromJson(setData)).toList();
    
    // Urutkan berdasarkan set_number untuk berjaga-jaga
    sets.sort((a, b) => a.setNumber.compareTo(b.setNumber));

    return SessionExerciseDetail(
      exerciseName: exerciseName,
      sets: sets,
    );
  }).toList();
});