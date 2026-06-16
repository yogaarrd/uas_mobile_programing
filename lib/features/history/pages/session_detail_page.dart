import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
// TODO: Sesuaikan path file
import '../models/workout_session.dart';
import '../providers/session_detail_provider.dart';

class SessionDetailPage extends ConsumerWidget {
  final WorkoutSession session;

  const SessionDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(sessionDetailProvider(session.id));
    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(session.startedAt);
    final durationMinutes = session.durationSeconds != null ? (session.durationSeconds! / 60).floor() : 0;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Session Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        slivers: [
          // Header Info Utama
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(dateFormatted, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat(Icons.timer_outlined, 'Duration', '$durationMinutes min'),
                      _buildHeaderStat(Icons.fitness_center, 'Volume', '${session.totalVolumeKg} kg'),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 40, thickness: 1),
                  const Text('Exercises', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Daftar Exercise dan Set
          detailAsync.when(
            data: (exercises) {
              if (exercises.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('Tidak ada detail latihan.', style: TextStyle(color: Colors.grey))),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = exercises[index];
                    return _buildExerciseCard(exercise);
                  },
                  childCount: exercises.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(padding: const EdgeInsets.all(32.0), child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red)))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildExerciseCard(dynamic exercise) {
    return Card(
      color: AppTheme.surfaceColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.exerciseName, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Header Tabel
            const Row(
              children: [
                Expanded(flex: 1, child: Text('Set', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Weight', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Reps', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            // Looping baris Set
            ...exercise.sets.map<Widget>((setDetail) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text('${setDetail.setNumber}', style: const TextStyle(color: Colors.white))),
                    Expanded(flex: 2, child: Text('${setDetail.weight} kg', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                    Expanded(flex: 2, child: Text('${setDetail.reps}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white))),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}