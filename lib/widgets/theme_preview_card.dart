import 'package:flutter/material.dart';
import '../core/theme/game_theme_data.dart';

class ThemePreviewCard extends StatelessWidget {
  final GameThemeData theme;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.buttonColor, width: 3)
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: isSelected
              ? [BoxShadow(color: theme.buttonColor.withValues(alpha: 0.3), blurRadius: 8)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mini 2x2 grid preview
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.boardColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MiniTile(color: theme.tileColor(2), size: 28),
                      const SizedBox(width: 3),
                      _MiniTile(color: theme.tileColor(8), size: 28),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MiniTile(color: theme.tileColor(32), size: 28),
                      const SizedBox(width: 3),
                      _MiniTile(color: theme.tileColor(128), size: 28),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.textDark,
              ),
            ),
            if (isLocked)
              Icon(Icons.lock, size: 16, color: theme.textDark),
            if (isSelected)
              Icon(Icons.check_circle, size: 16, color: theme.buttonColor),
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final Color color;
  final double size;

  const _MiniTile({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
