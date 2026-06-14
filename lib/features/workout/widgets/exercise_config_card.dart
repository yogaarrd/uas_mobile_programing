import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/workout_builder_models.dart';

class ExerciseConfigCard extends StatefulWidget {
  final int exerciseIndex;
  final TemplateExerciseFormData data;
  final VoidCallback onRemoveExercise;
  final VoidCallback onAddSet;
  final Function(int setIndex) onRemoveSet;
  final Function(int setIndex, int reps, double weight, int rest) onUpdateSet;

  const ExerciseConfigCard({
    super.key,
    required this.exerciseIndex,
    required this.data,
    required this.onRemoveExercise,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateSet,
  });

  @override
  State<ExerciseConfigCard> createState() => _ExerciseConfigCardState();
}

class _ExerciseConfigCardState extends State<ExerciseConfigCard> {
  // State lokal untuk melacak apakah user sedang melihat dalam format LBS atau KG
  bool _isLbs = false;

  @override
  Widget build(BuildContext context) {
    return Card(
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
            // HEADER LATIHAN (Drag Handle, Nama Latihan, Tombol Hapus)
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              decoration: const BoxDecoration(
                color: Colors.black26, 
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))
              ),
              child: Row(
                children: [
                  ReorderableDragStartListener(
                    index: widget.exerciseIndex,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0), 
                      child: Icon(Icons.drag_indicator, color: Colors.grey)
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.data.exercise.name, 
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                    )
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: widget.onRemoveExercise,
                  ),
                ],
              ),
            ),
            
            // LABEL KOLOM & TOGGLE KG/LBS
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 30, 
                    child: Text('SET', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))
                  ),
                  Expanded(
                    flex: 2, 
                    // Toggle Unit KG <-> LBS
                    child: GestureDetector(
                      onTap: () => setState(() => _isLbs = !_isLbs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLbs ? 'LBS' : 'KG', 
                            style: const TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.swap_horiz, size: 14, color: AppTheme.neonGreen),
                        ],
                      ),
                    )
                  ),
                  const Expanded(flex: 2, child: Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  const Expanded(flex: 2, child: Text('REST', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // LIST BARIS INPUT SETS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(widget.data.sets.length, (setIndex) {
                  return _SetInputRow(
                    key: ValueKey('${widget.data.uniqueId}_$setIndex'),
                    setNumber: setIndex + 1,
                    initialData: widget.data.sets[setIndex],
                    isLbs: _isLbs, // Passing state satuan ukuran
                    onChanged: (reps, weight, rest) => widget.onUpdateSet(setIndex, reps, weight, rest),
                    onDelete: () => widget.onRemoveSet(setIndex),
                  );
                }),
              ),
            ),
            
            // TOMBOL TAMBAH SET
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: InkWell(
                onTap: widget.onAddSet,
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
  }
}

// === KOMPONEN INTERNAL: BARIS INPUT PER SET ===
class _SetInputRow extends StatefulWidget {
  final int setNumber;
  final ExerciseSetFormData initialData;
  final bool isLbs; // Parameter untuk menentukan nilai konversi visual
  final Function(int reps, double weight, int rest) onChanged;
  final VoidCallback onDelete;

  const _SetInputRow({
    super.key, 
    required this.setNumber, 
    required this.initialData, 
    required this.isLbs,
    required this.onChanged, 
    required this.onDelete
  });

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
    _initControllers();
  }

  void _initControllers() {
    double displayWeight = widget.initialData.weight;
    // Jika LBS aktif, konversi data asli (KG) ke LBS hanya untuk tampilan visual
    if (widget.isLbs && displayWeight > 0) {
      displayWeight = displayWeight * 2.20462;
    }
    
    // Format text: Hilangkan ".0" di belakang jika angka bulat murni
    weightCtrl = TextEditingController(text: displayWeight == 0 ? '' : displayWeight.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''));
    repsCtrl = TextEditingController(text: widget.initialData.reps == 0 ? '' : widget.initialData.reps.toString());
    restCtrl = TextEditingController(text: widget.initialData.restSeconds.toString());
  }

  @override
  void didUpdateWidget(_SetInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Terpicu jika user menekan tombol Toggle KG/LBS di header
    if (oldWidget.isLbs != widget.isLbs) {
      double currentWeight = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
      if (currentWeight > 0) {
        double newDisplayWeight = widget.isLbs ? (currentWeight * 2.20462) : (currentWeight / 2.20462);
        weightCtrl.text = newDisplayWeight.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      }
    }
  }

  @override
  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
    restCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    // Parsing inputan user (mendukung desimal titik atau koma)
    double w = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
    
    // Normalisasi: Database selalu menyimpan dalam KG agar data seragam
    if (widget.isLbs && w > 0) {
      w = w / 2.20462; 
    }
    
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