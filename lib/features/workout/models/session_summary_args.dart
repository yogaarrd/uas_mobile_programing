class SessionSummaryArgs {
  final String workoutName;
  final int durationSeconds;
  final double totalVolume;
  final int completedSets;
  final List<String> prMessages;

  SessionSummaryArgs({
    required this.workoutName,
    required this.durationSeconds,
    required this.totalVolume,
    required this.completedSets,
    required this.prMessages,
  });
}