class LeaderboardEntry {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int playerLevel;
  final int score;
  final int stars;
  final int rank;
  final String periodType;

  const LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.playerLevel = 1,
    required this.score,
    required this.stars,
    required this.rank,
    required this.periodType,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? 'Player',
      avatarUrl: json['avatar_url'] as String?,
      playerLevel: json['player_level'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      rank: json['rank'] as int? ?? 1,
      periodType: json['period_type'] as String? ?? 'all_time',
    );
  }
}
