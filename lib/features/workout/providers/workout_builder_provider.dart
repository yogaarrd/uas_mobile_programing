import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_builder_models.dart';
import '../models/exercise_models.dart';
import '../repositories/workout_repository.dart';
import 'workout_provider.dart';

class WorkoutBuilderState {
  final String? templateId;
  final String name;
  final String description; // TAMBAHAN: Deskripsi
  final List<TemplateExerciseFormData> exercises;
  final bool isLoading;
  final String? error;
  final bool isSaved;

  WorkoutBuilderState({
    this.templateId,
    this.name = '',
    this.description = '', // TAMBAHAN
    this.exercises = const [],
    this.isLoading = false,
    this.error,
    this.isSaved = false,
  });

  WorkoutBuilderState copyWith({
    String? templateId,
    String? name,
    String? description, // TAMBAHAN
    List<TemplateExerciseFormData>? exercises,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isSaved,
  }) {
    return WorkoutBuilderState(
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      description: description ?? this.description, // TAMBAHAN
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class WorkoutBuilderNotifier extends Notifier<WorkoutBuilderState> {
  @override
  WorkoutBuilderState build() => WorkoutBuilderState();

  void clear() {
    state = WorkoutBuilderState();
  }

  Future<void> initForEdit(String templateId) async {
    state = WorkoutBuilderState(isLoading: true, templateId: templateId);
    try {
      final repo = ref.read(workoutRepositoryProvider);
      final data = await repo.getWorkoutTemplateById(templateId);

      final name = data['name'] as String;
      final description = data['description'] as String? ?? ''; // TAMBAHAN
      final rawExercises = data['template_exercises'] as List;

      rawExercises.sort((a, b) => (a['order_index'] as int).compareTo(b['order_index'] as int));

      List<TemplateExerciseFormData> loadedExercises = [];
      for (var te in rawExercises) {
        final exModel = ExerciseModel.fromMap(te['exercises']);
        final rawSets = te['exercise_sets'] as List;
        rawSets.sort((a, b) => (a['set_number'] as int).compareTo(b['set_number'] as int));

        List<ExerciseSetFormData> loadedSets = rawSets.map((s) => ExerciseSetFormData(
          reps: s['reps'] ?? 0,
          weight: (s['weight'] as num).toDouble(),
          restSeconds: s['rest_seconds'] ?? 0,
        )).toList();

        loadedExercises.add(TemplateExerciseFormData(
          uniqueId: generateUniqueId(),
          exercise: exModel,
          sets: loadedSets,
        ));
      }

      state = state.copyWith(name: name, description: description, exercises: loadedExercises, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setName(String name) => state = state.copyWith(name: name);
  void setDescription(String desc) => state = state.copyWith(description: desc);

  void addExercise(ExerciseModel exercise) {
    final newEx = TemplateExerciseFormData(
      uniqueId: generateUniqueId(), exercise: exercise, sets: [ExerciseSetFormData()],
    );
    state = state.copyWith(exercises: [...state.exercises, newEx]);
  }

  void removeExercise(int index) {
    final list = List<TemplateExerciseFormData>.from(state.exercises);
    list.removeAt(index);
    state = state.copyWith(exercises: list);
  }

  void reorderExercises(int oldIndex, int newIndex) {
    final list = List<TemplateExerciseFormData>.from(state.exercises);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(exercises: list);
  }

  void addSet(int exerciseIndex) {
    final list = List<TemplateExerciseFormData>.from(state.exercises);
    final ex = list[exerciseIndex];
    ExerciseSetFormData newSet = ExerciseSetFormData();
    if (ex.sets.isNotEmpty) {
      final last = ex.sets.last;
      newSet = ExerciseSetFormData(reps: last.reps, weight: last.weight, restSeconds: last.restSeconds);
    }
    ex.sets.add(newSet);
    state = state.copyWith(exercises: list);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    final list = List<TemplateExerciseFormData>.from(state.exercises);
    list[exerciseIndex].sets.removeAt(setIndex);
    state = state.copyWith(exercises: list);
  }

  void updateSet(int exerciseIndex, int setIndex, {int? reps, double? weight, int? rest}) {
    final list = List<TemplateExerciseFormData>.from(state.exercises);
    list[exerciseIndex].sets[setIndex] = list[exerciseIndex].sets[setIndex].copyWith(
      reps: reps, weight: weight, restSeconds: rest,
    );
    state = state.copyWith(exercises: list);
  }

  Future<void> save() async {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(error: 'Nama workout tidak boleh kosong');
      return;
    }
    if (state.exercises.isEmpty) {
      state = state.copyWith(error: 'Tambahkan minimal 1 latihan');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.saveWorkoutTemplate(
        templateId: state.templateId,
        name: state.name.trim(),
        description: state.description.trim(), // TAMBAHAN
        exercises: state.exercises,
      );
      ref.invalidate(workoutTemplatesProvider); 
      state = state.copyWith(isLoading: false, isSaved: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final workoutBuilderProvider = NotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>(() {
  return WorkoutBuilderNotifier();
});