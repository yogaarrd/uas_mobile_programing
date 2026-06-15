import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/workout_history_provider.dart';

class WorkoutHistoryPage extends ConsumerStatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  ConsumerState<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends ConsumerState<WorkoutHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Dengarkan gerakan scroll
    _scrollController.addListener(() {
      // Jika scroll sudah mendekati paling bawah (sisa 200 pixel)
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // [PERBAIKAN 1]: Bungkus dengan microtask agar tidak menabrak proses build UI
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
    
    // [PERBAIKAN 2]: Ambil hasMore di luar itemBuilder menggunakan ref.watch
    final hasMore = ref.watch(workoutHistoryProvider.notifier).hasMore;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Workout History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) return _buildEmptyState();

          return ListView.builder(
            controller: _scrollController, 
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length + 1, 
            itemBuilder: (context, index) {
              if (index < sessions.length) {
                return _buildHistoryCard(sessions[index]);
              } else {
                // Panggil variabel hasMore yang sudah diambil secara aman di atas
                return hasMore 
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
                      )
                    : const SizedBox(); 
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  // Widget untuk Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat latihan.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai sesi latihan pertamamu hari ini!',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Widget untuk Card History
  Widget _buildHistoryCard(dynamic session) {
    final dateFormatted = DateFormat('dd MMM yyyy, EEEE').format(session.startedAt);
    
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
          // Nanti kita arahkan ke halaman Detail Sesi (HIS-02)
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormatted,
                style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              
              Text(
                session.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              if (session.notes != null && session.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Text(
                    '"${session.notes}"',
                    style: const TextStyle(
                      color: Colors.white70, 
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(Icons.timer_outlined, '$durationMinutes mnt'),
                  _buildStatItem(Icons.fitness_center, '${session.totalVolumeKg} kg'),
                  _buildStatItem(Icons.list_alt, '? Latihan'), 
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