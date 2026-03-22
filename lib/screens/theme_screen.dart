import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../widgets/theme_preview_card.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final theme = themeController.theme;
    final themes = themeController.availableThemes.values.toList();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Themes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textDark,
          ),
        ),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final t = themes[index];
            final isSelected = t.id == themeController.currentThemeId;
            final isLocked = !themeController.isUnlocked(t.id);

            return ThemePreviewCard(
              theme: t,
              isSelected: isSelected,
              isLocked: isLocked,
              onTap: () {
                if (!isLocked) {
                  themeController.switchTheme(t.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
