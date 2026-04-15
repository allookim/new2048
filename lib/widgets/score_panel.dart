import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';

class ScorePanel extends StatelessWidget {
  const ScorePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Consumer<GameController>(
      builder: (context, controller, _) {
        final isSpeed = controller.gameMode == GameMode.item;
        final bestValue = isSpeed ? controller.bestItemScore : controller.bestScore;

        return Column(
          children: [
            // 상단 Row: 스코어 박스
            Row(
              children: [
                Expanded(child: _ScoreBox(label: 'SCORE', value: controller.score)),
                const SizedBox(width: 8),
                Expanded(child: _ScoreBox(label: 'BEST', iconSuffix: isSpeed ? '⚡' : null, value: bestValue)),
              ],
            ),
            const SizedBox(height: 6),
            // 하단 Row: 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isSpeed) ...[
                  _SmallButton(
                    icon: Icons.undo,
                    onPressed: controller.canUndo ? controller.undo : null,
                    backgroundColor: theme.boardColor,
                  ),
                  const SizedBox(width: 6),
                ],
                _SmallButton(
                  label: 'New Game',
                  onPressed: controller.newGame,
                  backgroundColor: theme.boardColor,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const _SmallButton({
    this.label,
    this.icon,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.tileRadius),
        ),
      ),
      child: icon != null
          ? Icon(icon, size: 18)
          : Text(
              label!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
    );
  }
}

class _ScoreBox extends StatefulWidget {
  final String label;
  final int value;
  final String? iconSuffix;

  const _ScoreBox({required this.label, required this.value, this.iconSuffix});

  @override
  State<_ScoreBox> createState() => _ScoreBoxState();
}

class _ScoreBoxState extends State<_ScoreBox> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.scoreBackground,
        borderRadius: BorderRadius.circular(theme.tileRadius),
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(text: widget.label),
                if (widget.iconSuffix != null)
                  TextSpan(
                    text: ' ${widget.iconSuffix}',
                    style: const TextStyle(fontSize: 15),
                  ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              '${widget.value}',
              key: ValueKey(widget.value),
              style: const TextStyle(
                fontSize: 20,
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
