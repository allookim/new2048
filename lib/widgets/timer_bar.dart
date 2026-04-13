import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';

class TimerBar extends StatefulWidget {
  const TimerBar({super.key});

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar> {
  bool _blink = true;
  Timer? _blinkTimer;

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _updateBlink(bool isLow) {
    if (isLow && _blinkTimer == null) {
      _blinkTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
        if (mounted) setState(() => _blink = !_blink);
      });
    } else if (!isLow && _blinkTimer != null) {
      _blinkTimer?.cancel();
      _blinkTimer = null;
      _blink = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, _) {
        if (controller.gameMode != GameMode.item) return const SizedBox.shrink();

        final seconds = controller.remainingSeconds.clamp(0, 999);
        final progress = (seconds / 60.0).clamp(0.0, 1.0);
        final isLow = seconds < 20;
        const normalColor = Color(0xFFFFFFFF);
        const lowColor = Color(0xFFFF6363);
        final barColor = isLow ? lowColor : normalColor;

        _updateBlink(isLow);

        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: AnimatedOpacity(
            opacity: isLow ? (_blink ? 1.0 : 0.3) : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0x4D000000),
                    valueColor: AlwaysStoppedAnimation(barColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${seconds.toStringAsFixed(1)}s',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: barColor,
                    letterSpacing: -0.48,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

