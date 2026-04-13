import 'package:flutter/material.dart';
import '../../models/tile.dart';
import '../skill.dart';
import '../skill_result.dart';

class UpgradeTileSkill extends Skill {
  @override
  String get id => 'upgrade_tile';
  @override
  String get name => 'Upgrade';
  @override
  String get description => 'Double a tile\'s value';
  @override
  IconData get icon => Icons.arrow_upward;
  @override
  String? get svgAsset => 'assets/images/ic_item_upgrade.svg';
  @override
  int get maxUsesPerGame => 1;
  @override
  bool get requiresTarget => true;

  @override
  bool canUse(List<List<Tile?>> board, int score) {
    for (final row in board) {
      for (final tile in row) {
        if (tile != null) return true;
      }
    }
    return false;
  }

  @override
  SkillResult apply(List<List<Tile?>> board, int score, {int? targetRow, int? targetCol}) {
    if (targetRow == null || targetCol == null) {
      return SkillResult(newBoard: board, wasApplied: false);
    }
    final target = board[targetRow][targetCol];
    if (target == null) {
      return SkillResult(newBoard: board, wasApplied: false);
    }

    // Deep copy board
    final newBoard = List.generate(4, (r) {
      return List.generate(4, (c) => board[r][c]);
    });
    newBoard[targetRow][targetCol] = target.copyWith(
      value: target.value * 2,
      isMerged: true,
    );

    return SkillResult(
      newBoard: newBoard,
      scoreChange: target.value * 2,
      wasApplied: true,
    );
  }
}
