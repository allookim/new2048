import '../models/tile.dart';

class MoveResult {
  final List<List<Tile?>> board;
  final int scoreGained;
  final bool didChange;

  const MoveResult({
    required this.board,
    required this.scoreGained,
    required this.didChange,
  });
}
