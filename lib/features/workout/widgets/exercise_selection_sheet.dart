import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../providers/exercise_provider.dart';

class ExerciseSelectionSheet extends ConsumerStatefulWidget {
  const ExerciseSelectionSheet({super.key});

  @override
  ConsumerState<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends ConsumerState<ExerciseSelectionSheet> {
  String _searchQuery = '';

  void _showDetailDrawer(BuildContext context, ExerciseModel exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final instructionSteps = exercise.instructions
            .split('.')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => '${s.trim()}.')
            .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Image / Placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: exercise.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Image.network(exercise.imageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          _buildChip(Icons.accessibility_new, exercise.muscleGroup, AppTheme.neonGreen),
                          _buildChip(Icons.fitness_center, exercise.equipment, Colors.lightBlueAccent),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Instruksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      ...List.generate(instructionSteps.length, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 12, backgroundColor: AppTheme.neonGreen.withOpacity(0.2), child: Text('${i+1}', style: const TextStyle(color: AppTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(instructionSteps[i], style: const TextStyle(color: Colors.white70, height: 1.5))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              // Tambahkan Tombol Add di dalam Detail Drawer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx); // Tutup drawer detail
                    Navigator.pop(context, exercise); // Kirim data ke page utama
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('Tambahkan ke Workout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncExercises = ref.watch(exercisesFutureProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Pilih Latihan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama atau otot...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: asyncExercises.when(
              data: (list) {
                final filtered = list.where((e) => e.name.toLowerCase().contains(_searchQuery) || e.muscleGroup.toLowerCase().contains(_searchQuery)).toList();
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final ex = filtered[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade800)
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(ex.muscleGroup.toUpperCase(), style: const TextStyle(color: AppTheme.neonGreen, fontSize: 11)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.grey),
                              tooltip: 'Lihat Detail',
                              onPressed: () => _showDetailDrawer(context, ex),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: AppTheme.neonGreen, size: 28),
                              tooltip: 'Tambah Latihan',
                              onPressed: () => Navigator.pop(context, ex),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
              error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: Colors.red))),
            ),
          )
        ],
      ),
    );
  }
}