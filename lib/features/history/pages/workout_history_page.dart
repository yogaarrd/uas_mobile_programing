import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/workout_history_provider.dart';
import '../providers/workout_calendar_provider.dart';
import '../providers/selected_date_provider.dart';
import 'session_detail_page.dart';

class WorkoutHistoryPage extends ConsumerStatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  ConsumerState<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends ConsumerState<WorkoutHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Future.microtask(() {
          ref.read(workoutHistoryProvider.notifier).fetchMore();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final hasMore = ref.watch(workoutHistoryProvider.notifier).hasMore;
    final selectedDay = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text(
          'Workout History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (selectedDay != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Tampilkan Semua',
              onPressed: () {
                ref.read(selectedDateProvider.notifier).setDate(null);
              },
            ),
        ],
      ),
      body: historyAsync.when(
        data: (sessions) {
          return Column(
            children: [
              // 1. Komponen Kalender Bulanan
              TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (selectedDateTime, focusedDateTime) {
                  setState(() {
                    _focusedDay = focusedDateTime;
                  });
                  // Gunakan .setDate() dari fungsi yang baru kita buat
                  ref
                      .read(selectedDateProvider.notifier)
                      .setDate(selectedDateTime);
                },
                eventLoader: (day) {
                  final events = ref.watch(workoutDatesProvider).value ?? {};
                  return events[DateTime(day.year, day.month, day.day)] ?? [];
                },
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: AppTheme.neonGreen,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.neonGreen,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white70),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                  // PERBAIKAN: Gunakan properti ini sebagai ganti iconColor
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(color: Colors.white12, height: 20, thickness: 1),

              // 2. Daftar Riwayat Latihan
              Expanded(
                child: sessions.isEmpty
                    ? _buildEmptyState(selectedDay != null)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: sessions.length + 1,
                        itemBuilder: (context, index) {
                          if (index < sessions.length) {
                            return _buildHistoryCard(sessions[index]);
                          } else {
                            return hasMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.neonGreen,
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          }
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered
                ? 'Tidak ada latihan di tanggal ini.'
                : 'Belum ada riwayat latihan.',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic session) {
    final dateFormatted = DateFormat(
      'dd MMM yyyy, EEEE',
    ).format(session.startedAt);
    final durationMinutes = session.durationSeconds != null
        ? (session.durationSeconds! / 60).floor()
        : 0;

    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionDetailPage(session: session),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormatted,
                style: const TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                session.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(Icons.timer_outlined, '$durationMinutes mnt'),
                  _buildStatItem(
                    Icons.fitness_center,
                    '${session.totalVolumeKg} kg',
                  ),
                  _buildStatItem(Icons.list_alt, 'Detail Sesi'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
