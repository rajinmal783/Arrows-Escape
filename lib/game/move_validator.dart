import '../models/arrow.dart';

class MoveValidator {
  /// Checks whether [arrow] has an unobstructed exit path to the board edge.
  static bool canArrowEscape({
    required Arrow arrow,
    required List<Arrow> activeArrows,
    required int rows,
    required int cols,
  }) {
    // Optimization: Build occupation map once if needed for many checks, 
    // but here we just check for one arrow.
    final head = arrow.head;
    final otherPaths = activeArrows
        .where((a) => a.id != arrow.id && a.state != ArrowState.cleared)
        .map((a) => a.path)
        .expand((p) => p)
        .toSet();

    return _checkPath(head, arrow.direction, rows, cols, otherPaths);
  }

  static bool _checkPath(GridPoint head, ArrowDirection direction, int rows, int cols, Set<GridPoint> occupied) {
    switch (direction) {
      case ArrowDirection.up:
        for (int r = head.row - 1; r >= 0; r--) {
          if (occupied.contains(GridPoint(r, head.col))) {
            return false;
          }
        }
        return true;
      case ArrowDirection.down:
        for (int r = head.row + 1; r < rows; r++) {
          if (occupied.contains(GridPoint(r, head.col))) {
            return false;
          }
        }
        return true;
      case ArrowDirection.left:
        for (int c = head.col - 1; c >= 0; c--) {
          if (occupied.contains(GridPoint(head.row, c))) {
            return false;
          }
        }
        return true;
      case ArrowDirection.right:
        for (int c = head.col + 1; c < cols; c++) {
          if (occupied.contains(GridPoint(head.row, c))) {
            return false;
          }
        }
        return true;
    }
  }

  /// Finds the first obstructing arrow along the exit path.
  static Arrow? findObstruction({
    required Arrow arrow,
    required List<Arrow> activeArrows,
    required int rows,
    required int cols,
  }) {
    final head = arrow.head;
    final others = activeArrows.where((a) => a.id != arrow.id && a.state != ArrowState.cleared).toList();

    switch (arrow.direction) {
      case ArrowDirection.up:
        for (int r = head.row - 1; r >= 0; r--) {
          final pt = GridPoint(r, head.col);
          for (final o in others) {
            if (o.path.contains(pt)) {
              return o;
            }
          }
        }
        break;
      case ArrowDirection.down:
        for (int r = head.row + 1; r < rows; r++) {
          final pt = GridPoint(r, head.col);
          for (final o in others) {
            if (o.path.contains(pt)) {
              return o;
            }
          }
        }
        break;
      case ArrowDirection.left:
        for (int c = head.col - 1; c >= 0; c--) {
          final pt = GridPoint(head.row, c);
          for (final o in others) {
            if (o.path.contains(pt)) {
              return o;
            }
          }
        }
        break;
      case ArrowDirection.right:
        for (int c = head.col + 1; c < cols; c++) {
          final pt = GridPoint(head.row, c);
          for (final o in others) {
            if (o.path.contains(pt)) {
              return o;
            }
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
    final occupied = activeArrows
        .where((a) => a.state != ArrowState.cleared)
        .map((a) => a.path)
        .expand((p) => p)
        .toSet();

    return activeArrows.where((a) {
      if (a.state == ArrowState.cleared) return false;
      // An arrow is unblocked if its path ahead is not occupied by ANY OTHER arrow.
      // Since 'occupied' includes 'a.path', we just need to be careful.
      // But 'a.path' is behind its head (mostly), and we check cells starting from head+1.
      // One exception: an arrow can't block itself in its own exit direction.
      
      switch (a.direction) {
        case ArrowDirection.up:
          for (int r = a.head.row - 1; r >= 0; r--) {
            final pt = GridPoint(r, a.head.col);
            if (occupied.contains(pt) && !a.path.contains(pt)) {
              return false;
            }
          }
          return true;
        case ArrowDirection.down:
          for (int r = a.head.row + 1; r < rows; r++) {
            final pt = GridPoint(r, a.head.col);
            if (occupied.contains(pt) && !a.path.contains(pt)) {
              return false;
            }
          }
          return true;
        case ArrowDirection.left:
          for (int c = a.head.col - 1; c >= 0; c--) {
            final pt = GridPoint(a.head.row, c);
            if (occupied.contains(pt) && !a.path.contains(pt)) {
              return false;
            }
          }
          return true;
        case ArrowDirection.right:
          for (int c = a.head.col + 1; c < cols; c++) {
            final pt = GridPoint(a.head.row, c);
            if (occupied.contains(pt) && !a.path.contains(pt)) {
              return false;
            }
          }
          return true;
      }
    }).toList();
  }
}
