import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_state.dart';

class WinOverlay extends StatelessWidget {
  const WinOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Consumer<GameController>(
      builder: (context, controller, _) {
        final visible = controller.status == GameStatus.won;
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !visible,
            child: Container(
              decoration: BoxDecoration(
                color: theme.winOverlayColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(theme.boardRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You Win!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: theme.overlayTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2048 달성!',
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.overlayTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: controller.continueAfterWin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.textDark,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(theme.tileRadius),
                            ),
                          ),
                          child: const Text(
                            'Keep Going',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: controller.newGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.buttonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(theme.tileRadius),
                            ),
                          ),
                          child: const Text(
                            'New Game',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
