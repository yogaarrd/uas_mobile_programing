import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider; 
import '../../../core/theme/app_theme.dart';
import '../../workout/providers/workout_provider.dart'; 
import '../../workout/models/workout_template.dart';
import '../../auth/providers/auth_provider.dart'; 
import '../../../features/workout/pages/exercise_library_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            floatingActionButton: AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
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
                    await context.read<AuthProvider>().logout();
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

class MyWorkoutsView extends ConsumerWidget {
  const MyWorkoutsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(workoutTemplatesProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return _buildEmptyState(context);
        }
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(workoutTemplatesProvider.future),
          color: AppTheme.neonGreen,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _WorkoutTemplateCard(template: templates[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
      error: (error, stack) => Center(
        child: Text('Terjadi kesalahan:\n$error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada template latihan',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-workout'),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text('Buat Template Pertama', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }
}

// === CARD DIUBAH JADI CONSUMER WIDGET AGAR BISA AKSES REF ===
class _WorkoutTemplateCard extends ConsumerWidget {
  final WorkoutTemplate template;
  const _WorkoutTemplateCard({required this.template});

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    // 1. Tampilkan Dialog Konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Workout?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah kamu yakin ingin menghapus template "${template.name}"?\nData yang dihapus tidak dapat dikembalikan.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    // 2. Lakukan Proses Penghapusan jika Dikonfirmasi
    if (confirmed == true && context.mounted) {
      try {
        // Tampilkan loading overlay pencegah double tap
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        );

        final repo = ref.read(workoutRepositoryProvider);
        await repo.deleteWorkoutTemplate(template.id);
        
        if (!context.mounted) return;
        Navigator.pop(context); // Tutup loading overlay

        // Minta Riverpod memuat ulang daftar data terbaru dari database
        ref.invalidate(workoutTemplatesProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout berhasil dihapus', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
            backgroundColor: AppTheme.neonGreen,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (context.mounted) Navigator.pop(context); // Tutup loading overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimatedTime = template.exerciseCount * 10;
    return Card(
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                // Tombol Edit dan Hapus Berjejer
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.grey),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 12),
                      onPressed: () => context.push('/create-workout?id=${template.id}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _handleDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            if (template.description != null && template.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                template.description!,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: _buildBadge(Icons.format_list_bulleted, '${template.exerciseCount} Latihan'),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _buildBadge(Icons.timer_outlined, '~ $estimatedTime mnt'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: template.muscleGroups.map((m) => _buildMuscleChip(m)).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/active-session/${template.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Start Workout', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                ),
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

  Widget _buildMuscleChip(String muscle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withOpacity(0.15),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        muscle.toUpperCase(),
        style: const TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}