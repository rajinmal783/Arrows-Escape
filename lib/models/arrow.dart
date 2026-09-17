import 'package:flutter/material.dart';

enum ArrowDirection { up, down, left, right }

enum ArrowState { available, blocked, selected, moving, cleared }

class GridPoint {
  final int row;
  final int col;

  const GridPoint(this.row, this.col);

  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  factory GridPoint.fromJson(Map<String, dynamic> json) =>
      GridPoint(json['row'] as int, json['col'] as int);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPoint &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}

class Arrow {
  final String id;
  final List<GridPoint> path; // Head is path.last
  final ArrowDirection direction;
  final ArrowState state;
  final Color? customColor;
  final double animationProgress; // 0.0 to 1.0 when escaping

  const Arrow({
    required this.id,
    required this.path,
    required this.direction,
    this.state = ArrowState.available,
    this.customColor,
    this.animationProgress = 0.0,
  });

  GridPoint get head => path.last;
  GridPoint get tail => path.first;

  Arrow copyWith({
    String? id,
    List<GridPoint>? path,
    ArrowDirection? direction,
    ArrowState? state,
    Color? customColor,
    double? animationProgress,
  }) {
    return Arrow(
      id: id ?? this.id,
      path: path ?? this.path,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      customColor: customColor ?? this.customColor,
      animationProgress: animationProgress ?? this.animationProgress,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path.map((p) => p.toJson()).toList(),
        'direction': direction.name,
        'customColor': customColor?.toARGB32(),
      };

  factory Arrow.fromJson(Map<String, dynamic> json) {
    return Arrow(
      id: json['id'] as String,
      path: (json['path'] as List)
          .map((p) => GridPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      direction: ArrowDirection.values.firstWhere(
        (d) => d.name == json['direction'],
        orElse: () => ArrowDirection.up,
      ),
      customColor: json['customColor'] != null
          ? Color(json['customColor'] as int)
          : null,
    );
  }
}
