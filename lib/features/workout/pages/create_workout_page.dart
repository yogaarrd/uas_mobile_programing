import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/workout_builder_provider.dart';
import '../widgets/exercise_selection_sheet.dart';
import '../widgets/exercise_config_card.dart'; // IMPORT WIDGET BARU KITA

class CreateWorkoutPage extends ConsumerStatefulWidget {
  final String? templateId;
  const CreateWorkoutPage({super.key, this.templateId});

  @override
  ConsumerState<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends ConsumerState<CreateWorkoutPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.templateId != null) {
        ref.read(workoutBuilderProvider.notifier).initForEdit(widget.templateId!).then((_) {
          if (!mounted) return; 
          final state = ref.read(workoutBuilderProvider);
          _nameController.text = state.name;
          _descController.text = state.description;
        });
      } else {
        ref.read(workoutBuilderProvider.notifier).clear();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openExercisePicker() async {
    final selected = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ExerciseSelectionSheet(),
    );
    if (!mounted) return;
    if (selected != null) {
      ref.read(workoutBuilderProvider.notifier).addExercise(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutBuilderProvider);
    final notifier = ref.read(workoutBuilderProvider.notifier);

    ref.listen(workoutBuilderProvider, (prev, next) {
      if (next.isSaved) context.pop();
      if (next.error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Text(widget.templateId == null ? 'Buat Workout Baru' : 'Edit Workout', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          state.isLoading 
            ? const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.neonGreen)))
            : Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    notifier.setName(_nameController.text);
                    notifier.setDescription(_descController.text);
                    notifier.save();
                  },
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
        ],
      ),
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(color: AppTheme.neonGreen.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))
              ]
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppTheme.neonGreen, fontSize: 22, fontWeight: FontWeight.bold),
                  cursorColor: AppTheme.neonGreen,
                  decoration: InputDecoration(
                    hintText: 'Nama Workout (Cth: Push Day)',
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 22),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.grey, height: 1),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  cursorColor: AppTheme.neonGreen,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan deskripsi singkat...',
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
        footer: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: OutlinedButton.icon(
            onPressed: _openExercisePicker,
            icon: const Icon(Icons.add, color: AppTheme.neonGreen),
            label: const Text('Tambah Latihan', style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.neonGreen.withOpacity(0.5), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: AppTheme.neonGreen.withOpacity(0.05),
            ),
          ),
        ),
        itemCount: state.exercises.length,
        
        // CUKUP PANGGIL WIDGET REUSABLE DI SINI
        itemBuilder: (context, index) {
          final exData = state.exercises[index];
          return ExerciseConfigCard(
            key: ValueKey(exData.uniqueId),
            exerciseIndex: index,
            data: exData,
            onRemoveExercise: () => notifier.removeExercise(index),
            onAddSet: () => notifier.addSet(index),
            onRemoveSet: (setIndex) => notifier.removeSet(index, setIndex),
            onUpdateSet: (setIndex, reps, weight, rest) => notifier.updateSet(index, setIndex, reps: reps, weight: weight, rest: rest),
          );
        },
        onReorder: (oldIndex, newIndex) => notifier.reorderExercises(oldIndex, newIndex),
      ),
    );
  }
}