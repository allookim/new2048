import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_2048/game/board_logic.dart';
import 'package:flutter_2048/models/tile.dart';

List<Tile?> makeLine(List<int?> values) {
  return values.map((v) {
    if (v == null) return null;
    return Tile(value: v, row: 0, col: 0);
  }).toList();
}

List<int?> lineValues(List<Tile?> line) => line.map((t) => t?.value).toList();

void main() {
  group('slideLineLeft', () {
    test('slides tiles left', () {
      final line = makeLine([null, 2, null, 4]);
      final result = slideLineLeft(line);
      expect(lineValues(result.line), [2, 4, null, null]);
      expect(result.score, 0);
    });

    test('merges equal tiles', () {
      final line = makeLine([2, 2, null, null]);
      final result = slideLineLeft(line);
      expect(lineValues(result.line), [4, null, null, null]);
      expect(result.score, 4);
    });

    test('no double merge [2,2,2,2] -> [4,4]', () {
      final line = makeLine([2, 2, 2, 2]);
      final result = slideLineLeft(line);
      expect(lineValues(result.line), [4, 4, null, null]);
      expect(result.score, 8);
    });

    test('merges leftmost pair first', () {
      final line = makeLine([2, 2, 4, null]);
      final result = slideLineLeft(line);
      expect(lineValues(result.line), [4, 4, null, null]);
      expect(result.score, 4);
    });

    test('no change when no moves possible', () {
      final line = makeLine([2, 4, 8, 16]);
      final result = slideLineLeft(line);
      expect(lineValues(result.line), [2, 4, 8, 16]);
      expect(result.score, 0);
    });
  });

  group('applyMove', () {
    List<List<Tile?>> makeBoard(List<List<int?>> values) {
      return List.generate(4, (r) {
        return List.generate(4, (c) {
          final v = values[r][c];
          return v == null ? null : Tile(value: v, row: r, col: c);
        });
      });
    }

    List<List<int?>> boardValues(List<List<Tile?>> board) {
      return board.map((row) => row.map((t) => t?.value).toList()).toList();
    }

    test('move left merges correctly', () {
      final board = makeBoard([
        [null, 2, 2, null],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);
      final result = applyMove(board, Direction.left);
      expect(result.didChange, true);
      expect(boardValues(result.board)[0][0], 4);
      expect(result.scoreGained, 4);
    });

    test('returns didChange=false when no movement', () {
      final board = makeBoard([
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2, 4],
        [8, 16, 32, 64],
      ]);
      final result = applyMove(board, Direction.left);
      expect(result.didChange, false);
    });
  });

  group('isGameOver', () {
    test('returns false when empty cells exist', () {
      final board = List.generate(4, (r) => List.generate(4, (c) {
        return r == 0 && c == 0 ? null : Tile(value: (r * 4 + c + 1) * 2, row: r, col: c);
      }));
      expect(isGameOver(board), false);
    });

    test('returns false when adjacent equal tiles', () {
      final board = List.generate(4, (r) => List.generate(4, (c) {
        return Tile(value: (r * 4 + c + 1) * 2, row: r, col: c);
      }));
      // Make two adjacent tiles equal
      board[0][0] = Tile(value: 2, row: 0, col: 0);
      board[0][1] = Tile(value: 2, row: 0, col: 1);
      expect(isGameOver(board), false);
    });
  });
}
