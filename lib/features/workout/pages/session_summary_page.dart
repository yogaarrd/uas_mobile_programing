import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/session_summary_args.dart';

class SessionSummaryPage extends StatelessWidget {
  final SessionSummaryArgs args;
  
  const SessionSummaryPage({super.key, required this.args});

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // Mematikan tombol back Android agar tidak kembali ke halaman sesi aktif yang sudah hangus
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Hilangkan tombol back default
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => context.go('/home'),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ICON SUKSES BESAR
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5), width: 2)
                ),
                child: const Icon(Icons.emoji_events, color: AppTheme.neonGreen, size: 80),
              ),
              const SizedBox(height: 24),
              const Text('Workout Selesai!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(args.workoutName, style: const TextStyle(color: AppTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              // GRID STATS
              Row(
                children: [
                  Expanded(child: _buildStatCard('Durasi', _formatTime(args.durationSeconds), Icons.timer)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Volume', '${args.totalVolume.toStringAsFixed(0)} kg', Icons.fitness_center)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Sets', '${args.completedSets}', Icons.tag)),
                ],
              ),
              const SizedBox(height: 32),

              // HIGHLIGHT PR BARU
              if (args.prMessages.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.1), blurRadius: 20)]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.orangeAccent),
                          SizedBox(width: 8),
                          Text('Pencapaian Baru!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...args.prMessages.map((msg) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $msg', style: const TextStyle(color: AppTheme.neonGreen, fontSize: 15, fontWeight: FontWeight.w600)),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],

              // BUTTONS
              // OutlinedButton.icon(
              //   onPressed: () {
              //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka menu share perangkat...')));
              //   },
              //   icon: const Icon(Icons.share, color: Colors.white),
              //   label: const Text('Bagikan ke Teman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              //   style: OutlinedButton.styleFrom(
              //     minimumSize: const Size.fromHeight(54),
              //     side: const BorderSide(color: Colors.grey),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              //   ),
              // ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Kembali ke Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade800)),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}