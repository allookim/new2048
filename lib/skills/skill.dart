import 'package:flutter/material.dart';
import '../models/tile.dart';
import 'skill_result.dart';

abstract class Skill {
  String get id;
  String get name;
  String get description;
  IconData get icon;
  String? get svgAsset => null;
  int get maxUsesPerGame;

  /// Whether this skill requires the player to tap a specific tile.
  bool get requiresTarget;

  /// Returns true if the skill can be used given current board state.
  bool canUse(List<List<Tile?>> board, int score);

  /// Applies the skill effect. Returns a SkillResult.
  /// [targetRow] and [targetCol] are provided for targeted skills.
  SkillResult apply(List<List<Tile?>> board, int score, {int? targetRow, int? targetCol});
}
