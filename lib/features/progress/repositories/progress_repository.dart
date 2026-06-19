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

  // === FITUR BARU [PRG-02]: AMBIL PROGRESS PER EXERCISE ===
  Future<List<ExerciseProgressPoint>> getExerciseProgress(String exerciseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    // Ambil session_exercises yang terhubung dengan workout_sessions (milik user) dan session_sets
    final response = await _supabase
        .from('session_exercises')
        .select('''
          workout_sessions!inner(started_at, user_id),
          session_sets(weight, reps, is_completed)
        ''')
        .eq('exercise_id', exerciseId)
        .eq('workout_sessions.user_id', userId);

    final List<dynamic> data = response as List<dynamic>;
    List<ExerciseProgressPoint> points = [];

    for (var row in data) {
      final session = row['workout_sessions'];
      if (session == null) continue;
      
      final dateStr = session['started_at'] as String;
      final date = DateTime.parse(dateStr).toLocal();

      final setsList = row['session_sets'] as List<dynamic>? ?? [];
      double maxWeight = 0;
      int totalReps = 0;
      int completedSetsCount = 0;

      for (var s in setsList) {
        if (s['is_completed'] == true) {
          completedSetsCount++;
          final w = (s['weight'] as num?)?.toDouble() ?? 0.0;
          final r = (s['reps'] as num?)?.toInt() ?? 0;
          totalReps += r;
          if (w > maxWeight) maxWeight = w;
        }
      }

      // Hanya catat sesi yang minimal ada 1 set sukses selesai
      if (completedSetsCount > 0) {
        points.add(ExerciseProgressPoint(
          date: date,
          maxWeight: maxWeight,
          totalReps: totalReps,
          totalSets: completedSetsCount,
        ));
      }
    }

    // Urutkan dari tanggal TERLAMA ke TERBARU agar grafik garis mengalir ke kanan dengan benar
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
  // === FITUR BARU [PRG-03]: CEK PR BARU SETELAH SESI SELESAI ===
  Future<List<String>> checkNewPRsForSession(String sessionId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // 1. Ambil data angkatan pada sesi yang baru saja selesai
    final currentSessionResp = await _supabase
        .from('session_exercises')
        .select('exercise_id, exercises(name), session_sets(weight, is_completed)')
        .eq('session_id', sessionId);

    List<String> exercisesWithNewPR = [];

    for (var row in currentSessionResp) {
      final exId = row['exercise_id'];
      final exName = row['exercises']['name'];
      final sets = row['session_sets'] as List<dynamic>? ?? [];

      // Cari angkatan maksimal di sesi ini
      double currentMax = 0;
      for (var s in sets) {
        if (s['is_completed'] == true) {
          final w = (s['weight'] as num?)?.toDouble() ?? 0.0;
          if (w > currentMax) currentMax = w;
        }
      }

      if (currentMax == 0) continue; // Skip kalau tidak ada angkatan sukses

      // 2. Ambil seluruh histori angkatan latihan ini di sesi-sesi SEBELUMNYA
      final historyResp = await _supabase
          .from('session_exercises')
          .select('session_sets(weight, is_completed), workout_sessions!inner(started_at)')
          .eq('exercise_id', exId)
          .eq('workout_sessions.user_id', userId)
          .neq('session_id', sessionId); // Jangan menghitung sesi saat ini

      double historicalMax = 0;
      for (var hRow in historyResp) {
        final hSets = hRow['session_sets'] as List<dynamic>? ?? [];
        for (var hs in hSets) {
          if (hs['is_completed'] == true) {
            final hw = (hs['weight'] as num?)?.toDouble() ?? 0.0;
            if (hw > historicalMax) historicalMax = hw;
          }
        }
      }

      // 3. Bandingkan, apakah angkatan sesi ini LEBIH BESAR dari max histori?
      // Bisa diganti menjadi >= jika menyamai rekor lama juga ingin dianggap PR
      if (currentMax > historicalMax) {
        exercisesWithNewPR.add(exName);
      }
    }

    // Mengembalikan list nama exercise yang pecah rekor (misal: ["Bench Press", "Squat"])
    return exercisesWithNewPR;
  }
}