import 'dart:math' show max;
import '../models/tile.dart';
import 'move_result.dart';

enum Direction { left, right, up, down }

/// 한 줄을 왼쪽으로 슬라이드·머지.
/// 특수 타일 규칙:
///   ice  : 이동은 되지만 머지 불가
///   wild : 어떤 값과도 머지 가능 (ice 제외)
///   golden: 머지 점수 ×2
///   bomb : 머지 후 주변 타일 폭발 (GameController에서 처리)
({List<Tile?> line, int score}) slideLineLeft(List<Tile?> line) {
  final tiles = line.whereType<Tile>().toList();
  int score = 0;
  int i = 0;

  while (i < tiles.length - 1) {
    final a = tiles[i];
    final b = tiles[i + 1];

    // 얼음 타일은 머지 불가
    if (a.tileType == TileType.ice || b.tileType == TileType.ice) {
      i++;
      continue;
    }

    final aWild = a.tileType == TileType.wild;
    final bWild = b.tileType == TileType.wild;
    final canMerge = aWild || bWild || a.value == b.value;

    if (canMerge) {
      // 합쳐진 값 계산
      int mergedValue;
      if (aWild && bWild) {
        mergedValue = max(a.value, b.value) * 2;
      } else if (aWild) {
        mergedValue = b.value * 2;
      } else if (bWild) {
        mergedValue = a.value * 2;
      } else {
        mergedValue = a.value * 2;
      }

      // 점수: 황금 타일이 하나라도 포함되면 ×2
      int mergeScore = mergedValue;
      if (a.tileType == TileType.golden || b.tileType == TileType.golden) {
        mergeScore *= 2;
      }

      // 결과 타일 타입: 폭탄 우선, 와일드·황금은 소멸
      TileType resultType = TileType.normal;
      if (a.tileType == TileType.bomb || b.tileType == TileType.bomb) {
        resultType = TileType.bomb;
      }

      tiles[i] = a.copyWith(
        value: mergedValue,
        isMerged: true,
        tileType: resultType,
      );
      score += mergeScore;
      tiles.removeAt(i + 1);
      i++; // 새로 머지된 타일은 건너뜀
    } else {
      i++;
    }
  }

  final result = List<Tile?>.filled(4, null);
  for (int j = 0; j < tiles.length; j++) {
    result[j] = tiles[j];
  }
  return (line: result, score: score);
}

/// 방향에 맞게 보드 전체에 이동·머지 적용.
MoveResult applyMove(List<List<Tile?>> board, Direction direction) {
  List<List<Tile?>> newBoard = List.generate(4, (r) {
    return List.generate(4, (c) {
      final tile = board[r][c];
      if (tile == null) return null;
      return tile.copyWith(isNew: false, isMerged: false);
    });
  });

  int totalScore = 0;
  bool changed = false;

  void processRow(int r, bool reversed) {
    final original = newBoard[r].map((t) => t?.value).toList();
    final line = reversed ? newBoard[r].reversed.toList() : newBoard[r];
    final result = slideLineLeft(line);
    newBoard[r] = reversed ? result.line.reversed.toList() : result.line;
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

  void processCol(int c, bool reversed) {
    final column = [newBoard[0][c], newBoard[1][c], newBoard[2][c], newBoard[3][c]];
    final original = column.map((t) => t?.value).toList();
    final line = reversed ? column.reversed.toList() : column;
    final result = slideLineLeft(line);
    final newCol = reversed ? result.line.reversed.toList() : result.line;
    for (int r = 0; r < 4; r++) {
      newBoard[r][c] = newCol[r]?.copyWith(row: r, col: c);
    }
    totalScore += result.score;
    if (!_listEquals(original, [for (int r = 0; r < 4; r++) newBoard[r][c]?.value])) {
      changed = true;
    }
  }

  switch (direction) {
    case Direction.left:
      for (int r = 0; r < 4; r++) processRow(r, false);
    case Direction.right:
      for (int r = 0; r < 4; r++) processRow(r, true);
    case Direction.up:
      for (int c = 0; c < 4; c++) processCol(c, false);
    case Direction.down:
      for (int c = 0; c < 4; c++) processCol(c, true);
  }

  // 폭탄이 머지된 위치 수집 (isMerged && bomb → 폭발 예정)
  final bombPositions = <(int, int)>[];
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      final tile = newBoard[r][c];
      if (tile != null && tile.isMerged && tile.tileType == TileType.bomb) {
        bombPositions.add((r, c));
      }
    }
  }

  return MoveResult(
    board: newBoard,
    scoreGained: totalScore,
    didChange: changed,
    bombPositions: bombPositions,
  );
}

bool isGameOver(List<List<Tile?>> board) {
  // 빈 칸이 있으면 게임 오버 아님
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      if (board[r][c] == null) return false;
    }
  }
  // 머지 가능한 인접 쌍이 있으면 게임 오버 아님
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      final tile = board[r][c]!;
      if (tile.tileType == TileType.ice) continue; // 얼음은 머지 불가

      for (final neighbor in _neighbors(board, r, c)) {
        if (neighbor.tileType == TileType.ice) continue;
        final canMerge = tile.value == neighbor.value ||
            tile.tileType == TileType.wild ||
            neighbor.tileType == TileType.wild;
        if (canMerge) return false;
      }
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

List<Tile> _neighbors(List<List<Tile?>> board, int r, int c) {
  final result = <Tile>[];
  if (c < 3 && board[r][c + 1] != null) result.add(board[r][c + 1]!);
  if (r < 3 && board[r + 1][c] != null) result.add(board[r + 1][c]!);
  return result;
}

bool _listEquals(List<int?> a, List<int?> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
