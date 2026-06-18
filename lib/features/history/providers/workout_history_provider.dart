import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_session.dart';
import 'selected_date_provider.dart';

class WorkoutHistoryNotifier extends AsyncNotifier<List<WorkoutSession>> {
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isFetching = false;

  @override
  Future<List<WorkoutSession>> build() async {
    // Watch perubahan tanggal agar otomatis reload
    final selectedDate = ref.watch(selectedDateProvider);
    _currentPage = 0;
    _hasMore = true;
    return _fetchData(page: 0, filterDate: selectedDate);
  }

  // PERBAIKAN 1: Tambahkan filterDate di sini
  // PERBAIKAN 1: Tambahkan filterDate di sini
  Future<List<WorkoutSession>> _fetchData({
    required int page,
    DateTime? filterDate,
  }) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) throw Exception('User belum login');

    final from = page * _pageSize;
    final to = from + _pageSize - 1;

    // 1. Siapkan query dasar dan filter pertama (eq)
    var query = supabase
        .from('workout_sessions')
        .select()
        .eq('user_id', userId);

    // 2. Tambahkan filter tanggal (gte & lte) JIKA ADA
    if (filterDate != null) {
      final startOfDayUtc = DateTime(
        filterDate.year,
        filterDate.month,
        filterDate.day,
      ).toUtc().toIso8601String();

      final endOfDayUtc = DateTime(
        filterDate.year,
        filterDate.month,
        filterDate.day,
        23,
        59,
        59,
      ).toUtc().toIso8601String();

      query = query.gte('started_at', startOfDayUtc).lte('started_at', endOfDayUtc);
    }

    // 3. TERAKHIR, pasang modifier (order dan range) lalu eksekusi (await)
    final response = await query
        .order('started_at', ascending: false)
        .range(from, to);

    final data = (response as List)
        .map((json) => WorkoutSession.fromJson(json))
        .toList();

    if (data.length < _pageSize) {
      _hasMore = false;
    }

    return data;
  }

  Future<void> fetchMore() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;

    try {
      _currentPage++;
      // PERBAIKAN 2: Ambil filterDate saat ini dari provider agar saat loadmore filter tetap jalan
      final selectedDate = ref.read(selectedDateProvider);
      final newData = await _fetchData(
        page: _currentPage,
        filterDate: selectedDate,
      );

      final currentData = state.value ?? [];
      state = AsyncData([...currentData, ...newData]);
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _isFetching = false;
    }
  }
}

final workoutHistoryProvider =
    AsyncNotifierProvider<WorkoutHistoryNotifier, List<WorkoutSession>>(() {
      return WorkoutHistoryNotifier();
    });
