class UserProfile {
  final String id;
  final String username;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int coins;
  final int totalStars;
  final int currentStreak;
  final int longestStreak;
  final int hintsCount;
  final int undosCount;

  const UserProfile({
    required this.id,
    required this.username,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.coins = 100,
    this.totalStars = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.hintsCount = 3,
    this.undosCount = 3,
  });

  int get nextLevelXp => level * 150;
  double get xpProgress => xp.remainder(150) / 150.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'full_name': fullName,
        'email': email,
        'avatar_url': avatarUrl,
        'level': level,
        'xp': xp,
        'coins': coins,
        'total_stars': totalStars,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'hints_count': hintsCount,
        'undos_count': undosCount,
      };

  /// Schema mapping specifically for public.profiles in Supabase (excluding inventory columns)
  Map<String, dynamic> toSupabaseProfileMap() => {
        'id': id,
        'username': username,
        'full_name': fullName,
        'email': email,
        'avatar_url': avatarUrl,
        'level': level,
        'xp': xp,
        'coins': coins,
        'total_stars': totalStars,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'updated_at': DateTime.now().toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Player',
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 100,
      totalStars: json['total_stars'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      hintsCount: json['hints_count'] as int? ?? 3,
      undosCount: json['undos_count'] as int? ?? 3,
    );
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? avatarUrl,
    int? level,
    int? xp,
    int? coins,
    int? totalStars,
    int? currentStreak,
    int? longestStreak,
    int? hintsCount,
    int? undosCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      totalStars: totalStars ?? this.totalStars,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      hintsCount: hintsCount ?? this.hintsCount,
      undosCount: undosCount ?? this.undosCount,
    );
  }
}
