import '../models/tile.dart';

class MoveResult {
  final List<List<Tile?>> board;
  final int scoreGained;
  final bool didChange;

  /// 이동 후 폭탄이 폭발한 위치 목록 (row, col)
  final List<(int, int)> bombPositions;

  /// 이번 이동에서 발생한 머지 횟수 (스피드 모드 시간 보너스용)
  final int mergeCount;

  const MoveResult({
    required this.board,
    required this.scoreGained,
    required this.didChange,
    this.bombPositions = const [],
    this.mergeCount = 0,
  });
}
