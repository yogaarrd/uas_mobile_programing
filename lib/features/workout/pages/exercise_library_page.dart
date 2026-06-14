import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exercise_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'exercise_detail_page.dart';

class ExerciseLibraryTab extends ConsumerStatefulWidget {
  const ExerciseLibraryTab({super.key});

  @override
  ConsumerState<ExerciseLibraryTab> createState() => _ExerciseLibraryTabState();
}

class _ExerciseLibraryTabState extends ConsumerState<ExerciseLibraryTab> {
  String _searchQuery = '';
  // Tambahkan variabel untuk menampung filter otot yang dipilih
  String _selectedMuscle = 'All';
  final List<String> _muscleGroups = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
  ];

  @override
  Widget build(BuildContext context) {
    final asyncExercises = ref.watch(exercisesFutureProvider);

    return Column(
      children: [
        // 1. SEARCH BAR
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari gerakan...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.neonGreen),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 2. FILTER OTOT (ChoiceChips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _muscleGroups.map((muscle) {
              final isSelected = _selectedMuscle == muscle;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(muscle),
                  selected: isSelected,
                  selectedColor: AppTheme.neonGreen,
                  backgroundColor: AppTheme.surfaceColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                  onSelected: (selected) {
                    setState(() => _selectedMuscle = muscle);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // 3. LIST VIEW DENGAN LOGIKA FILTER
        Expanded(
          child: asyncExercises.when(
            data: (list) {
              final filtered = list.where((ex) {
                final matchSearch = ex.name.toLowerCase().contains(
                  _searchQuery,
                );
                final matchMuscle =
                    _selectedMuscle == 'All' ||
                    ex.muscleGroup.toLowerCase() ==
                        _selectedMuscle.toLowerCase();
                return matchSearch && matchMuscle;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    "Latihan tidak ditemukan",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final exercise = filtered[i]; // Simpan data per item

                  return ListTile(
                    // === TAMBAHKAN ONTAP DI SINI ===
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExerciseDetailPage(exercise: exercise),
                        ),
                      );
                    },
                    // ===============================
                    title: Text(
                      exercise.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      exercise.muscleGroup.toUpperCase(),
                      style: const TextStyle(color: AppTheme.neonGreen),
                    ),
                    // Opsional: Tambah panah kecil di kanan biar user tahu ini bisa diklik
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.neonGreen),
            ),
            error: (e, _) => Center(
              child: Text('$e', style: const TextStyle(color: Colors.red)),
            ),
          ),
        ),
      ],
    );
  }
}
