import 'arrow.dart';

class PuzzleLevel {
  final int id;
  final String difficulty;
  final int rows;
  final int columns;
  final int seed;
  final int targetMoves;
  final int parMoves;
  final String shape;
  final List<Arrow> arrows;

  const PuzzleLevel({
    required this.id,
    required this.difficulty,
    required this.rows,
    required this.columns,
    required this.seed,
    required this.targetMoves,
    required this.parMoves,
    this.shape = 'geometric',
    required this.arrows,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty,
        'rows': rows,
        'columns': columns,
        'seed': seed,
        'targetMoves': targetMoves,
        'parMoves': parMoves,
        'shape': shape,
        'arrows': arrows.map((a) => a.toJson()).toList(),
      };

  factory PuzzleLevel.fromJson(Map<String, dynamic> json) {
    return PuzzleLevel(
      id: json['id'] as int,
      difficulty: json['difficulty'] as String? ?? 'Normal',
      rows: json['rows'] as int,
      columns: json['columns'] as int,
      seed: json['seed'] as int? ?? json['id'] as int,
      targetMoves: json['targetMoves'] as int? ?? (json['arrows'] as List).length,
      parMoves: json['parMoves'] as int? ?? ((json['arrows'] as List).length * 1.2).ceil(),
      shape: json['shape'] as String? ?? 'geometric',
      arrows: (json['arrows'] as List)
          .map((a) => Arrow.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
