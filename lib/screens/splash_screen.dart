import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import 'game_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1800), _goToGame);
  }

  void _goToGame() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const GameScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타일 모양 로고
                _TileLogo(theme: theme),
                const SizedBox(height: 24),
                Text(
                  '2048',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: theme.textDark,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '타일을 합쳐서 2048을 만들어보세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 스플래쉬용 미니 2×2 타일 그리드 로고
class _TileLogo extends StatelessWidget {
  final dynamic theme;

  const _TileLogo({required this.theme});

  @override
  Widget build(BuildContext context) {
    const values = [2, 8, 64, 2048];
    const size = 52.0;
    const gap = 6.0;

    return SizedBox(
      width: size * 2 + gap,
      height: size * 2 + gap,
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: values.map((v) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.tileColor(v),
              borderRadius: BorderRadius.circular(theme.tileRadius),
            ),
          );
        }).toList(),
      ),
    );
  }
}
