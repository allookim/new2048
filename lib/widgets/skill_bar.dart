import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';

class SkillBar extends StatelessWidget {
  const SkillBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;
    final btnColor = theme.buttonColor;
    final bgColor = theme.backgroundColor;

    return Consumer<GameController>(
      builder: (context, controller, _) {
        if (controller.gameMode != GameMode.item) {
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
                  final iconColor = isActive ? Colors.white : Colors.white;
                  return GestureDetector(
                    onTap: canUse ? () => controller.activateSkill(skill.id) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 42,
                      decoration: BoxDecoration(
                        color: isActive
                            ? btnColor
                            : canUse
                                ? btnColor.withValues(alpha: 0.85)
                                : btnColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (skill.svgAsset != null)
                            SvgPicture.asset(
                              skill.svgAsset!,
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            )
                          else
                            Icon(skill.icon, size: 18, color: iconColor),
                          const SizedBox(width: 6),
                          Text(
                            skill.name,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: iconColor,
                              letterSpacing: -0.51,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : bgColor.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$remaining',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
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
