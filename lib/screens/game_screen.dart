import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/theme_controller.dart';
import '../game/board_logic.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';
import '../widgets/game_board.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/skill_bar.dart';
import '../widgets/timer_bar.dart';
import '../widgets/win_overlay.dart';
import 'ranking_screen.dart';
import 'settings_screen.dart';
import 'theme_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<Offset> _drawerSlide;
  late AnimationController _pauseController;
  late Animation<double> _pauseFade;
  bool _useNewLayout = true;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _drawerSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut));

    _pauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _pauseFade = CurvedAnimation(parent: _pauseController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheTileImages());
  }

  void _precacheTileImages() {
    const assets = [
      'assets/tiles/Tile-sea-bg.png',
      'assets/tiles/Tile-sea-bg-fish-1.png',
      'assets/tiles/Tile-sea-bg-fish-2.png',
      'assets/tiles/Tile-sea-bg-fish-3.png',
      'assets/tiles/Tile-sea-bg-fish-4.png',
      'assets/tiles/Tile-sea-bg-fish-5.png',
      'assets/tiles/Tile-sea-bg-fish-6.png',
      'assets/tiles/Tile-sea-bg-fish-7.png',
      'assets/tiles/Tile-sea-bg-fish-8.png',
      'assets/tiles/Tile-sea-bg-fish-9.png',
    ];
    for (final asset in assets) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _pauseController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _drawerController.forward();
  }

  void _closeDrawer() {
    _drawerController.reverse();
  }

  void _openPauseMenu() {
    context.read<GameController>().pause();
    _pauseController.forward();
  }

  void _closePauseMenu() {
    context.read<GameController>().resume();
    _pauseController.reverse();
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardTop = constraints.maxHeight * 0.30;
          return Stack(
            children: [
              // Board — starts at 30% of screen height
              Positioned(
                top: boardTop, left: 0, right: 0,
                child: const GameBoard(),
              ),
              // Header & score — top (board 위 레이어)
              Positioned(
                top: 0, left: 24, right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _TitleRow(onMenu: _openDrawer, onPause: _openPauseMenu),
                    const SizedBox(height: 26),
                    const _FigmaScore(),
                    const TimerBar(),
                    const _ComboBadgeRow(),
                  ],
                ),
              ),
              // SkillBar — bottom (overlays 아래 레이어)
              Positioned(
                bottom: 32, left: 24, right: 24,
                child: const SkillBar(),
              ),
              if (isAndroid)
                const Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _HomeIndicator(),
                ),
              // Overlays — full screen (최상단 레이어)
              const Positioned.fill(child: GameOverOverlay()),
              const Positioned.fill(child: WinOverlay()),
            ],
          );
        },
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

          // ── Pause menu ────────────────────────────────────
          AnimatedBuilder(
            animation: _pauseFade,
            builder: (context, _) {
              if (_pauseFade.value == 0) return const SizedBox.shrink();
              return FadeTransition(
                opacity: _pauseFade,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Blur + dim
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    // Menu content
                    GestureDetector(
                      onTap: _closePauseMenu,
                      behavior: HitTestBehavior.opaque,
                      child: _PauseMenu(
                        onResume: _closePauseMenu,
                        onRestart: () {
                          _pauseController.value = 0;
                          context.read<GameController>().newGame();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
            // ── Left-side drawer ──────────────────────────────
            AnimatedBuilder(
              animation: _drawerController,
              builder: (context, _) {
                if (_drawerController.value == 0) return const SizedBox.shrink();
                return Stack(
                  children: [
                    // Dim overlay
                    GestureDetector(
                      onTap: _closeDrawer,
                      child: Container(
                        color: Colors.black.withValues(
                            alpha: 0.4 * _drawerController.value),
                      ),
                    ),
                    // Drawer panel
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
                );
              },
            ),
          ],
        ),
    );
  }
}

// ── Title row ────────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  final VoidCallback onMenu;
  final VoidCallback? onPause;
  const _TitleRow({required this.onMenu, this.onPause});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drawer icon — left
          GestureDetector(
            onTap: onMenu,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  'assets/images/ic_drawer.svg',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
          // Title
          const Text(
            'Num Loop',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          // Pause icon — right
          GestureDetector(
            onTap: onPause,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerRight,
                child: onPause != null
                    ? SvgPicture.asset(
                        'assets/images/ic_pause.svg',
                        width: 32,
                        height: 32,
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
        final isItem = gc.gameMode == GameMode.item;
        final bestLabel = isItem ? 'BEST ⚡' : 'BEST';
        final bestValue = isItem ? gc.bestItemScore : gc.bestScore;
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
                      _MenuItem(
                        label: 'Normal Mode',
                        isActive: currentMode == GameMode.normal,
                        onTap: () => onSelectNewLayout(GameMode.normal),
                      ),
                      _MenuItem(
                        label: 'Item Mode',
                        isActive: currentMode == GameMode.item,
                        onTap: () => onSelectNewLayout(GameMode.item),
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.white12),
                      const SizedBox(height: 12),
                      _MenuItem(
                        label: 'Ranking',
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RankingScreen()),
                          );
                        },
                      ),
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

// ── Combo badge ───────────────────────────────────────────────

class _ComboBadgeRow extends StatefulWidget {
  const _ComboBadgeRow();

  @override
  State<_ComboBadgeRow> createState() => _ComboBadgeRowState();
}

class _ComboBadgeRowState extends State<_ComboBadgeRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _flash;
  int _lastCombo = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.92), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _flash = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 80),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _triggerAnim(int combo) {
    if (combo >= 2 && combo != _lastCombo) {
      _ctrl.forward(from: 0);
    }
    _lastCombo = combo;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (_, gc, __) {
        _triggerAnim(gc.combo);

        if (gc.gameMode != GameMode.item || gc.combo < 2) {
          return const SizedBox(height: 35);
        }

        return SizedBox(
          height: 35,
          child: Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final bgColor = Color.lerp(
                  const Color(0xFF7DFDF0),
                  Colors.white,
                  _flash.value,
                )!;
                return Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7DFDF0).withValues(alpha: _flash.value * 0.5),
                          blurRadius: 10 + _flash.value * 10,
                          spreadRadius: _flash.value * 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${gc.combo}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF27085D),
                            letterSpacing: -0.54,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'COMBO!',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF27085D),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
              fontSize: 30,
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
        final bestValue = gc.gameMode == GameMode.item ? gc.bestItemScore : gc.bestScore;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/ic_best.svg',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$bestValue',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StrokeText(
              text: '${gc.score}',
              fontSize: 50,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              fillColor: Colors.white,
              strokeColor: const Color(0xFF006494),
              strokeWidth: 8,
            ),
          ],
        );
      },
    );
  }
}

// ── Stroke Text ──────────────────────────────────────────────

class _StrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const _StrokeText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.letterSpacing,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: 'Nunito',
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.1,
    );
    return Stack(
      children: [
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        Text(text, style: base.copyWith(color: fillColor)),
      ],
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

// ── Pause Menu ───────────────────────────────────────────────

class _PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  const _PauseMenu({required this.onResume, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: Color(0x99FFFFFF), size: 30),
                  onPressed: onResume,
                ),
              ),
            ),
            // Buttons
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PauseMenuItem(
                        label: 'Play game',
                        onTap: onResume,
                        bgColor: const Color(0xFF6DDDD0),
                        textColor: const Color(0xFF1E1460),
                      ),
                      const SizedBox(height: 16),
                      _PauseMenuItem(
                        label: 'Restart game',
                        onTap: onRestart,
                        bgColor: Colors.white.withValues(alpha: 0.15),
                        textColor: Colors.white,
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

class _PauseMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;
  const _PauseMenuItem({
    required this.label,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
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
