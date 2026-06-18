import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/progress_models.dart';

class ProgressRepository {
  final _supabase = Supabase.instance.client;

  Future<ProgressOverviewData> getProgressOverview() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    // 1. AMBIL SEMUA SESI LATIHAN UNTUK STATISTIK
    final sessionsResp = await _supabase
        .from('workout_sessions')
        .select('started_at, duration_seconds, total_volume_kg')
        .eq('user_id', userId);

    int totalSessions = sessionsResp.length;
    double totalVolume = 0;
    int totalDuration = 0;
    DateTime? firstSessionDate;

    for (var s in sessionsResp) {
      totalVolume += (s['total_volume_kg'] as num?)?.toDouble() ?? 0;
      totalDuration += (s['duration_seconds'] as int?) ?? 0;
      
      final date = DateTime.parse(s['started_at']);
      if (firstSessionDate == null || date.isBefore(firstSessionDate)) {
        firstSessionDate = date;
      }
    }

    // Kalkulasi rata-rata per minggu
    double avgPerWeek = 0;
    if (totalSessions > 0 && firstSessionDate != null) {
      final daysDiff = DateTime.now().difference(firstSessionDate).inDays;
      final weeks = (daysDiff / 7).ceil();
      int effectiveWeeks = weeks < 1 ? 1 : weeks;
      avgPerWeek = totalSessions / effectiveWeeks;
    }

    final stats = ProgressStats(
      totalSessions: totalSessions,
      totalVolume: totalVolume,
      totalDurationSeconds: totalDuration,
      avgSessionsPerWeek: avgPerWeek,
    );

    // 2. AMBIL DAFTAR EXERCISE YANG PERNAH DILAKUKAN
    // Lakukan Inner Join dengan workout_sessions untuk memfilter berdasarkan user_id
    final exercisesResp = await _supabase
        .from('session_exercises')
        .select('exercise_id, exercises(id, name, muscle_group, image_url), workout_sessions!inner(user_id)')
        .eq('workout_sessions.user_id', userId);

    final Map<String, PerformedExercise> uniqueExercises = {};

    for (var row in exercisesResp) {
      final exData = row['exercises'];
      if (exData != null) {
        final id = exData['id'].toString();
        // Menggunakan Map untuk memastikan datanya unique (tidak duplikat)
        if (!uniqueExercises.containsKey(id)) {
          uniqueExercises[id] = PerformedExercise(
            id: id,
            name: exData['name'] ?? 'Unknown',
            muscleGroup: exData['muscle_group'] ?? '',
            imageUrl: exData['image_url'],
          );
        }
      }
    }

    final exercisesList = uniqueExercises.values.toList();
    // Urutkan sesuai abjad nama latihan
    exercisesList.sort((a, b) => a.name.compareTo(b.name));

    return ProgressOverviewData(stats: stats, exercises: exercisesList);
  }
}