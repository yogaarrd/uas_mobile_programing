import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../providers/active_session_provider.dart';

class ActiveSessionPage extends ConsumerStatefulWidget {
  final String? templateId;
  const ActiveSessionPage({super.key, this.templateId});

  @override
  ConsumerState<ActiveSessionPage> createState() => _ActiveSessionPageState();
}

class _ActiveSessionPageState extends ConsumerState<ActiveSessionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeSessionProvider.notifier).initSession(widget.templateId);
    });
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showExerciseDetail(BuildContext context, ExerciseModel exercise) {
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
                      const Text('Cara Melakukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text('Tutup', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
    final state = ref.watch(activeSessionProvider);
    final notifier = ref.read(activeSessionProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
      );
    }

    final currentExIndex = state.exercises.indexWhere((ex) => ex.sets.any((s) => !s.isCompleted));

    return WillPopScope(
      onWillPop: () async {
        final quit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text('Batalkan Workout?', style: TextStyle(color: Colors.white)),
            content: const Text('Semua progress sesi ini akan hilang.', style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Lanjut', style: TextStyle(color: Colors.grey))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Batalkan', style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        );
        return quit ?? false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBackground,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.maybePop(context)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.workoutName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatTime(state.elapsedSeconds), style: const TextStyle(fontSize: 14, color: AppTheme.neonGreen)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonGreen, foregroundColor: Colors.black),
                onPressed: () {
                  notifier.finishWorkout();
                  context.pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi Selesai!'), backgroundColor: AppTheme.neonGreen));
                },
                child: const Text('FINISH', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Colors.grey.shade800,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
            ),
          ),
        ),
        body: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 140), 
              itemCount: state.exercises.length,
              itemBuilder: (ctx, exIndex) {
                final exData = state.exercises[exIndex];
                final isActiveExercise = exIndex == currentExIndex;
                final activeSetIndex = isActiveExercise ? state.currentSetIndex : -1;

                return _ActiveExerciseCard(
                  exIndex: exIndex,
                  data: exData,
                  isActiveExercise: isActiveExercise,
                  activeSetIndex: activeSetIndex ?? -1,
                  onToggleSet: (setIndex) => notifier.toggleSet(exIndex, setIndex),
                  onUpdateSet: (setIndex, reps, weight) => notifier.updateSetActuals(exIndex, setIndex, reps, weight),
                  onShowDetail: () => _showExerciseDetail(context, exData.exercise),
                );
              },
            ),
            
            // DYNAMIC BOTTOM BAR
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -10))],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
                ),
                child: state.isResting 
                  // --- MODE REST TIMER ---
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer, color: AppTheme.neonGreen, size: 28),
                                const SizedBox(width: 12),
                                Text(_formatTime(state.restSecondsRemaining), style: const TextStyle(color: AppTheme.neonGreen, fontSize: 32, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildTimeAdder('+15s', () => notifier.addRestTime(15)),
                                const SizedBox(width: 8),
                                _buildTimeAdder('+30s', () => notifier.addRestTime(30)),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: notifier.skipRest,
                                  style: TextButton.styleFrom(backgroundColor: Colors.grey.shade800),
                                  child: const Text('SKIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Selanjutnya: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Expanded(child: Text(state.nextUpText, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ],
                    )
                  // --- MODE AKTIF (TIDAK REST) - DENGAN GIF ---
                  : Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            'assets/gifs/progress_giff.gif',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.fitness_center, color: AppTheme.neonGreen, size: 24);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Sedang Dilakukan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                state.currentExercise != null 
                                  ? '${state.currentExercise!.exercise.name} - Set ${state.currentSetIndex! + 1}'
                                  : 'Semua Selesai! Tekan Finish.', 
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
            ),

            // ========================================================
            // OVERLAY: NEW PREMIUM SPLASH SCREEN TRANSISI MOTIVASI
            // ========================================================
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInQuad,
                switchOutCurve: Curves.easeOutQuad,
                child: state.isTransitioning
                    ? Container(
                        key: const ValueKey('splash_screen'),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppTheme.darkBackground,
                          // Efek Radial Gradient agar layar tidak flat
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF2B2B3A), // Sedikit lebih terang di tengah
                              AppTheme.darkBackground,
                            ],
                            radius: 1.2,
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 1. LABEL GET READY
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'GET READY',
                                  style: TextStyle(
                                    color: AppTheme.neonGreen,
                                    fontSize: 14,
                                    letterSpacing: 4.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),

                              // 2. GIANT GLOWING COUNTDOWN
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Shadow/Glow effect
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.neonGreen.withOpacity(0.2),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Background Track
                                  const SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: CircularProgressIndicator(
                                      value: 1.0,
                                      color: Colors.black26,
                                      strokeWidth: 8,
                                    ),
                                  ),
                                  // Spinning Progress
                                  const SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.neonGreen,
                                      strokeWidth: 8,
                                    ),
                                  ),
                                  // Countdown Number
                                  Text(
                                    '${state.transitionSecondsRemaining}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 50),

                              // 3. ELEGANT MOTIVATIONAL QUOTE CARD
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.grey.shade800),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.format_quote_rounded,
                                        color: AppTheme.neonGreen.withOpacity(0.6),
                                        size: 40,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        state.transitionMessage,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAdder(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

// === KOMPONEN CARD LATIHAN ===
class _ActiveExerciseCard extends StatelessWidget {
  final int exIndex;
  final ActiveExercise data;
  final bool isActiveExercise;
  final int activeSetIndex;
  final Function(int setIndex) onToggleSet;
  final Function(int setIndex, int reps, double weight) onUpdateSet;
  final VoidCallback onShowDetail; 

  const _ActiveExerciseCard({
    required this.exIndex, 
    required this.data, 
    required this.isActiveExercise,
    required this.activeSetIndex,
    required this.onToggleSet, 
    required this.onUpdateSet, 
    required this.onShowDetail
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge, 
      child: Column(
        children: [
          ListTile(
            title: Text(data.exercise.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(data.exercise.muscleGroup.toUpperCase(), style: const TextStyle(color: AppTheme.neonGreen, fontSize: 11)),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.grey),
              onPressed: onShowDetail,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(width: 30, child: Text('SET', style: TextStyle(color: Colors.grey, fontSize: 11))),
                Expanded(child: Text('KG', style: TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center)),
                Expanded(child: Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center)),
                SizedBox(width: 48, child: Icon(Icons.check, color: Colors.grey, size: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(data.sets.length, (setIndex) {
            final set = data.sets[setIndex];
            final isActiveSet = isActiveExercise && setIndex == activeSetIndex;
            
            return _ActiveSetRow(
              setNumber: setIndex + 1,
              setData: set,
              isActiveSet: isActiveSet, 
              onChanged: (r, w) => onUpdateSet(setIndex, r, w),
              onToggle: () => onToggleSet(setIndex),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// === KOMPONEN INPUT ROW ===
class _ActiveSetRow extends StatefulWidget {
  final int setNumber;
  final ActiveSet setData;
  final bool isActiveSet;
  final Function(int reps, double weight) onChanged;
  final VoidCallback onToggle;

  const _ActiveSetRow({
    required this.setNumber, 
    required this.setData, 
    required this.isActiveSet, 
    required this.onChanged, 
    required this.onToggle
  });

  @override
  State<_ActiveSetRow> createState() => _ActiveSetRowState();
}

class _ActiveSetRowState extends State<_ActiveSetRow> {
  late TextEditingController weightCtrl;
  late TextEditingController repsCtrl;

  @override
  void initState() {
    super.initState();
    weightCtrl = TextEditingController(text: widget.setData.weight == 0 ? '' : widget.setData.weight.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''));
    repsCtrl = TextEditingController(text: widget.setData.reps == 0 ? '' : widget.setData.reps.toString());
  }

  @override
  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.setData.isCompleted;
    final isCurrentlyProgressing = widget.isActiveSet && !isDone;

    final bgColor = isDone 
        ? AppTheme.neonGreen.withOpacity(0.1) 
        : (isCurrentlyProgressing ? Colors.white.withOpacity(0.08) : Colors.transparent); 

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            color: isCurrentlyProgressing ? AppTheme.neonGreen : Colors.transparent, 
            width: 4
          )
        )
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 26, 
            child: Text(
              '${widget.setNumber}', 
              style: TextStyle(
                color: isDone || isCurrentlyProgressing ? AppTheme.neonGreen : Colors.white, 
                fontWeight: FontWeight.bold
              )
            )
          ),
          Expanded(child: _buildField(weightCtrl, isDone, isCurrentlyProgressing)),
          const SizedBox(width: 8),
          Expanded(child: _buildField(repsCtrl, isDone, isCurrentlyProgressing)),
          const SizedBox(width: 8),
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40, height: 36,
              decoration: BoxDecoration(
                color: isDone ? AppTheme.neonGreen : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(Icons.check, color: isDone ? Colors.black : Colors.grey, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, bool isDone, bool isProgressing) {
    final textColor = isDone || isProgressing ? AppTheme.neonGreen : Colors.white;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDone ? Colors.transparent : AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontWeight: isDone || isProgressing ? FontWeight.bold : FontWeight.normal),
        enabled: !isDone,
        onChanged: (_) {
          final w = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
          final r = int.tryParse(repsCtrl.text) ?? 0;
          widget.onChanged(r, w);
        },
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 14)),
      ),
    );
  }
}