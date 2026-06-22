import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/body_measurement.dart';

class BodyMeasurementRepository {
  final _supabase = Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw Exception('User belum login');
    return id;
  }

  /// Ambil semua catatan berat badan milik user, diurutkan dari terlama ke terbaru
  Future<List<BodyMeasurement>> getMeasurements() async {
    final response = await _supabase
        .from('body_measurements')
        .select()
        .eq('user_id', _userId)
        .order('measured_at', ascending: true);

    return (response as List<dynamic>)
        .map((e) => BodyMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tambah atau update catatan (upsert berdasarkan user_id + measured_at)
  Future<void> upsertMeasurement({
    required DateTime date,
    required double weightKg,
    String? note,
  }) async {
    final userId = _userId;
    final dateStr = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    await _supabase.from('body_measurements').upsert({
      'user_id': userId,
      'measured_at': dateStr,
      'weight_kg': weightKg,
      if (note != null && note.isNotEmpty) 'note': note,
    }, onConflict: 'user_id,measured_at');
  }

  /// Hapus catatan berdasarkan ID
  Future<void> deleteMeasurement(String id) async {
    await _supabase
        .from('body_measurements')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
