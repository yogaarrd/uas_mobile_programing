import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Menggunakan provider
import '../../../core/theme/app_theme.dart';
import '../../workout/providers/workout_provider.dart'; // Pastikan ini sudah versi Provider
import '../../workout/models/workout_template.dart';
import '../../auth/providers/auth_provider.dart'; // AuthProvider milikmu
import '../../../features/workout/pages/exercise_library_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita gunakan DefaultTabController agar bisa memantau perubahan tab
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            // Gunakan AnimatedBuilder untuk memunculkan/menyembunyikan tombol secara halus
            floatingActionButton: AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                // Jika index 0 (My Workouts), tampilkan tombol. Jika tidak, sembunyikan.
                return tabController.index == 0
                    ? FloatingActionButton(
                        backgroundColor: AppTheme.neonGreen,
                        onPressed: () => context.push('/create-workout'),
                        child: const Icon(Icons.add, color: Colors.black),
                      )
                    : const SizedBox.shrink();
              },
            ),
            appBar: AppBar(
              backgroundColor: AppTheme.darkBackground,
              elevation: 0,
              title: const Text(
                'GymApp',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () async {
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
              bottom: const TabBar(
                indicatorColor: AppTheme.neonGreen,
                labelColor: AppTheme.neonGreen,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'My Workouts'),
                  Tab(text: 'Library'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [MyWorkoutsView(), ExerciseLibraryTab()],
            ),
          );
        },
      ),
    );
  }
}

// === TAB 1: VERSI PROVIDER ===
class MyWorkoutsView extends StatelessWidget {
  const MyWorkoutsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Di sini sesuaikan dengan cara temanmu mengambil data workout
    // Contoh jika menggunakan FutureBuilder atau Provider:
    return const Center(
      child: Text(
        'Workouts (Provider Mode)',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

// Card tetap sama
class _WorkoutTemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  const _WorkoutTemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    final estimatedTime = template.exerciseCount * 10;
    return Card(
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: _buildBadge(
                    Icons.format_list_bulleted,
                    '${template.exerciseCount} Latihan',
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _buildBadge(
                    Icons.timer_outlined,
                    '~ $estimatedTime mnt',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/active-session/${template.id}'),
                child: const Text('Start Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    ],
  );
}
