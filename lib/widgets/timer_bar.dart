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
                : Colors.green.shade500;

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
              // 시간 + 콤보 행
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                            fontSize: isLow ? 17 : 14,
                            fontWeight: FontWeight.bold,
                            color: barColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 콤보 배지
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: controller.combo >= 2
                        ? _ComboBadge(
                            key: ValueKey(controller.combo),
                            combo: controller.combo,
                            multiplier: controller.comboMultiplier,
                            theme: theme,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ComboBadge extends StatelessWidget {
  final int combo;
  final double multiplier;
  final dynamic theme;

  const _ComboBadge({
    super.key,
    required this.combo,
    required this.multiplier,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: theme.buttonColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${combo} COMBO',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '×${multiplier.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
