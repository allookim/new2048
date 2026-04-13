import 'package:flutter/material.dart';
import '../../models/tile.dart';
import '../skill.dart';
import '../skill_result.dart';

class RemoveTileSkill extends Skill {
  @override
  String get id => 'remove_tile';
  @override
  String get name => 'Remove';
  @override
  String get description => 'Remove a tile from the board';
  @override
  IconData get icon => Icons.close;
  @override
  String? get svgAsset => 'assets/images/ic_item_remove.svg';
  @override
  int get maxUsesPerGame => 2;
  @override
  bool get requiresTarget => true;

  @override
  bool canUse(List<List<Tile?>> board, int score) {
    // Can use if there's at least one tile on the board
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
    if (board[targetRow][targetCol] == null) {
      return SkillResult(newBoard: board, wasApplied: false);
    }

    // Deep copy board
    final newBoard = List.generate(4, (r) {
      return List.generate(4, (c) => board[r][c]);
    });
    newBoard[targetRow][targetCol] = null;

    return SkillResult(newBoard: newBoard, wasApplied: true);
  }
}
