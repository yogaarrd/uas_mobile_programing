class BodyMeasurement {
  final String id;
  final String userId;
  final DateTime measuredAt;
  final double weightKg;
  final String? note;
  final DateTime createdAt;

  BodyMeasurement({
    required this.id,
    required this.userId,
    required this.measuredAt,
    required this.weightKg,
    this.note,
    required this.createdAt,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'measured_at': measuredAt.toIso8601String().split('T').first,
      'weight_kg': weightKg,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }

  BodyMeasurement copyWith({
    String? id,
    String? userId,
    DateTime? measuredAt,
    double? weightKg,
    String? note,
    DateTime? createdAt,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
