import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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
  bool _useNewLayout = false;

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

  Widget _buildOriginalLayout() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 18),
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
                          TimeUpOverlay(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Consumer<GameController>(
              builder: (_, gc, __) => gc.gameMode == GameMode.item
                  ? const SkillBar()
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaLayout() {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return SafeArea(
      bottom: isAndroid,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _TitleRow(onMenu: _openDrawer, isPauseIcon: true),
            const SizedBox(height: 12),
            const _FigmaScore(),
            const TimerBar(),
            const _ComboBadgeRow(),
            const SizedBox(height: 8),
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
                          TimeUpOverlay(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            const SkillBar(),
            if (isAndroid) const _HomeIndicator(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────
          Positioned.fill(
            child: Consumer2<GameController, ThemeController>(
              builder: (_, gc, tc, __) {
                if (_useNewLayout && tc.theme.backgroundVideoAsset != null) {
                  return _VideoBackground(asset: tc.theme.backgroundVideoAsset!);
                }
                if (_useNewLayout && tc.theme.backgroundAsset != null) {
                  return Image.asset(
                    tc.theme.backgroundAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: tc.theme.backgroundColor),
                  );
                }
                final bg = gc.gameMode == GameMode.normalTest
                    ? 'assets/images/bg_normal_test.png'
                    : 'assets/images/bg_normal.png';
                return Image.asset(bg, fit: BoxFit.cover);
              },
            ),
          ),
          // ── Main content ──────────────────────────────────
          _useNewLayout ? _buildFigmaLayout() : _buildOriginalLayout(),

            // ── Full-screen top-sliding drawer ────────────────
            SlideTransition(
              position: _drawerSlide,
              child: _FullScreenDrawer(
                onClose: _closeDrawer,
                useNewLayout: _useNewLayout,
                onSelectNewLayout: (mode) {
                  setState(() => _useNewLayout = true);
                  context.read<GameController>().startGame(mode);
                  _closeDrawer();
                },
              ),
            ),
          ],
        ),
    );
  }
}

// ── Title row ────────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  final VoidCallback onMenu;
  final bool isPauseIcon;
  const _TitleRow({required this.onMenu, this.isPauseIcon = false});

  @override
  Widget build(BuildContext context) {
    final gc = context.read<GameController>();
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hamburger — left aligned, 44x44 tap area
          GestureDetector(
            onTap: onMenu,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
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
          ),
          // Title
          const Text(
            'Num Loop',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          // Right icon — right aligned, 44x44 tap area
          GestureDetector(
            onTap: gc.newGame,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerRight,
                child: isPauseIcon
                    ? Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.pause_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
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
  final bool useNewLayout;
  final void Function(GameMode) onSelectNewLayout;
  const _FullScreenDrawer({
    required this.onClose,
    required this.useNewLayout,
    required this.onSelectNewLayout,
  });

  @override
  Widget build(BuildContext context) {
    final gc = context.watch<GameController>();
    final currentMode = gc.gameMode;

    return Material(
      color: const Color(0xFFD9A84D),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: Color(0x99FFFFFF), size: 30),
                  onPressed: onClose,
                ),
              ),
            ),

            // Body
            Expanded(
              child: Align(
                alignment: const Alignment(0, -0.3),
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Game Mode
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
                      // ── New Layout ──
                      const Text(
                        'NEW LAYOUT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white38,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _MenuItem(
                        label: 'Normal ✦',
                        isActive: useNewLayout && currentMode == GameMode.normal,
                        onTap: () => onSelectNewLayout(GameMode.normal),
                      ),
                      _MenuItem(
                        label: 'Item ✦',
                        isActive: useNewLayout && currentMode == GameMode.item,
                        onTap: () => onSelectNewLayout(GameMode.item),
                      ),
                      _MenuItem(
                        label: 'Speed ✦',
                        isActive: useNewLayout && currentMode == GameMode.speed,
                        onTap: () => onSelectNewLayout(GameMode.speed),
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.white12),
                      const SizedBox(height: 12),
                      // Settings
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
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isActive ? const Color(0xFFB5762A) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Figma Layout: Score section ──────────────────────────────

class _FigmaScore extends StatelessWidget {
  const _FigmaScore();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) {
        final isSpeed = gc.gameMode == GameMode.speed;
        final bestValue = isSpeed ? gc.bestSpeedScore : gc.bestScore;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSpeed ? '⚡ $bestValue' : '😎 $bestValue',
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white70,
                letterSpacing: -0.5,
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
                '${gc.score}',
                key: ValueKey(gc.score),
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Video Background ─────────────────────────────────────────

class _VideoBackground extends StatefulWidget {
  final String asset;
  const _VideoBackground({required this.asset});

  @override
  State<_VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<_VideoBackground> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.asset)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

// ── Figma Layout: Home Indicator (Android only) ──────────────

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Center(
        child: Container(
          width: 144,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFBFBFBF),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
