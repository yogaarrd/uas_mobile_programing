import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/progress_provider.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}j ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatVolume(double volume) {
    if (volume > 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    }
    return volume.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressOverviewProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Statistik Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.neonGreen),
            onPressed: () => ref.refresh(progressOverviewProvider),
          )
        ],
      ),
      body: progressAsync.when(
        data: (data) {
          return CustomScrollView(
            slivers: [
              // 1. BAGIAN GRID STATISTIK
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overview Keseluruhan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatCard(
                            title: 'Sesi Latihan',
                            value: data.stats.totalSessions.toString(),
                            unit: 'Total Sesi',
                            icon: Icons.fitness_center,
                            color: const Color(0xFF7B61FF),
                          ),
                          _buildStatCard(
                            title: 'Volume Angkatan',
                            value: _formatVolume(data.stats.totalVolume),
                            unit: 'Kilogram',
                            icon: Icons.monitor_weight_outlined,
                            color: const Color(0xFFFF6B35),
                          ),
                          _buildStatCard(
                            title: 'Total Durasi',
                            value: _formatDuration(data.stats.totalDurationSeconds),
                            unit: 'Waktu Aktif',
                            icon: Icons.timer_outlined,
                            color: const Color(0xFF00D4AA),
                          ),
                          _buildStatCard(
                            title: 'Konsistensi',
                            value: data.stats.avgSessionsPerWeek.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
                            unit: 'Sesi / Minggu',
                            icon: Icons.calendar_today_rounded,
                            color: AppTheme.neonGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text('Analisis Per Latihan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Pilih latihan di bawah ini untuk melihat grafik rekor personalmu.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 2. BAGIAN DAFTAR EXERCISE YANG PERNAH DILAKUKAN
              if (data.exercises.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('Belum ada data latihan.\nMulai sesi workout pertamamu!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ex = data.exercises[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.darkBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: ex.imageUrl != null 
                              ? Image.network(ex.imageUrl!, fit: BoxFit.cover)
                              : const Icon(Icons.fitness_center, color: Colors.grey),
                          ),
                          title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(ex.muscleGroup.toUpperCase(), style: const TextStyle(color: AppTheme.neonGreen, fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          // Navigasi ke halaman detail [Tugas Selanjutnya]
                          onTap: () => context.push('/progress/exercise/${ex.id}', extra: ex.name),
                        ),
                      );
                    },
                    childCount: data.exercises.length,
                  ),
                ),
                
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1)),
          Text(unit, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }
}