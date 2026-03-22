import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/score_panel.dart';
import '../widgets/skill_bar.dart';
import '../widgets/win_overlay.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textDark),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const ScorePanel(),
              const SizedBox(height: 12),
              Text(
                '현동이가 타일을 밀어서 합치세요. 2048을 만들면 승리! 아자',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;
                      return SizedBox(
                        width: size,
                        height: size,
                        child: const Stack(
                          children: [
                            GameBoard(),
                            GameOverOverlay(),
                            WinOverlay(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SkillBar(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
