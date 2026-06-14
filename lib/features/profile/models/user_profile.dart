enum FitnessGoal {
  strength('Strength'),
  hypertrophy('Hypertrophy'),
  weightLoss('Weight Loss'),
  generalFitness('General Fitness');

  final String label;
  const FitnessGoal(this.label);

  static FitnessGoal fromString(String value) {
    return FitnessGoal.values.firstWhere(
      (e) => e.label == value,
      orElse: () => FitnessGoal.generalFitness,
    );
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final double weightKg;
  final double heightCm;
  final FitnessGoal goal;
  final String? avatarUrl; // URL foto profil dari Supabase Storage
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.weightKg,
    required this.heightCm,
    required this.goal,
    this.avatarUrl,
    this.createdAt,
  });

  /// Buat salinan dengan field yang diubah
  UserProfile copyWith({
    String? fullName,
    DateTime? birthDate,
    double? weightKg,
    double? heightCm,
    FitnessGoal? goal,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      goal: goal ?? this.goal,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      heightCm: (json['height_cm'] as num).toDouble(),
      goal: FitnessGoal.fromString(json['goal'] as String),
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date':
          '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'goal': goal.label,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}
