import '../models/tile.dart';
import 'move_result.dart';

enum Direction { left, right, up, down }

/// Slides and merges a single row/line to the left.
/// Returns a new list of length 4 with merged tiles and accumulated score.
({List<Tile?> line, int score}) slideLineLeft(List<Tile?> line) {
  // Collect non-null tiles
  final tiles = line.whereType<Tile>().toList();
  int score = 0;
  int i = 0;

  // Merge adjacent equal tiles (left to right, no double-merge)
  while (i < tiles.length - 1) {
    if (tiles[i].value == tiles[i + 1].value) {
      tiles[i] = tiles[i].copyWith(
        value: tiles[i].value * 2,
        isMerged: true,
      );
      score += tiles[i].value;
      tiles.removeAt(i + 1);
      i++; // skip newly merged tile
    } else {
      i++;
    }
  }

  // Pad to length 4
  final result = List<Tile?>.filled(4, null);
  for (int j = 0; j < tiles.length; j++) {
    result[j] = tiles[j];
  }
  return (line: result, score: score);
}

/// Applies a move in the given direction to the board.
/// Returns a [MoveResult] with the new board state, score gained, and whether anything changed.
MoveResult applyMove(List<List<Tile?>> board, Direction direction) {
  // Deep copy board
  List<List<Tile?>> newBoard = List.generate(4, (r) {
    return List.generate(4, (c) {
      final tile = board[r][c];
      if (tile == null) return null;
      // Reset animation flags on every move
      return tile.copyWith(isNew: false, isMerged: false);
    });
  });

  int totalScore = 0;
  bool changed = false;

  if (direction == Direction.left) {
    for (int r = 0; r < 4; r++) {
      final original = newBoard[r].map((t) => t?.value).toList();
      final result = slideLineLeft(newBoard[r]);
      newBoard[r] = result.line;
      totalScore += result.score;
      // Update row/col positions
      for (int c = 0; c < 4; c++) {
        if (newBoard[r][c] != null) {
          newBoard[r][c] = newBoard[r][c]!.copyWith(row: r, col: c);
        }
      }
      if (!_listEquals(original, newBoard[r].map((t) => t?.value).toList())) {
        changed = true;
      }
    }
  } else if (direction == Direction.right) {
    for (int r = 0; r < 4; r++) {
      final original = newBoard[r].map((t) => t?.value).toList();
      final reversed = newBoard[r].reversed.toList();
      final result = slideLineLeft(reversed);
      newBoard[r] = result.line.reversed.toList();
      totalScore += result.score;
      for (int c = 0; c < 4; c++) {
        if (newBoard[r][c] != null) {
          newBoard[r][c] = newBoard[r][c]!.copyWith(row: r, col: c);
        }
      }
      if (!_listEquals(original, newBoard[r].map((t) => t?.value).toList())) {
        changed = true;
      }
    }
  } else if (direction == Direction.up) {
    for (int c = 0; c < 4; c++) {
      final column = [newBoard[0][c], newBoard[1][c], newBoard[2][c], newBoard[3][c]];
      final original = column.map((t) => t?.value).toList();
      final result = slideLineLeft(column);
      for (int r = 0; r < 4; r++) {
        newBoard[r][c] = result.line[r]?.copyWith(row: r, col: c);
      }
      totalScore += result.score;
      if (!_listEquals(original, [for (int r = 0; r < 4; r++) newBoard[r][c]?.value])) {
        changed = true;
      }
    }
  } else if (direction == Direction.down) {
    for (int c = 0; c < 4; c++) {
      final column = [newBoard[0][c], newBoard[1][c], newBoard[2][c], newBoard[3][c]];
      final original = column.map((t) => t?.value).toList();
      final reversed = column.reversed.toList();
      final result = slideLineLeft(reversed);
      final newCol = result.line.reversed.toList();
      for (int r = 0; r < 4; r++) {
        newBoard[r][c] = newCol[r]?.copyWith(row: r, col: c);
      }
      totalScore += result.score;
      if (!_listEquals(original, [for (int r = 0; r < 4; r++) newBoard[r][c]?.value])) {
        changed = true;
      }
    }
  }

  return MoveResult(board: newBoard, scoreGained: totalScore, didChange: changed);
}

bool isGameOver(List<List<Tile?>> board) {
  // Check for any empty cell
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      if (board[r][c] == null) return false;
    }
  }
  // Check for any adjacent equal tiles
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      final val = board[r][c]!.value;
      if (c < 3 && board[r][c + 1]?.value == val) return false;
      if (r < 3 && board[r + 1][c]?.value == val) return false;
    }
  }
  return true;
}

bool hasWon(List<List<Tile?>> board) {
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      if (board[r][c]?.value == 2048) return true;
    }
  }
  return false;
}

bool _listEquals(List<int?> a, List<int?> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
