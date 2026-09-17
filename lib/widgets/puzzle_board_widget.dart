import 'dart:math';
import 'package:flutter/material.dart';
import '../models/arrow.dart';
import '../game/puzzle_painter.dart';

class PuzzleBoardWidget extends StatefulWidget {
  final List<Arrow> arrows;
  final int rows;
  final int cols;
  final bool isDark;
  final bool showGrid;
  final String? hintArrowId;
  final String? blockedArrowId;
  final String? obstructingArrowId;
  final ValueChanged<String> onArrowTapped;

  const PuzzleBoardWidget({
    super.key,
    required this.arrows,
    required this.rows,
    required this.cols,
    required this.isDark,
    required this.showGrid,
    this.hintArrowId,
    this.blockedArrowId,
    this.obstructingArrowId,
    required this.onArrowTapped,
  });

  @override
  State<PuzzleBoardWidget> createState() => _PuzzleBoardWidgetState();
}

class _PuzzleBoardWidgetState extends State<PuzzleBoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details, Size size) {
    final cellWidth = size.width / widget.cols;
    final cellHeight = size.height / widget.rows;
    final cellSize = min(cellWidth, cellHeight);

    final offsetX = (size.width - (cellSize * widget.cols)) / 2.0;
    final offsetY = (size.height - (cellSize * widget.rows)) / 2.0;

    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;

    // Check if tap falls within board bounds
    if (tapX < offsetX ||
        tapX > offsetX + cellSize * widget.cols ||
        tapY < offsetY ||
        tapY > offsetY + cellSize * widget.rows) {
      return;
    }

    // Convert pixel to grid cell
    final c = ((tapX - offsetX) / cellSize).floor();
    final r = ((tapY - offsetY) / cellSize).floor();
    final tappedPoint = GridPoint(r, c);

    // 1. Check direct point match (head has highest priority, then body)
    for (final arrow in widget.arrows) {
      if (arrow.state == ArrowState.cleared) continue;
      if (arrow.head == tappedPoint) {
        widget.onArrowTapped(arrow.id);
        return;
      }
    }

    for (final arrow in widget.arrows) {
      if (arrow.state == ArrowState.cleared) continue;
      if (arrow.path.contains(tappedPoint)) {
        widget.onArrowTapped(arrow.id);
        return;
      }
    }

    // 2. Tolerance radius check if slightly off-center
    double minDistance = double.infinity;
    Arrow? closestArrow;

    for (final arrow in widget.arrows) {
      if (arrow.state == ArrowState.cleared) continue;
      for (final pt in arrow.path) {
        final cx = offsetX + (pt.col + 0.5) * cellSize;
        final cy = offsetY + (pt.row + 0.5) * cellSize;
        final dist = sqrt(pow(tapX - cx, 2) + pow(tapY - cy, 2));
        if (dist < minDistance && dist <= cellSize * 0.75) {
          minDistance = dist;
          closestArrow = arrow;
        }
      }
    }

    if (closestArrow != null) {
      widget.onArrowTapped(closestArrow.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardDim = min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: SizedBox(
            width: boardDim,
            height: boardDim,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _handleTap(details, Size(boardDim, boardDim)),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(boardDim, boardDim),
                    painter: PuzzlePainter(
                      arrows: widget.arrows,
                      rows: widget.rows,
                      cols: widget.cols,
                      isDark: widget.isDark,
                      showGrid: widget.showGrid,
                      hintArrowId: widget.hintArrowId,
                      blockedArrowId: widget.blockedArrowId,
                      obstructingArrowId: widget.obstructingArrowId,
                      pulseValue: _pulseController.value,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
