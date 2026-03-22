import 'skill.dart';

class SkillInventory {
  final List<Skill> _skills;
  final Map<String, int> _remainingUses;

  SkillInventory(this._skills)
      : _remainingUses = {
          for (final s in _skills) s.id: s.maxUsesPerGame,
        };

  List<Skill> get skills => List.unmodifiable(_skills);

  bool canUse(String skillId) => (_remainingUses[skillId] ?? 0) > 0;

  int remaining(String skillId) => _remainingUses[skillId] ?? 0;

  void use(String skillId) {
    final current = _remainingUses[skillId];
    if (current != null && current > 0) {
      _remainingUses[skillId] = current - 1;
    }
  }

  Skill? getSkill(String skillId) {
    try {
      return _skills.firstWhere((s) => s.id == skillId);
    } catch (_) {
      return null;
    }
  }
}
