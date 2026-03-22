import '../models/tile.dart';
import '../models/game_state.dart';

class BoardSnapshot {
  final List<List<Tile?>> board;
  final int score;
  final GameStatus status;

  BoardSnapshot({
    required this.board,
    required this.score,
    required this.status,
  });

  /// Deep copy the board for safe snapshot storage.
  static BoardSnapshot capture(List<List<Tile?>> board, int score, GameStatus status) {
    final boardCopy = List.generate(4, (r) {
      return List.generate(4, (c) => board[r][c]);
    });
    return BoardSnapshot(board: boardCopy, score: score, status: status);
  }
}
