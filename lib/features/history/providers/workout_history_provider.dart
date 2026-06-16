import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// TODO: Pastikan path ini sesuai
import '../models/workout_session.dart';

class WorkoutHistoryNotifier extends AsyncNotifier<List<WorkoutSession>> {
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  
  int _currentPage = 0;
  final int _pageSize = 10; // Ambil 10 data setiap kali load
  bool _isFetching = false;

  @override
  Future<List<WorkoutSession>> build() async {
    _currentPage = 0;
    _hasMore = true;
    return _fetchData(page: 0);
  }

  Future<List<WorkoutSession>> _fetchData({required int page}) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) throw Exception('User belum login');

    final from = page * _pageSize;
    final to = from + _pageSize - 1;

    final response = await supabase
        .from('workout_sessions')
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false)
        .range(from, to); // Pagination Supabase

    final data = (response as List).map((json) => WorkoutSession.fromJson(json)).toList();

    // Kalau data yang ditarik kurang dari 10, berarti sudah mentok
    if (data.length < _pageSize) {
      _hasMore = false;
    }

    return data;
  }

  // Fungsi ini dipanggil saat user nge-scroll ke paling bawah
  Future<void> fetchMore() async {
    if (_isFetching || !_hasMore) return; // Cegah double load

    _isFetching = true;

    try {
      _currentPage++;
      final newData = await _fetchData(page: _currentPage);
      
      // Gabungkan data lama dengan data baru
      final currentData = state.value ?? [];
      state = AsyncData([...currentData, ...newData]);
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _isFetching = false;
    }
  }
}

final workoutHistoryProvider = AsyncNotifierProvider<WorkoutHistoryNotifier, List<WorkoutSession>>(() {
  return WorkoutHistoryNotifier();
});