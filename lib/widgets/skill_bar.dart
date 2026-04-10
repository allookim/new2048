import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';

class SkillBar extends StatelessWidget {
  const SkillBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Consumer<GameController>(
      builder: (context, controller, _) {
        // 노멀 모드에서는 스킬바 숨김
        if (controller.gameMode == GameMode.normal) {
          return const SizedBox.shrink();
        }

        final inventory = controller.skillInventory;
        final skills = inventory.skills;
        return Row(
          children: [
            for (int i = 0; i < skills.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(
                child: Builder(builder: (context) {
                  final skill = skills[i];
                  final remaining = inventory.remaining(skill.id);
                  final isActive = controller.activeSkillId == skill.id;
                  final canUse = remaining > 0 && skill.canUse(controller.board, controller.score);
                  return GestureDetector(
                    onTap: canUse ? () => controller.activateSkill(skill.id) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 42,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF006494)
                            : canUse
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            skill.icon,
                            size: 18,
                            color: isActive ? Colors.white : const Color(0xFF006494),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            skill.name,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : const Color(0xFF006494),
                              letterSpacing: -0.51,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : const Color(0xFF006494),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '$remaining',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isActive ? Colors.white : Colors.white,
                                letterSpacing: -0.42,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}
