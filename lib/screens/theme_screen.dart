import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../core/theme/game_theme_data.dart';

const _kBg    = Color(0xFF0a1e4a);
const _kCard  = Color(0xFF1a2d6e);
const _kTeal  = Color(0xFF6DDDD0);

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final themes = themeController.availableThemes.values.toList();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Themes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42), // balance spacer
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Theme List ───────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                itemCount: themes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = themes[index];
                  final isSelected = t.id == themeController.currentThemeId;
                  final isLocked = !themeController.isUnlocked(t.id);

                  return _ThemeCard(
                    theme: t,
                    isSelected: isSelected,
                    isLocked: isLocked,
                    onTap: () {
                      if (!isLocked) themeController.switchTheme(t.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final GameThemeData theme;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemeCard({
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
        height: 96,
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: _kTeal, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // ── Thumbnail ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 76,
                  child: theme.backgroundAsset != null
                      ? Image.asset(theme.backgroundAsset!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _MiniGrid(theme: theme))
                      : _MiniGrid(theme: theme),
                ),
              ),
            ),

            // ── Theme Name ────────────────────────────────
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                theme.displayName,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),

            // ── Status Icon ───────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: isLocked
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : isSelected
                      ? const Icon(Icons.check_circle_rounded, color: _kTeal, size: 26)
                      : const Icon(Icons.radio_button_unchecked_rounded, color: Colors.white24, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

/// 배경 이미지 없을 때 미니 2×2 타일 그리드
class _MiniGrid extends StatelessWidget {
  final GameThemeData theme;
  const _MiniGrid({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniTile(color: theme.tileColor(2)),
              const SizedBox(width: 4),
              _MiniTile(color: theme.tileColor(8)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniTile(color: theme.tileColor(32)),
              const SizedBox(width: 4),
              _MiniTile(color: theme.tileColor(128)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final Color color;
  const _MiniTile({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
