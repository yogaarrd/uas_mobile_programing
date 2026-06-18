class ProgressStats {
  final int totalSessions;
  final double totalVolume;
  final int totalDurationSeconds;
  final double avgSessionsPerWeek;

  ProgressStats({
    required this.totalSessions,
    required this.totalVolume,
    required this.totalDurationSeconds,
    required this.avgSessionsPerWeek,
  });
}

class PerformedExercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String? imageUrl;

  PerformedExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.imageUrl,
  });
}

class ProgressOverviewData {
  final ProgressStats stats;
  final List<PerformedExercise> exercises;

  ProgressOverviewData({
    required this.stats,
    required this.exercises,
  });
}