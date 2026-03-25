import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
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
    final theme = context.watch<ThemeController>().theme;

    return Consumer<GameController>(
      builder: (context, controller, _) {
        if (controller.gameMode != GameMode.speed) return const SizedBox.shrink();

        final seconds = controller.remainingSeconds.clamp(0, 999);
        final progress = (seconds / 60.0).clamp(0.0, 1.0);
        final isLow = seconds < 15;
        final isMid = seconds < 30;

        _updateBlink(isLow);

        final barColor = isLow
            ? Colors.red.shade400
            : isMid
                ? Colors.orange.shade400
                : const Color(0xFF6DDDD0);

        final timeDisplay = seconds >= 10
            ? seconds.toStringAsFixed(1)
            : seconds.toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 타이머 프로그레스 바
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.boardColor,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
              const SizedBox(height: 5),
              // 시간 표시
              AnimatedOpacity(
                opacity: isLow ? (_blink ? 1.0 : 0.3) : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 15, color: barColor),
                    const SizedBox(width: 4),
                    Text(
                      '${timeDisplay}s',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: isLow ? 17 : 14,
                        fontWeight: FontWeight.w900,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

