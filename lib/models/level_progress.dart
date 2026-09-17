class LevelProgress {
  final int levelId;
  final bool completed;
  final int stars;
  final int bestScore;
  final int? bestMoves;
  final int attempts;
  final int hintsUsed;
  final DateTime? completedAt;

  const LevelProgress({
    required this.levelId,
    this.completed = false,
    this.stars = 0,
    this.bestScore = 0,
    this.bestMoves,
    this.attempts = 0,
    this.hintsUsed = 0,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'level_id': levelId,
        'completed': completed,
        'stars': stars,
        'best_score': bestScore,
        'best_moves': bestMoves,
        'attempts': attempts,
        'hints_used': hintsUsed,
        'completed_at': completedAt?.toIso8601String(),
      };

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelId: json['level_id'] as int,
      completed: json['completed'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
      bestScore: json['best_score'] as int? ?? 0,
      bestMoves: json['best_moves'] as int?,
      attempts: json['attempts'] as int? ?? 0,
      hintsUsed: json['hints_used'] as int? ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }

  LevelProgress copyWith({
    int? levelId,
    bool? completed,
    int? stars,
    int? bestScore,
    int? bestMoves,
    int? attempts,
    int? hintsUsed,
    DateTime? completedAt,
  }) {
    return LevelProgress(
      levelId: levelId ?? this.levelId,
      completed: completed ?? this.completed,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      bestMoves: bestMoves ?? this.bestMoves,
      attempts: attempts ?? this.attempts,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
