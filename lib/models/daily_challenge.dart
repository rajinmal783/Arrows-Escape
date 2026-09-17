class DailyChallenge {
  final String id;
  final DateTime challengeDate;
  final int seed;
  final String difficulty;
  final int targetMoves;
  final int rewardXp;
  final int rewardCoins;
  final bool isCompleted;
  final bool rewardClaimed;
  final int? userMoves;
  final int? userScore;

  const DailyChallenge({
    required this.id,
    required this.challengeDate,
    required this.seed,
    required this.difficulty,
    required this.targetMoves,
    this.rewardXp = 150,
    this.rewardCoins = 75,
    this.isCompleted = false,
    this.rewardClaimed = false,
    this.userMoves,
    this.userScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'challenge_date': challengeDate.toIso8601String().split('T').first,
        'seed': seed,
        'difficulty': difficulty,
        'target_moves': targetMoves,
        'reward_xp': rewardXp,
        'reward_coins': rewardCoins,
        'is_completed': isCompleted,
        'reward_claimed': rewardClaimed,
        'user_moves': userMoves,
        'user_score': userScore,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String? ?? 'daily_${json['challenge_date']}',
      challengeDate: DateTime.tryParse(json['challenge_date'] as String) ?? DateTime.now(),
      seed: json['seed'] as int? ?? 42,
      difficulty: json['difficulty'] as String? ?? 'Hard',
      targetMoves: json['target_moves'] as int? ?? 25,
      rewardXp: json['reward_xp'] as int? ?? 150,
      rewardCoins: json['reward_coins'] as int? ?? 75,
      isCompleted: json['is_completed'] as bool? ?? false,
      rewardClaimed: json['reward_claimed'] as bool? ?? false,
      userMoves: json['user_moves'] as int?,
      userScore: json['user_score'] as int?,
    );
  }

  DailyChallenge copyWith({
    bool? isCompleted,
    bool? rewardClaimed,
    int? userMoves,
    int? userScore,
  }) {
    return DailyChallenge(
      id: id,
      challengeDate: challengeDate,
      seed: seed,
      difficulty: difficulty,
      targetMoves: targetMoves,
      rewardXp: rewardXp,
      rewardCoins: rewardCoins,
      isCompleted: isCompleted ?? this.isCompleted,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      userMoves: userMoves ?? this.userMoves,
      userScore: userScore ?? this.userScore,
    );
  }
}
