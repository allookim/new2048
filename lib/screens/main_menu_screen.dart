import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../widgets/menu_button.dart';
import 'game_screen.dart';
import 'theme_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '2048',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: theme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '타일을 합쳐서 2048을 만들어보세요!',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textDark.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 48),
              MenuButton(
                label: 'Play',
                icon: Icons.play_arrow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                },
              ),
              MenuButton(
                label: 'Themes',
                icon: Icons.palette,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ThemeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
