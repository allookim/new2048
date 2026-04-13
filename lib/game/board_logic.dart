import 'dart:math' show max;
import '../models/tile.dart';
import 'move_result.dart';

enum Direction { left, right, up, down }

/// 한 줄을 왼쪽으로 슬라이드·머지.
/// 특수 타일 규칙:
///   ice  : 이동은 되지만 머지 불가
///   lock : 위치 고정(벽 역할) + 머지 불가
///   wild : 어떤 값과도 머지 가능 (ice/lock 제외)
///   golden: 머지 점수 ×2
///   bomb : 머지 후 주변 타일 폭발 (GameController에서 처리)
({List<Tile?> line, int score, int mergeCount}) slideLineLeft(List<Tile?> line) {
  final result = List<Tile?>.filled(line.length, null);
  int totalScore = 0;
  int totalMergeCount = 0;

  // Lock 타일 위치를 벽으로 고정, 세그먼트 경계 계산
  final walls = [-1];
  for (int i = 0; i < line.length; i++) {
    if (line[i]?.tileType == TileType.lock) {
      result[i] = line[i]; // 제자리 고정
      walls.add(i);
    }
  }
  walls.add(line.length);

  // 각 세그먼트를 독립적으로 슬라이드·머지
  for (int w = 0; w < walls.length - 1; w++) {
    final segStart = walls[w] + 1;
    final segEnd = walls[w + 1];
    if (segStart >= segEnd) continue;

    final tiles = <Tile>[];
    for (int i = segStart; i < segEnd; i++) {
      if (line[i] != null && line[i]!.tileType != TileType.lock) {
        tiles.add(line[i]!);
      }
    }
    if (tiles.isEmpty) continue;

    int i = 0;
    while (i < tiles.length - 1) {
      final a = tiles[i];
      final b = tiles[i + 1];

      // 얼음·화살표 타일은 머지 불가
      if (a.tileType == TileType.ice || b.tileType == TileType.ice ||
          _isArrowType(a.tileType) || _isArrowType(b.tileType)) {
        i++;
        continue;
      }

      final aWild = a.tileType == TileType.wild;
      final bWild = b.tileType == TileType.wild;
      final canMerge = aWild || bWild || a.value == b.value;

      if (canMerge) {
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

        int mergeScore = mergedValue;
        if (a.tileType == TileType.golden || b.tileType == TileType.golden) {
          mergeScore *= 2;
        }

        TileType resultType = TileType.normal;
        if (a.tileType == TileType.bomb || b.tileType == TileType.bomb) {
          resultType = TileType.bomb;
        }

        tiles[i] = a.copyWith(
          value: mergedValue,
          isMerged: true,
          tileType: resultType,
        );
        totalScore += mergeScore;
        totalMergeCount++;
        tiles.removeAt(i + 1);
        i++;
      } else {
        i++;
      }
    }

    for (int j = 0; j < tiles.length; j++) {
      result[segStart + j] = tiles[j];
    }
  }

  return (line: result, score: totalScore, mergeCount: totalMergeCount);
}

bool _isArrowType(TileType t) =>
    t == TileType.arrowLeft || t == TileType.arrowRight ||
    t == TileType.arrowUp   || t == TileType.arrowDown;

/// 화살표 타일 활성화: 스와이프 방향과 일치하는 화살표를 찾아
/// 화살표 기준 끝까지 타일을 최댓값 하나로 수렴시킨다.
/// 변경이 발생하면 true 반환.
bool _processArrows(List<List<Tile?>> board, Direction direction) {
  bool changed = false;

  void activateLine(List<Tile?> line, TileType arrowType, bool towardEnd) {
    for (int i = 0; i < line.length; i++) {
      if (line[i]?.tileType != arrowType) continue;

      final start = towardEnd ? i : 0;
      final end   = towardEnd ? line.length - 1 : i;

      int maxVal = 0;
      for (int j = start; j <= end; j++) {
        final v = line[j]?.value ?? 0;
        if (v > maxVal) maxVal = v;
      }
      if (maxVal == 0) continue;

      // 화살표 위치에 최댓값 타일 배치, 나머지 null
      line[i] = line[i]!.copyWith(
        value: maxVal,
        tileType: TileType.normal,
        isMerged: true,
      );
      for (int j = start; j <= end; j++) {
        if (j != i) line[j] = null;
      }
      changed = true;
      break;
    }
  }

  switch (direction) {
    case Direction.left:
      for (int r = 0; r < 4; r++) {
        activateLine(board[r], TileType.arrowLeft, false);
      }
    case Direction.right:
      for (int r = 0; r < 4; r++) {
        activateLine(board[r], TileType.arrowRight, true);
      }
    case Direction.up:
      for (int c = 0; c < 4; c++) {
        final col = [board[0][c], board[1][c], board[2][c], board[3][c]];
        activateLine(col, TileType.arrowUp, false);
        for (int r = 0; r < 4; r++) board[r][c] = col[r];
      }
    case Direction.down:
      for (int c = 0; c < 4; c++) {
        final col = [board[0][c], board[1][c], board[2][c], board[3][c]];
        activateLine(col, TileType.arrowDown, true);
        for (int r = 0; r < 4; r++) board[r][c] = col[r];
      }
  }
  return changed;
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
  int totalMergeCount = 0;
  // 화살표 활성화가 일어나면 이미 changed
  bool changed = _processArrows(newBoard, direction);

  void processRow(int r, bool reversed) {
    final original = newBoard[r].map((t) => t?.value).toList();
    final line = reversed ? newBoard[r].reversed.toList() : newBoard[r];
    final result = slideLineLeft(line);
    newBoard[r] = reversed ? result.line.reversed.toList() : result.line;
    totalScore += result.score;
    totalMergeCount += result.mergeCount;
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
    totalMergeCount += result.mergeCount;
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
    mergeCount: totalMergeCount,
  );
}

bool isGameOver(List<List<Tile?>> board) {
  // 빈 칸이 있으면 게임 오버 아님
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      if (board[r][c] == null) return false;
    }
  }
  // 화살표 타일이 있으면 활성화로 판 변경 가능
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      if (_isArrowType(board[r][c]!.tileType)) return false;
    }
  }

  // 머지 가능한 인접 쌍이 있으면 게임 오버 아님
  for (int r = 0; r < 4; r++) {
    for (int c = 0; c < 4; c++) {
      final tile = board[r][c]!;
      if (tile.tileType == TileType.ice) continue;
      if (tile.tileType == TileType.lock) continue;

      for (final neighbor in _neighbors(board, r, c)) {
        if (neighbor.tileType == TileType.ice) continue;
        if (neighbor.tileType == TileType.lock) continue;
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
