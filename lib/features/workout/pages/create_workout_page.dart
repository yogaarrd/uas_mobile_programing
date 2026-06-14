import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/workout_builder_models.dart';
import '../providers/workout_builder_provider.dart';
import '../widgets/exercise_selection_sheet.dart';

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
        itemBuilder: (context, index) {
          final exData = state.exercises[index];
          return Card(
            key: ValueKey(exData.uniqueId),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            color: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                children: [
                  // HEADER LATIHAN
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.drag_indicator, color: Colors.grey)),
                        ),
                        Expanded(child: Text(exData.exercise.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => notifier.removeExercise(index),
                        ),
                      ],
                    ),
                  ),
                  
                  // LABEL KOLOM
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 30, child: Text('SET', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('KG', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('REST', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),

                  // LIST SETS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: List.generate(exData.sets.length, (setIndex) {
                        return _SetInputRow(
                          key: ValueKey('${exData.uniqueId}_$setIndex'),
                          setNumber: setIndex + 1,
                          initialData: exData.sets[setIndex],
                          onChanged: (reps, weight, rest) => notifier.updateSet(index, setIndex, reps: reps, weight: weight, rest: rest),
                          onDelete: () => notifier.removeSet(index, setIndex),
                        );
                      }),
                    ),
                  ),
                  
                  // TOMBOL TAMBAH SET
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: InkWell(
                      onTap: () => notifier.addSet(index),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade800), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18, color: Colors.grey),
                            SizedBox(width: 6),
                            Text('Tambah Set', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        onReorder: (oldIndex, newIndex) => notifier.reorderExercises(oldIndex, newIndex),
      ),
    );
  }
}

// === KOMPONEN INPUT SET YANG LEBIH CLEAN ===
class _SetInputRow extends StatefulWidget {
  final int setNumber;
  final ExerciseSetFormData initialData;
  final Function(int reps, double weight, int rest) onChanged;
  final VoidCallback onDelete;

  const _SetInputRow({super.key, required this.setNumber, required this.initialData, required this.onChanged, required this.onDelete});

  @override
  State<_SetInputRow> createState() => _SetInputRowState();
}

class _SetInputRowState extends State<_SetInputRow> {
  late TextEditingController weightCtrl;
  late TextEditingController repsCtrl;
  late TextEditingController restCtrl;

  @override
  void initState() {
    super.initState();
    weightCtrl = TextEditingController(text: widget.initialData.weight == 0 ? '' : widget.initialData.weight.toString());
    repsCtrl = TextEditingController(text: widget.initialData.reps == 0 ? '' : widget.initialData.reps.toString());
    restCtrl = TextEditingController(text: widget.initialData.restSeconds.toString());
  }

  @override
  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
    restCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final w = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final r = int.tryParse(repsCtrl.text) ?? 0;
    final rs = int.tryParse(restCtrl.text) ?? 0;
    widget.onChanged(r, w, rs);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('${widget.setNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(flex: 2, child: _buildSleekField(weightCtrl)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildSleekField(repsCtrl)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildSleekField(restCtrl)),
          SizedBox(
            width: 36,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.grey, size: 22),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleekField(TextEditingController ctrl) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.darkBackground, 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800)
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        cursorColor: AppTheme.neonGreen,
        onChanged: (_) => _notifyChange(),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 12)),
      ),
    );
  }
}