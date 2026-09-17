import 'dart:math';
import 'package:flutter/material.dart';
import '../models/arrow.dart';
import '../core/constants/app_colors.dart';

class PuzzlePainter extends CustomPainter {
  final List<Arrow> arrows;
  final int rows;
  final int cols;
  final bool isDark;
  final bool showGrid;
  final String? hintArrowId;
  final String? blockedArrowId;
  final String? obstructingArrowId;
  final double pulseValue; // 0.0 to 1.0 for hint breathing effect

  PuzzlePainter({
    required this.arrows,
    required this.rows,
    required this.cols,
    required this.isDark,
    required this.showGrid,
    this.hintArrowId,
    this.blockedArrowId,
    this.obstructingArrowId,
    this.pulseValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Determine cell sizing with uniform margins
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    final cellSize = min(cellWidth, cellHeight);

    final offsetX = (size.width - (cellSize * cols)) / 2.0;
    final offsetY = (size.height - (cellSize * rows)) / 2.0;

    // 1. Draw subtle background grid if enabled
    if (showGrid) {
      final dotPaint = Paint()
        ..color = (isDark ? AppColors.gridDotDark : AppColors.gridDot).withOpacity(0.5)
        ..style = PaintingStyle.fill;

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final cx = offsetX + (c + 0.5) * cellSize;
          final cy = offsetY + (r + 0.5) * cellSize;
          canvas.drawCircle(Offset(cx, cy), 1.8, dotPaint);
        }
      }
    }

    // Default stroke properties
    final baseStrokeWidth = max(3.5, cellSize * 0.16);
    final defaultLineColor = isDark ? AppColors.puzzleLineDark : AppColors.puzzleLineLight;

    // 2. Render each active arrow
    for (final arrow in arrows) {
      if (arrow.state == ArrowState.cleared) continue;

      Color lineColor = defaultLineColor;
      double strokeWidth = baseStrokeWidth;

      // State-based coloring & effects
      final isHinted = arrow.id == hintArrowId;
      final isBlocked = arrow.id == blockedArrowId;
      final isObstructing = arrow.id == obstructingArrowId;
      final isMoving = arrow.state == ArrowState.moving;

      if (isHinted) {
        lineColor = AppColors.hintPulseGlow;
        strokeWidth = baseStrokeWidth * (1.1 + 0.15 * sin(pulseValue * pi * 2));
      } else if (isBlocked) {
        lineColor = AppColors.blockedMoveHighlight;
      } else if (isObstructing) {
        lineColor = AppColors.accentAmber;
      } else if (isMoving) {
        lineColor = AppColors.validMoveHighlight;
      } else if (arrow.customColor != null) {
        lineColor = arrow.customColor!;
      }

      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Draw arrow path
      final path = Path();
      for (int i = 0; i < arrow.path.length; i++) {
        final pt = arrow.path[i];
        final x = offsetX + (pt.col + 0.5) * cellSize;
        final y = offsetY + (pt.row + 0.5) * cellSize;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, linePaint);

      // Draw arrowhead at head position
      _drawArrowHead(
        canvas: canvas,
        headPoint: arrow.head,
        direction: arrow.direction,
        offsetX: offsetX,
        offsetY: offsetY,
        cellSize: cellSize,
        color: lineColor,
        isHinted: isHinted,
        pulseValue: pulseValue,
      );
    }
  }

  void _drawArrowHead({
    required Canvas canvas,
    required GridPoint headPoint,
    required ArrowDirection direction,
    required double offsetX,
    required double offsetY,
    required double cellSize,
    required Color color,
    required bool isHinted,
    required double pulseValue,
  }) {
    final cx = offsetX + (headPoint.col + 0.5) * cellSize;
    final cy = offsetY + (headPoint.row + 0.5) * cellSize;

    final headSize = cellSize * 0.42;
    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Hint glow around arrowhead
    if (isHinted) {
      final glowPaint = Paint()
        ..color = AppColors.hintPulseGlow.withOpacity(0.35 + 0.2 * sin(pulseValue * pi * 2))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), headSize * 1.5, glowPaint);
    }

    final path = Path();
    switch (direction) {
      case ArrowDirection.up:
        path.moveTo(cx, cy - headSize * 0.9);
        path.lineTo(cx - headSize * 0.65, cy + headSize * 0.4);
        path.lineTo(cx + headSize * 0.65, cy + headSize * 0.4);
        break;

      case ArrowDirection.down:
        path.moveTo(cx, cy + headSize * 0.9);
        path.lineTo(cx - headSize * 0.65, cy - headSize * 0.4);
        path.lineTo(cx + headSize * 0.65, cy - headSize * 0.4);
        break;

      case ArrowDirection.left:
        path.moveTo(cx - headSize * 0.9, cy);
        path.lineTo(cx + headSize * 0.4, cy - headSize * 0.65);
        path.lineTo(cx + headSize * 0.4, cy + headSize * 0.65);
        break;

      case ArrowDirection.right:
        path.moveTo(cx + headSize * 0.9, cy);
        path.lineTo(cx - headSize * 0.4, cy - headSize * 0.65);
        path.lineTo(cx - headSize * 0.4, cy + headSize * 0.65);
        break;
    }
    path.close();
    canvas.drawPath(path, headPaint);
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return true; // Fast redraw on pulse/animation state
  }
}
