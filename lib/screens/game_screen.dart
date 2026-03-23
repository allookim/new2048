import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';
import '../widgets/game_board.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/score_panel.dart';
import '../widgets/skill_bar.dart';
import '../widgets/win_overlay.dart';
import 'settings_screen.dart';
import 'theme_screen.dart';

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
        // 햄버거 메뉴
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: theme.textDark),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          '2048',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: theme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const _GameDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const ScorePanel(),
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

class _GameDrawer extends StatelessWidget {
  const _GameDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;
    final gameController = context.read<GameController>();

    return Drawer(
      backgroundColor: theme.boardColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 드로어 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Text(
                '2048',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: theme.textDark,
                ),
              ),
            ),
            Divider(
              color: theme.textDark.withValues(alpha: 0.12),
              height: 1,
            ),
            const SizedBox(height: 8),

            // 노멀 게임
            _DrawerItem(
              icon: Icons.grid_4x4_rounded,
              label: '노멀 게임',
              theme: theme,
              onTap: () {
                gameController.startGame(GameMode.normal);
                Navigator.pop(context);
              },
            ),

            // 아이템 게임
            _DrawerItem(
              icon: Icons.auto_awesome,
              label: '아이템 게임',
              theme: theme,
              badge: '특수 타일',
              onTap: () {
                gameController.startGame(GameMode.item);
                Navigator.pop(context);
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Divider(color: theme.textDark.withValues(alpha: 0.12), height: 1),
            ),

            // 테마 선택
            _DrawerItem(
              icon: Icons.palette_outlined,
              label: '테마 선택',
              theme: theme,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThemeScreen()),
                );
              },
            ),

            // 설정
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: '설정',
              theme: theme,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic theme;
  final VoidCallback onTap;
  final String? badge;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.buttonColor, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.textDark,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
