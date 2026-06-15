class WorkoutSession {
  final String id;
  final String name;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? durationSeconds;
  final double totalVolumeKg;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.name,
    required this.startedAt,
    this.finishedAt,
    this.durationSeconds,
    this.totalVolumeKg = 0.0,
    this.notes,
  });

  // Fungsi untuk mengubah data JSON dari Supabase menjadi object Dart
  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      name: json['name'] as String,
      startedAt: DateTime.parse(json['started_at'] as String).toLocal(),
      finishedAt: json['finished_at'] != null 
          ? DateTime.parse(json['finished_at'] as String).toLocal() 
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      totalVolumeKg: (json['total_volume_kg'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );
  }
}