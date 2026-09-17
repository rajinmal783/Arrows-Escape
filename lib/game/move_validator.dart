import '../models/arrow.dart';

class MoveValidator {
  /// Checks whether [arrow] has an unobstructed exit path to the board edge.
  static bool canArrowEscape({
    required Arrow arrow,
    required List<Arrow> activeArrows,
    required int rows,
    required int cols,
  }) {
    final head = arrow.head;

    // Fast lookup set of occupied cells by other active arrows
    final occupied = <GridPoint>{};
    for (final a in activeArrows) {
      if (a.id != arrow.id && a.state != ArrowState.cleared) {
        occupied.addAll(a.path);
      }
    }

    switch (arrow.direction) {
      case ArrowDirection.up:
        for (int r = head.row - 1; r >= 0; r--) {
          if (occupied.contains(GridPoint(r, head.col))) return false;
        }
        return true;

      case ArrowDirection.down:
        for (int r = head.row + 1; r < rows; r++) {
          if (occupied.contains(GridPoint(r, head.col))) return false;
        }
        return true;

      case ArrowDirection.left:
        for (int c = head.col - 1; c >= 0; c--) {
          if (occupied.contains(GridPoint(head.row, c))) return false;
        }
        return true;

      case ArrowDirection.right:
        for (int c = head.col + 1; c < cols; c++) {
          if (occupied.contains(GridPoint(head.row, c))) return false;
        }
        return true;
    }
  }

  /// Finds the first obstructing arrow along the exit path (used for red shake/highlight).
  static Arrow? findObstruction({
    required Arrow arrow,
    required List<Arrow> activeArrows,
    required int rows,
    required int cols,
  }) {
    final head = arrow.head;
    final otherArrows = activeArrows
        .where((a) => a.id != arrow.id && a.state != ArrowState.cleared)
        .toList();

    switch (arrow.direction) {
      case ArrowDirection.up:
        for (int r = head.row - 1; r >= 0; r--) {
          final pt = GridPoint(r, head.col);
          for (final other in otherArrows) {
            if (other.path.contains(pt)) return other;
          }
        }
        break;

      case ArrowDirection.down:
        for (int r = head.row + 1; r < rows; r++) {
          final pt = GridPoint(r, head.col);
          for (final other in otherArrows) {
            if (other.path.contains(pt)) return other;
          }
        }
        break;

      case ArrowDirection.left:
        for (int c = head.col - 1; c >= 0; c--) {
          final pt = GridPoint(head.row, c);
          for (final other in otherArrows) {
            if (other.path.contains(pt)) return other;
          }
        }
        break;

      case ArrowDirection.right:
        for (int c = head.col + 1; c < cols; c++) {
          final pt = GridPoint(head.row, c);
          for (final other in otherArrows) {
            if (other.path.contains(pt)) return other;
          }
        }
        break;
    }
    return null;
  }

  /// Returns all currently available (unblocked) arrows.
  static List<Arrow> getAvailableArrows({
    required List<Arrow> activeArrows,
    required int rows,
    required int cols,
  }) {
    return activeArrows
        .where((a) =>
            a.state != ArrowState.cleared &&
            canArrowEscape(
              arrow: a,
              activeArrows: activeArrows,
              rows: rows,
              cols: cols,
            ))
        .toList();
  }
}
