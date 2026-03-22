import 'skill.dart';
import 'implementations/remove_tile_skill.dart';
import 'implementations/upgrade_tile_skill.dart';

/// 새 스킬 추가 시 이 파일만 수정한다.
/// GameController는 이 파일만 import하면 된다.
final List<Skill> defaultSkillSet = [
  RemoveTileSkill(),
  UpgradeTileSkill(),
];
