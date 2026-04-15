import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import '../models/game_state.dart';

class WinOverlay extends StatefulWidget {
  const WinOverlay({super.key});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
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
        final visible = gc.status == GameStatus.won;
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
                  child: Transform.scale(scale: _scale.value, child: child),
                ),
                child: _WinContent(gc: gc),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WinContent extends StatelessWidget {
  final GameController gc;
  const _WinContent({required this.gc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'YOU\nWIN!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 58,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFD95C),
              letterSpacing: 3,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '2048',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6DDDD0),
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'REACHED',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0x80FFFFFF),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 36),
          _PulsingWrapper(
            child: _WinButton(
              label: 'KEEP GOING',
              bg: const Color(0xFF6DDDD0),
              fg: const Color(0xFF1E1460),
              onPressed: gc.continueAfterWin,
            ),
          ),
          const SizedBox(height: 12),
          _WinButton(
            label: 'NEW GAME',
            bg: Colors.white.withValues(alpha: 0.12),
            fg: Colors.white,
            onPressed: gc.newGame,
          ),
        ],
      ),
    );
  }
}

class _PulsingWrapper extends StatefulWidget {
  final Widget child;
  const _PulsingWrapper({required this.child});

  @override
  State<_PulsingWrapper> createState() => _PulsingWrapperState();
}

class _PulsingWrapperState extends State<_PulsingWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 0.0, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6DDDD0).withValues(alpha: _glow.value),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class _WinButton extends StatefulWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onPressed;
  const _WinButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onPressed,
  });

  @override
  State<_WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<_WinButton> {
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
            color: widget.bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: widget.fg,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
