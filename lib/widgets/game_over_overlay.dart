import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import '../models/game_state.dart';
import '../models/game_mode.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleVisibility(bool visible) {
    if (visible && !_wasVisible) {
      _ctrl.forward(from: 0);
    } else if (!visible && _wasVisible) {
      _ctrl.reset();
    }
    _wasVisible = visible;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gc, _) {
        final visible = gc.status == GameStatus.gameOver;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _handleVisibility(visible));

        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: const Color(0xE0100A36),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Opacity(
                  opacity: _fade.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _scale.value,
                    child: child,
                  ),
                ),
                child: _GameOverContent(gc: gc),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameOverContent extends StatelessWidget {
  final GameController gc;
  const _GameOverContent({required this.gc});

  @override
  Widget build(BuildContext context) {
    final isSpeed = gc.gameMode == GameMode.speed;
    final score = gc.score;
    final best = isSpeed ? gc.bestSpeedScore : gc.bestScore;
    final isNewBest = score > 0 && score >= best;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Text(
            'GAME\nOVER',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF4E8C),
              letterSpacing: 3,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 28),

          // Score — label on top, number below
          const Text(
            'SCORE',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0x80FFFFFF),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$score',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFD95C),
              height: 1,
            ),
          ),

          const SizedBox(height: 16),

          // Best / extra stats
          if (isNewBest)
            const Text(
              'NEW BEST!',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6DDDD0),
                letterSpacing: 2,
              ),
            )
          else
            Text(
              'BEST  $best',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),

          if (isSpeed) ...[
            const SizedBox(height: 6),
            Text(
              'MAX COMBO  ${gc.maxCombo}×',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0x55FFFFFF),
                letterSpacing: 1,
              ),
            ),
          ],

          const SizedBox(height: 36),

          // CTA
          _TryAgainButton(onPressed: gc.newGame),
        ],
      ),
    );
  }
}

class _TryAgainButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _TryAgainButton({required this.onPressed});

  @override
  State<_TryAgainButton> createState() => _TryAgainButtonState();
}

class _TryAgainButtonState extends State<_TryAgainButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'TRY AGAIN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1460),
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
