import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_state.dart';
import '../models/game_mode.dart';

class TimeUpOverlay extends StatelessWidget {
  const TimeUpOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Consumer<GameController>(
      builder: (context, controller, _) {
        final visible = controller.gameMode == GameMode.speed &&
            controller.status == GameStatus.timeUp;

        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !visible,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(theme.boardRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '시간 초과!',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 점수
                    _StatRow(
                      label: '최종 점수',
                      value: '${controller.score}',
                      theme: theme,
                      highlight: true,
                    ),
                    const SizedBox(height: 4),
                    _StatRow(
                      label: '최고 기록',
                      value: '${controller.bestSpeedScore}',
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    _StatRow(
                      label: '최대 콤보',
                      value: '${controller.maxCombo}x',
                      theme: theme,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.newGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(theme.tileRadius),
                        ),
                      ),
                      child: const Text(
                        '다시 시작',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final dynamic theme;
  final bool highlight;

  const _StatRow({
    required this.label,
    required this.value,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label  ',
          style: TextStyle(
            fontSize: 13,
            color: theme.textDark.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: theme.textDark,
          ),
        ),
      ],
    );
  }
}
