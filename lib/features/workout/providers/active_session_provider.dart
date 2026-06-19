import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_models.dart';
import '../repositories/workout_repository.dart';
import 'workout_provider.dart';
import '../../../core/services/notification_service.dart';
import '../models/session_summary_args.dart';
import '../../progress/providers/progress_provider.dart';

class ActiveSet {
  int reps;
  double weight;
  int restSeconds;
  bool isCompleted;

  ActiveSet({
    required this.reps,
    required this.weight,
    required this.restSeconds,
    this.isCompleted = false,
  });

  ActiveSet copyWith({
    int? reps,
    double? weight,
    int? restSeconds,
    bool? isCompleted,
  }) {
    return ActiveSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActiveExercise {
  final ExerciseModel exercise;
  final List<ActiveSet> sets;

  ActiveExercise({required this.exercise, required this.sets});

  ActiveExercise copyWith({ExerciseModel? exercise, List<ActiveSet>? sets}) {
    return ActiveExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
    );
  }
}

class ActiveSessionState {
  final String? templateId;
  final String workoutName;
  final List<ActiveExercise> exercises;
  final int elapsedSeconds;
  final int restSecondsRemaining;
  final bool isResting;
  final bool isLoading;
  final bool isTransitioning;
  final String transitionMessage;
  final int transitionSecondsRemaining;
  final bool isSaving;

  ActiveSessionState({
    this.templateId,
    this.workoutName = 'Free Workout',
    this.exercises = const [],
    this.elapsedSeconds = 0,
    this.restSecondsRemaining = 0,
    this.isResting = false,
    this.isLoading = true,
    this.isTransitioning = false,
    this.transitionMessage = '',
    this.transitionSecondsRemaining = 0,
    this.isSaving = false,
  });

  ActiveSessionState copyWith({
    String? templateId,
    String? workoutName,
    List<ActiveExercise>? exercises,
    int? elapsedSeconds,
    int? restSecondsRemaining,
    bool? isResting,
    bool? isLoading,
    bool? isTransitioning,
    String? transitionMessage,
    int? transitionSecondsRemaining,
    bool? isSaving,
  }) {
    return ActiveSessionState(
      templateId: templateId ?? this.templateId,
      workoutName: workoutName ?? this.workoutName,
      exercises: exercises ?? this.exercises,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      isResting: isResting ?? this.isResting,
      isLoading: isLoading ?? this.isLoading,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      transitionMessage: transitionMessage ?? this.transitionMessage,
      transitionSecondsRemaining:
          transitionSecondsRemaining ?? this.transitionSecondsRemaining,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);
  int get completedSets => exercises.fold(
    0,
    (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length,
  );
  double get progress => totalSets == 0 ? 0 : completedSets / totalSets;

  ActiveExercise? get currentExercise {
    try {
      return exercises.firstWhere((ex) => ex.sets.any((s) => !s.isCompleted));
    } catch (_) {
      return null;
    }
  }

  int? get currentSetIndex {
    final ex = currentExercise;
    if (ex == null) return null;
    return ex.sets.indexWhere((s) => !s.isCompleted);
  }

  String get nextUpText {
    final currEx = currentExercise;
    final currSetIdx = currentSetIndex;
    if (currEx == null || currSetIdx == null) return 'Sesi Selesai! 🎉';
    return '${currEx.exercise.name} - Set ${currSetIdx + 1}';
  }
}

class ActiveSessionNotifier extends Notifier<ActiveSessionState> {
  Timer? _sessionTimer;
  Timer? _restTimer;
  Timer? _transitionTimer;

  @override
  ActiveSessionState build() {
    ref.onDispose(() {
      _sessionTimer?.cancel();
      _restTimer?.cancel();
      _transitionTimer?.cancel();
    });
    return ActiveSessionState();
  }

  Future<void> initSession(String? templateId) async {
    state = ActiveSessionState(isLoading: true, templateId: templateId);

    if (templateId != null) {
      try {
        final repo = ref.read(workoutRepositoryProvider);
        final data = await repo.getWorkoutTemplateById(templateId);

        final name = data['name'] as String;
        final rawExercises = data['template_exercises'] as List;
        rawExercises.sort(
          (a, b) =>
              (a['order_index'] as int).compareTo(b['order_index'] as int),
        );

        List<ActiveExercise> loadedExercises = [];
        for (var te in rawExercises) {
          final exModel = ExerciseModel.fromMap(te['exercises']);
          final rawSets = te['exercise_sets'] as List;
          rawSets.sort(
            (a, b) =>
                (a['set_number'] as int).compareTo(b['set_number'] as int),
          );

          List<ActiveSet> loadedSets = rawSets
              .map(
                (s) => ActiveSet(
                  reps: s['reps'] ?? 0,
                  weight: (s['weight'] as num).toDouble(),
                  restSeconds: s['rest_seconds'] ?? 60,
                ),
              )
              .toList();

          loadedExercises.add(
            ActiveExercise(exercise: exModel, sets: loadedSets),
          );
        }

        state = state.copyWith(
          workoutName: name,
          exercises: loadedExercises,
          isLoading: false,
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          workoutName: 'Error Loading Template',
        );
      }
    } else {
      state = state.copyWith(isLoading: false);
    }

    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  // ============================================================
  // FITUR BARU [SES-05]: Tambah Exercise Spontan & Manipulasi Set
  // ============================================================

  void addSpontaneousExercise(ExerciseModel exercise) {
    final newExercise = ActiveExercise(
      exercise: exercise,
      sets: [
        ActiveSet(reps: 0, weight: 0, restSeconds: 60), // Default 1 set kosong
      ],
    );
    state = state.copyWith(exercises: [...state.exercises, newExercise]);
  }

  void addSet(int exIndex) {
    final list = List<ActiveExercise>.from(state.exercises);
    final ex = list[exIndex];

    // Copy data dari set terakhir untuk mempercepat input user
    ActiveSet newSet = ActiveSet(reps: 0, weight: 0, restSeconds: 60);
    if (ex.sets.isNotEmpty) {
      final last = ex.sets.last;
      newSet = ActiveSet(
        reps: last.reps,
        weight: last.weight,
        restSeconds: last.restSeconds,
      );
    }

    final updatedSets = List<ActiveSet>.from(ex.sets)..add(newSet);
    list[exIndex] = ex.copyWith(sets: updatedSets);

    state = state.copyWith(exercises: list);
  }

  void removeExercise(int exIndex) {
    final list = List<ActiveExercise>.from(state.exercises);
    list.removeAt(exIndex);
    state = state.copyWith(exercises: list);
  }

  // ============================================================

  void toggleSet(int exIndex, int setIndex) {
    final list = List<ActiveExercise>.from(state.exercises);
    final ex = list[exIndex];
    final currentSet = ex.sets[setIndex];

    final isNowCompleted = !currentSet.isCompleted;
    ex.sets[setIndex] = currentSet.copyWith(isCompleted: isNowCompleted);

    state = state.copyWith(exercises: list);

    if (isNowCompleted) {
      _startRestTimer(currentSet.restSeconds);
    } else {
      _cancelRest();
    }
  }

  void updateSetActuals(int exIndex, int setIndex, int reps, double weight) {
    final list = List<ActiveExercise>.from(state.exercises);
    list[exIndex].sets[setIndex] = list[exIndex].sets[setIndex].copyWith(
      reps: reps,
      weight: weight,
    );
    state = state.copyWith(exercises: list);
  }

  void _startRestTimer(int seconds) {
    if (seconds <= 0) return;
    _restTimer?.cancel();
    state = state.copyWith(isResting: true, restSecondsRemaining: seconds);

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restSecondsRemaining > 1) {
        state = state.copyWith(
          restSecondsRemaining: state.restSecondsRemaining - 1,
        );
      } else {
        NotificationService.showRestFinishedNotification();
        _showTransitionSplash();
      }
    });
  }

  void addRestTime(int seconds) {
    if (state.isResting) {
      state = state.copyWith(
        restSecondsRemaining: state.restSecondsRemaining + seconds,
      );
    }
  }

  void _cancelRest() {
    _restTimer?.cancel();
    state = state.copyWith(isResting: false, restSecondsRemaining: 0);
  }

  void skipRest() {
    _showTransitionSplash();
  }

  void _showTransitionSplash() {
    _restTimer?.cancel();
    _transitionTimer?.cancel();

    final quotes = [
      "Bakar lemaknya, bangun ototnya! 🔥",
      "Sakit sekarang, bangga kemudian! 💪",
      "Satu set lagi, kamu pasti bisa! 😤",
      "Jangan berhenti saat lelah! 💯",
      "Fokus! Hasil menunggumu! ✨",
      "Batasmu hanya ada di pikiranmu! 🚀",
      "Keringat hari ini adalah kekuatan besok! 💦",
    ];

    final quote = quotes[Random().nextInt(quotes.length)];
    final durationSeconds = Random().nextInt(3) + 3;

    state = state.copyWith(
      isResting: false,
      restSecondsRemaining: 0,
      isTransitioning: true,
      transitionMessage: quote,
      transitionSecondsRemaining: durationSeconds,
    );

    _transitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.transitionSecondsRemaining > 1) {
        state = state.copyWith(
          transitionSecondsRemaining: state.transitionSecondsRemaining - 1,
        );
      } else {
        timer.cancel();
        state = state.copyWith(
          isTransitioning: false,
          transitionSecondsRemaining: 0,
        );
      }
    });
  }

  // MENGGANTI FUNGSI finishWorkout()
  Future<SessionSummaryArgs?> finishWorkout({
    bool updateTemplate = false,
  }) async {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    _transitionTimer?.cancel();

    state = state.copyWith(isSaving: true);

    try {
      double totalVolume = 0;
      int setsDone = 0;
      List<Map<String, dynamic>> exData = [];

      for (var ex in state.exercises) {
        double maxWeight = 0;
        List<Map<String, dynamic>> setsData = [];
        for (int i = 0; i < ex.sets.length; i++) {
          final s = ex.sets[i];
          if (s.isCompleted) {
            setsDone++;
            totalVolume += (s.weight * s.reps);
            if (s.weight > maxWeight) maxWeight = s.weight;
          }
          setsData.add({
            'set_number': i + 1,
            'reps': s.reps,
            'weight': s.weight,
            'rest_seconds': s.restSeconds, // [BARU] Bawa data rest time
            'is_completed': s.isCompleted,
          });
        }
        exData.add({
          'exercise_id': ex.exercise.id,
          'exercise_name': ex.exercise.name,
          'max_weight': maxWeight,
          'sets': setsData,
        });
      }

      final repo = ref.read(workoutRepositoryProvider);

      // 1. Simpan Sesi Historis
      final result = await repo.saveWorkoutSession(
        templateId: state.templateId,
        name: state.workoutName,
        durationSeconds: state.elapsedSeconds,
        totalVolume: totalVolume,
        exercisesData: exData,
      );

      // ========================================================
      // INTEGRASI KITA [PRG-03]: CEK PR SETELAH SESI DISIMPAN
      // ========================================================
      final sessionId = result['id'] ?? result['session_id']; 
      List<String> prList = [];

      if (sessionId != null) {
        prList = await ref.read(progressRepositoryProvider).checkNewPRsForSession(sessionId.toString());
      } else if (result['pr_messages'] != null) {
        prList = List<String>.from(result['pr_messages']);
      }
      // ========================================================

      // 2. [FITUR BARU] Update Template Asli jika diminta user
      if (updateTemplate && state.templateId != null) {
        await repo.syncTemplateWithSession(state.templateId!, exData);
        ref.invalidate(
          workoutTemplatesProvider,
        ); // Refresh daftar template di beranda
      }

      state = state.copyWith(isSaving: false);

      return SessionSummaryArgs(
        workoutName: state.workoutName,
        durationSeconds: state.elapsedSeconds,
        totalVolume: totalVolume,
        completedSets: setsDone,
        prMessages: prList, // <-- Menggunakan list PR yang berhasil kita cek
      );
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return null;
    }
  }
}

final activeSessionProvider =
    NotifierProvider<ActiveSessionNotifier, ActiveSessionState>(() {
      return ActiveSessionNotifier();
    });