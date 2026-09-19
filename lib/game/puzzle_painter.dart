import 'dart:math';
import 'package:flutter/material.dart';
import '../models/arrow.dart';
import '../core/constants/app_colors.dart';

class PuzzlePainter extends CustomPainter {
  final List<Arrow> arrows;
  final int rows;
  final int cols;
  final String difficulty;
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
    required this.difficulty,
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

    final isEasyOrMedium = difficulty == 'Beginner' || difficulty == 'Normal';

    // 0. Draw board background for Easy/Medium
    if (isEasyOrMedium) {
      final bgRect = Rect.fromLTWH(offsetX, offsetY, cellSize * cols, cellSize * rows);
      final bgPaint = Paint()
        ..color = (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withAlpha(128)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(12)), bgPaint);
    }

    // 1. Draw subtle background grid ONLY for Easy/Medium levels
    if (isEasyOrMedium && showGrid) {
      final dotPaint = Paint()
        ..color = (isDark ? AppColors.gridDotDark : AppColors.gridDot).withAlpha(230)
        ..style = PaintingStyle.fill;

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final cx = offsetX + (c + 0.5) * cellSize;
          final cy = offsetY + (r + 0.5) * cellSize;
          canvas.drawCircle(Offset(cx, cy), 2.2, dotPaint);
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

      if (isMoving) {
        final baseColor = arrow.customColor ?? (isDark ? const Color(0xFF38BDF8) : AppColors.primaryBlue);
        final fadeOut = (1.0 - ((arrow.animationProgress - 0.70) / 0.30).clamp(0.0, 1.0));
        lineColor = baseColor.withAlpha((fadeOut * 255).toInt());
        strokeWidth = baseStrokeWidth * 1.15;
      } else if (isHinted) {
        lineColor = AppColors.hintPulseGlow;
        strokeWidth = baseStrokeWidth * (1.1 + 0.15 * sin(pulseValue * pi * 2));
      } else if (isBlocked) {
        lineColor = AppColors.blockedMoveHighlight;
      } else if (isObstructing) {
        lineColor = AppColors.accentAmber;
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
      if (isMoving) {
        _drawSnakePath(
          canvas: canvas,
          arrow: arrow,
          offsetX: offsetX,
          offsetY: offsetY,
          cellSize: cellSize,
          linePaint: linePaint,
          rows: rows,
          cols: cols,
        );
      } else {
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
  }

  void _drawSnakePath({
    required Canvas canvas,
    required Arrow arrow,
    required double offsetX,
    required double offsetY,
    required double cellSize,
    required Paint linePaint,
    required int rows,
    required int cols,
  }) {
    // 1. Construct the extended path the snake will follow
    final List<Offset> points = [];
    for (final pt in arrow.path) {
      points.add(Offset(
        offsetX + (pt.col + 0.5) * cellSize,
        offsetY + (pt.row + 0.5) * cellSize,
      ));
    }

    // Extend path out of board
    final lastPoint = points.last;
    final maxDist = max(rows, cols) + 3.0;
    Offset dirOffset;
    switch (arrow.direction) {
      case ArrowDirection.up:
        dirOffset = Offset(0, -cellSize);
        break;
      case ArrowDirection.down:
        dirOffset = Offset(0, cellSize);
        break;
      case ArrowDirection.left:
        dirOffset = Offset(-cellSize, 0);
        break;
      case ArrowDirection.right:
        dirOffset = Offset(cellSize, 0);
        break;
    }

    for (int i = 1; i <= maxDist.toInt(); i++) {
      points.add(lastPoint + dirOffset * i.toDouble());
    }

    // 2. Calculate the portion of the path to draw
    final double snakeLength = (arrow.path.length - 1).toDouble();
    final double totalTravel = points.length.toDouble() - 1.0;

    final double currentHeadDist = snakeLength + (totalTravel - snakeLength + 2.0) * arrow.animationProgress;
    final double currentTailDist = currentHeadDist - snakeLength;

    final pathLength = points.length.toDouble();
    final newPath = Path();
    bool firstPoint = true;

    // Sample the path and apply organic serpentine wave perpendicular to segment direction
    for (double d = currentTailDist; d <= currentHeadDist; d += 0.04) {
      final clampedD = d.clamp(0.0, pathLength - 1.0);
      final pos = _getPointAtDistance(points, clampedD);

      // Compute local tangent and normal along the polyline
      final dAhead = (clampedD + 0.1).clamp(0.0, pathLength - 1.0);
      final dBehind = (clampedD - 0.1).clamp(0.0, pathLength - 1.0);
      final pAhead = _getPointAtDistance(points, dAhead);
      final pBehind = _getPointAtDistance(points, dBehind);
      final tangent = pAhead - pBehind;
      final tLen = sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);

      Offset normal;
      if (tLen > 0.001) {
        normal = Offset(-tangent.dy / tLen, tangent.dx / tLen);
      } else {
        normal = (arrow.direction == ArrowDirection.up || arrow.direction == ArrowDirection.down)
            ? const Offset(1, 0)
            : const Offset(0, 1);
      }

      final double distanceAlongSnake = d - currentTailDist;
      final double wiggleScale = (1.0 - (d / totalTravel)).clamp(0.0, 1.0);
      // Traveling serpentine sine wave
      final double wiggle = sin((distanceAlongSnake * 2.2) - (arrow.animationProgress * pi * 7.0)) * (cellSize * 0.13) * wiggleScale;
      final wiggledPos = pos + normal * wiggle;

      if (firstPoint) {
        newPath.moveTo(wiggledPos.dx, wiggledPos.dy);
        firstPoint = false;
      } else {
        newPath.lineTo(wiggledPos.dx, wiggledPos.dy);
      }
    }

    // Ambient glow pass behind snake body
    final glowPaint = Paint()
      ..color = linePaint.color.withAlpha((linePaint.color.a * 0.32 * 255).round().clamp(0, 255))
      ..style = PaintingStyle.stroke
      ..strokeWidth = linePaint.strokeWidth * 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(newPath, glowPaint);
    canvas.drawPath(newPath, linePaint);

    // 3. Draw head at the front of the snake
    final headD = currentHeadDist.clamp(0.0, pathLength - 1.0);
    final headPosBase = _getPointAtDistance(points, headD);

    final dBehind = (headD - 0.1).clamp(0.0, pathLength - 1.0);
    final pBehind = _getPointAtDistance(points, dBehind);
    final tangent = headPosBase - pBehind;
    final tLen = sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);

    Offset headNormal;
    if (tLen > 0.001) {
      headNormal = Offset(-tangent.dy / tLen, tangent.dx / tLen);
    } else {
      headNormal = (arrow.direction == ArrowDirection.up || arrow.direction == ArrowDirection.down)
          ? const Offset(1, 0)
          : const Offset(0, 1);
    }

    final double headWiggle = sin(((currentHeadDist - currentTailDist) * 2.2) - (arrow.animationProgress * pi * 7.0)) *
        (cellSize * 0.13) *
        (1.0 - (headD / totalTravel)).clamp(0.0, 1.0);
    final headPos = headPosBase + headNormal * headWiggle;

    _drawSnakeHead(
      canvas: canvas,
      center: headPos,
      direction: arrow.direction,
      cellSize: cellSize,
      color: linePaint.color,
    );
  }

  Offset _getPointAtDistance(List<Offset> points, double d) {
    if (d <= 0) return points.first;
    if (d >= points.length - 1) return points.last;

    final int index = d.floor();
    final double t = d - index;
    return Offset.lerp(points[index], points[index + 1], t)!;
  }

  void _drawSnakeHead({
    required Canvas canvas,
    required Offset center,
    required ArrowDirection direction,
    required double cellSize,
    required Color color,
  }) {
    final headSize = cellSize * 0.42;
    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = center.dx;
    final cy = center.dy;

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

    // Subtle sleek snake eyes
    if (color.a > 0.15) {
      Offset eye1, eye2;
      switch (direction) {
        case ArrowDirection.up:
          eye1 = Offset(cx - headSize * 0.32, cy - headSize * 0.15);
          eye2 = Offset(cx + headSize * 0.32, cy - headSize * 0.15);
          break;
        case ArrowDirection.down:
          eye1 = Offset(cx - headSize * 0.32, cy + headSize * 0.15);
          eye2 = Offset(cx + headSize * 0.32, cy + headSize * 0.15);
          break;
        case ArrowDirection.left:
          eye1 = Offset(cx - headSize * 0.15, cy - headSize * 0.32);
          eye2 = Offset(cx - headSize * 0.15, cy + headSize * 0.32);
          break;
        case ArrowDirection.right:
          eye1 = Offset(cx + headSize * 0.15, cy - headSize * 0.32);
          eye2 = Offset(cx + headSize * 0.15, cy + headSize * 0.32);
          break;
      }

      final eyeR = max(1.8, cellSize * 0.045);
      final eyePaint = Paint()
        ..color = Colors.white.withAlpha((color.a * 0.9 * 255).round().clamp(0, 255))
        ..style = PaintingStyle.fill;
      final pupilPaint = Paint()
        ..color = Colors.black.withAlpha((color.a * 0.85 * 255).round().clamp(0, 255))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(eye1, eyeR, eyePaint);
      canvas.drawCircle(eye2, eyeR, eyePaint);
      canvas.drawCircle(eye1, eyeR * 0.5, pupilPaint);
      canvas.drawCircle(eye2, eyeR * 0.5, pupilPaint);
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
        ..color = AppColors.hintPulseGlow.withAlpha(((0.35 + 0.2 * sin(pulseValue * pi * 2)) * 255).toInt())
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
