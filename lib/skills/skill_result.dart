import '../models/tile.dart';

class SkillResult {
  final List<List<Tile?>> newBoard;
  final int scoreChange;
  final bool wasApplied;

  const SkillResult({
    required this.newBoard,
    this.scoreChange = 0,
    required this.wasApplied,
  });
}
