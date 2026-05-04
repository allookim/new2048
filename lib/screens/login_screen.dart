import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/theme_controller.dart';
import '../services/supabase_service.dart';
import 'game_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // OAuth 리디렉션 복귀 시 자동으로 게임 화면으로 이동
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        _goToGame();
      }
    });
  }

  void _goToGame() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const GameScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _signInAsGuest() async {
    setState(() => _loading = true);
    await SupabaseService.instance.signInAsGuest();
    if (mounted) _goToGame();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    await SupabaseService.instance.signInWithGoogle();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    await SupabaseService.instance.signInWithApple();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final theme = context.watch<ThemeController>().theme;

    return Scaffold(
      backgroundColor: const Color(0xFF0a1e4a),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // 로고
              _TileLogo(tileRadius: theme.tileRadius),
              const SizedBox(height: 20),
              const Text(
                'Num Loop',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to save your ranking',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
              const Spacer(flex: 3),
              if (_loading)
                const CircularProgressIndicator(color: Color(0xFF6DDDD0))
              else ...[
                _LoginButton(
                  label: 'Continue with Google',
                  icon: Icons.login_rounded,
                  bgColor: Colors.white,
                  textColor: const Color(0xFF1E1460),
                  iconColor: const Color(0xFF1E1460),
                  onTap: _signInWithGoogle,
                ),
                if (isIOS) ...[
                  const SizedBox(height: 14),
                  _LoginButton(
                    label: ' Continue with Apple',
                    bgColor: Colors.black,
                    textColor: Colors.white,
                    onTap: _signInWithApple,
                  ),
                ],
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _signInAsGuest,
                  child: const Text(
                    'Play as Guest',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '⚠ Guest data will be lost if the app is reinstalled',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white38,
                  ),
                ),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _LoginButton({
    required this.label,
    this.icon,
    required this.bgColor,
    required this.textColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TileLogo extends StatelessWidget {
  final double tileRadius;
  const _TileLogo({required this.tileRadius});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFFDA72D),
      Color(0xFF533281),
      Color(0xFF399BFA),
      Color(0xFFED5270),
    ];
    const size = 52.0;
    const gap = 6.0;
    return SizedBox(
      width: size * 2 + gap,
      height: size * 2 + gap,
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: colors
            .map((c) => Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(tileRadius),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
