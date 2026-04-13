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
        final visible = gc.status == GameStatus.gameOver ||
            gc.status == GameStatus.timeUp;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _handleVisibility(visible));

        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xE0100A36),
                borderRadius: BorderRadius.circular(16),
              ),
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
    final isItem = gc.gameMode == GameMode.item;
    final score = gc.score;
    final best = isItem ? gc.bestItemScore : gc.bestScore;
    final isNewBest = score > 0 && score >= best;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'GAME\nOVER',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 58,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6DDDD0),
              letterSpacing: 3,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 28),

          Text(
            '$score',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFD95C),
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
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

          const SizedBox(height: 16),

          if (isNewBest)
            const Text(
              'NEW BEST!',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
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
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0x66FFFFFF),
                letterSpacing: 1,
              ),
            ),

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

          const SizedBox(height: 36),

          _PlayAgainButton(onPressed: gc.newGame),
        ],
      ),
    );
  }
}

class _PlayAgainButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _PlayAgainButton({required this.onPressed});

  @override
  State<_PlayAgainButton> createState() => _PlayAgainButtonState();
}

class _PlayAgainButtonState extends State<_PlayAgainButton> {
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
            color: const Color(0xFF6DDDD0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'PLAY AGAIN',
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
