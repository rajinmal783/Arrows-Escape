class Achievement {
  final String id;
  final String code;
  final String name;
  final String description;
  final String icon;
  final String requirementType;
  final int requirementValue;
  final int rewardXp;
  final int rewardCoins;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirementType,
    required this.requirementValue,
    this.rewardXp = 50,
    this.rewardCoins = 25,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'icon': icon,
        'requirement_type': requirementType,
        'requirement_value': requirementValue,
        'reward_xp': rewardXp,
        'reward_coins': rewardCoins,
        'is_unlocked': isUnlocked,
        'unlocked_at': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String? ?? json['code'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '🏆',
      requirementType: json['requirement_type'] as String? ?? 'general',
      requirementValue: json['requirement_value'] as int? ?? 1,
      rewardXp: json['reward_xp'] as int? ?? 50,
      rewardCoins: json['reward_coins'] as int? ?? 25,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'] as String)
          : null,
    );
  }

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      code: code,
      name: name,
      description: description,
      icon: icon,
      requirementType: requirementType,
      requirementValue: requirementValue,
      rewardXp: rewardXp,
      rewardCoins: rewardCoins,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
