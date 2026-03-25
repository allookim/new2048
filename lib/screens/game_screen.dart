import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/board_logic.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';
import '../widgets/game_board.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/skill_bar.dart';
import '../widgets/time_up_overlay.dart';
import '../widgets/timer_bar.dart';
import '../widgets/win_overlay.dart';
import 'settings_screen.dart';
import 'theme_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<Offset> _drawerSlide;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _drawerSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _drawerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _drawerController.forward();
  }

  void _closeDrawer() {
    _drawerController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  _TitleRow(onMenu: _openDrawer),
                  const SizedBox(height: 30),
                  const _ScoreRow(),
                  const SizedBox(height: 8),
                  const TimerBar(),
                  const SizedBox(height: 6),
                  const _ComboBadgeRow(),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = constraints.maxWidth <
                                  constraints.maxHeight
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
                                TimeUpOverlay(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // SkillBar: only visible in item mode
                  Consumer<GameController>(
                    builder: (_, gc, __) => gc.gameMode == GameMode.item
                        ? const SkillBar()
                        : const SizedBox.shrink(),
                  ),
                  const _BottomSection(),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Full-screen top-sliding drawer ────────────────
            SlideTransition(
              position: _drawerSlide,
              child: _FullScreenDrawer(onClose: _closeDrawer),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Title row ────────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  final VoidCallback onMenu;
  const _TitleRow({required this.onMenu});

  @override
  Widget build(BuildContext context) {
    final gc = context.read<GameController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hamburger
        GestureDetector(
          onTap: onMenu,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HamLine(),
                const SizedBox(height: 5),
                _HamLine(),
                const SizedBox(height: 5),
                _HamLine(),
              ],
            ),
          ),
        ),
        // Title
        const Text(
          '2048',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        // New game icon
        GestureDetector(
          onTap: gc.newGame,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.refresh_rounded, color: Colors.white, size: 38),
          ),
        ),
      ],
    );
  }
}

class _HamLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 3.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── Score row ────────────────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  const _ScoreRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) {
        final isSpeed = gc.gameMode == GameMode.speed;
        final bestLabel = isSpeed ? 'BEST ⚡' : 'BEST';
        final bestValue = isSpeed ? gc.bestSpeedScore : gc.bestScore;
        return Row(
          children: [
            Expanded(child: _ScoreBox(label: 'SCORE', value: gc.score)),
            const SizedBox(width: 12),
            Expanded(child: _ScoreBox(label: bestLabel, value: bestValue)),
          ],
        );
      },
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4E3880),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0x8CFFFFFF),
              letterSpacing: 2,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              '$value',
              key: ValueKey(value),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom section ───────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  const _BottomSection();

  @override
  Widget build(BuildContext context) {
    final gc = context.read<GameController>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ArrowKeys(
          onUp: () => gc.move(Direction.up),
          onDown: () => gc.move(Direction.down),
          onLeft: () => gc.move(Direction.left),
          onRight: () => gc.move(Direction.right),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Combine the identical numbers and try to reach 2048!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Color(0xD9FFFFFF),
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowKeys extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _ArrowKeys({
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowBtn(icon: Icons.keyboard_arrow_up_rounded, onTap: onUp),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowBtn(icon: Icons.keyboard_arrow_left_rounded, onTap: onLeft),
            const SizedBox(width: 4),
            _ArrowBtn(icon: Icons.keyboard_arrow_down_rounded, onTap: onDown),
            const SizedBox(width: 4),
            _ArrowBtn(icon: Icons.keyboard_arrow_right_rounded, onTap: onRight),
          ],
        ),
      ],
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

// ── Full-screen drawer ───────────────────────────────────────

class _FullScreenDrawer extends StatelessWidget {
  final VoidCallback onClose;
  const _FullScreenDrawer({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final gc = context.watch<GameController>();
    final currentMode = gc.gameMode;

    return Material(
      color: const Color(0xFF3A2870),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Row(
                children: [
                  const SizedBox(width: 48), // balance spacer
                  const Expanded(
                    child: Text(
                      '2048',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(0x99FFFFFF), size: 22),
                      onPressed: onClose,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Game Mode
                      const _SectionLabel('GAME MODE'),
                      _MenuItem(
                        label: 'Normal',
                        isActive: currentMode == GameMode.normal,
                        onTap: () {
                          gc.startGame(GameMode.normal);
                          onClose();
                        },
                      ),
                      _MenuItem(
                        label: 'Normal Test',
                        isActive: currentMode == GameMode.normalTest,
                        onTap: () {
                          gc.startGame(GameMode.normalTest);
                          onClose();
                        },
                      ),
                      _MenuItem(
                        label: 'Item Mode',
                        isActive: currentMode == GameMode.item,
                        onTap: () {
                          gc.startGame(GameMode.item);
                          onClose();
                        },
                      ),
                      _MenuItem(
                        label: 'Speed Mode',
                        isActive: currentMode == GameMode.speed,
                        onTap: () {
                          gc.startGame(GameMode.speed);
                          onClose();
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.white12),
                      const SizedBox(height: 12),
                      // Settings
                      const _SectionLabel('SETTINGS'),
                      _MenuItem(
                        label: 'Theme',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ThemeScreen()),
                          );
                        },
                      ),
                      _MenuItem(
                        label: 'Settings',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Combo badge (speed mode, above board) ────────────────────

class _ComboBadgeRow extends StatelessWidget {
  const _ComboBadgeRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) {
        if (gc.gameMode != GameMode.speed || gc.combo < 2) {
          return const SizedBox(height: 42);
        }
        return SizedBox(
          height: 42,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(gc.combo),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6DDDD0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${gc.combo} COMBO',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E1460),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0x331E1460),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '×${gc.comboMultiplier.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1460),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0x59FFFFFF),
          letterSpacing: 3,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0x266DDDD0)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
