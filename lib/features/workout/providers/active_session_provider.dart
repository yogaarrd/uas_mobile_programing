import 'dart:async';
import 'dart:math'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_models.dart';
import '../repositories/workout_repository.dart';
import 'workout_provider.dart';
import '../../../core/services/notification_service.dart';
import '../models/session_summary_args.dart';

class ActiveSet {
  int reps;
  double weight;
  int restSeconds;
  bool isCompleted;

  ActiveSet({required this.reps, required this.weight, required this.restSeconds, this.isCompleted = false});

  ActiveSet copyWith({int? reps, double? weight, int? restSeconds, bool? isCompleted}) {
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
    return ActiveExercise(exercise: exercise ?? this.exercise, sets: sets ?? this.sets);
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
  
  // STATE SPLASH SCREEN
  final bool isTransitioning;
  final String transitionMessage;
  final int transitionSecondsRemaining; // Tambahan untuk waktu loading splash
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
    this.isSaving = false, // Default false
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
      transitionSecondsRemaining: transitionSecondsRemaining ?? this.transitionSecondsRemaining,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);
  int get completedSets => exercises.fold(0, (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length);
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
        rawExercises.sort((a, b) => (a['order_index'] as int).compareTo(b['order_index'] as int));

        List<ActiveExercise> loadedExercises = [];
        for (var te in rawExercises) {
          final exModel = ExerciseModel.fromMap(te['exercises']);
          final rawSets = te['exercise_sets'] as List;
          rawSets.sort((a, b) => (a['set_number'] as int).compareTo(b['set_number'] as int));

          List<ActiveSet> loadedSets = rawSets.map((s) => ActiveSet(
            reps: s['reps'] ?? 0,
            weight: (s['weight'] as num).toDouble(),
            restSeconds: s['rest_seconds'] ?? 60,
          )).toList();

          loadedExercises.add(ActiveExercise(exercise: exModel, sets: loadedSets));
        }

        state = state.copyWith(workoutName: name, exercises: loadedExercises, isLoading: false);
      } catch (e) {
        state = state.copyWith(isLoading: false, workoutName: 'Error Loading Template');
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
    list[exIndex].sets[setIndex] = list[exIndex].sets[setIndex].copyWith(reps: reps, weight: weight);
    state = state.copyWith(exercises: list);
  }

  void _startRestTimer(int seconds) {
    if (seconds <= 0) return;
    _restTimer?.cancel();
    state = state.copyWith(isResting: true, restSecondsRemaining: seconds);
    
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restSecondsRemaining > 1) {
        state = state.copyWith(restSecondsRemaining: state.restSecondsRemaining - 1);
      } else {
        // [FITUR BARU]: Waktu habis secara natural (bukan di-skip)
        // 1. Panggil notifikasi suara & getar
        NotificationService.showRestFinishedNotification();
        // 2. Munculkan splash screen
        _showTransitionSplash(); 
      }
    });
  }

  void addRestTime(int seconds) {
    if (state.isResting) {
      state = state.copyWith(restSecondsRemaining: state.restSecondsRemaining + seconds);
    }
  }

  void _cancelRest() {
    _restTimer?.cancel();
    state = state.copyWith(isResting: false, restSecondsRemaining: 0);
  }

  void skipRest() {
    _showTransitionSplash();
  }

  // --- LOGIKA SPLASH SCREEN DIPERBARUI ---
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
      "Keringat hari ini adalah kekuatan besok! 💦"
    ];
    
    final quote = quotes[Random().nextInt(quotes.length)];
    final durationSeconds = Random().nextInt(3) + 3; // Acak antara 3 sampai 5 detik

    state = state.copyWith(
      isResting: false,
      restSecondsRemaining: 0,
      isTransitioning: true,
      transitionMessage: quote,
      transitionSecondsRemaining: durationSeconds,
    );

    // Timer berjalan setiap detik untuk mengupdate loading countdown
    _transitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.transitionSecondsRemaining > 1) {
        state = state.copyWith(transitionSecondsRemaining: state.transitionSecondsRemaining - 1);
      } else {
        timer.cancel();
        state = state.copyWith(isTransitioning: false, transitionSecondsRemaining: 0);
      }
    });
  }

// MENGGANTI FUNGSI finishWorkout()
  Future<SessionSummaryArgs?> finishWorkout() async {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    _transitionTimer?.cancel();

    state = state.copyWith(isSaving: true);

    try {
      double totalVolume = 0;
      int setsDone = 0;
      List<Map<String, dynamic>> exData = [];

      // Kalkulasi semua data set
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

      // Panggil Repo untuk Simpan ke DB
      final repo = ref.read(workoutRepositoryProvider);
      final result = await repo.saveWorkoutSession(
        templateId: state.templateId,
        name: state.workoutName,
        durationSeconds: state.elapsedSeconds,
        totalVolume: totalVolume,
        exercisesData: exData,
      );
      
      state = state.copyWith(isSaving: false);
      
      // Kembalikan argumen untuk Summary Page
      return SessionSummaryArgs(
        workoutName: state.workoutName,
        durationSeconds: state.elapsedSeconds,
        totalVolume: totalVolume,
        completedSets: setsDone,
        prMessages: List<String>.from(result['pr_messages']),
      );

    } catch (e) {
      state = state.copyWith(isSaving: false);
      return null; 
    }
  }
}

final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, ActiveSessionState>(() {
  return ActiveSessionNotifier();
});