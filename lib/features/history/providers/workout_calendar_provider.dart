import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final workoutDatesProvider = FutureProvider<Map<DateTime, List<dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) return {};

  // Mengambil kolom started_at untuk menandai tanggal latihan di kalender
  final response = await supabase
      .from('workout_sessions')
      .select('started_at')
      .eq('user_id', user.id);

  final List<dynamic> data = response as List<dynamic>;
  final Map<DateTime, List<dynamic>> events = {};

  for (var item in data) {
    if (item['started_at'] != null) {
      final dateStr = item['started_at'] as String;
      final date = DateTime.parse(dateStr).toLocal();
      // Lakukan normalisasi jam menjadi 00:00 agar pencocokan tanggal di kalender akurat
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (events[normalizedDate] == null) events[normalizedDate] = [];
      events[normalizedDate]!.add(item);
    }
  }

  return events;
});