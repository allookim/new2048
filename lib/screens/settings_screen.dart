import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textDark),
        title: Text(
          '설정',
          style: TextStyle(
            color: theme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _SectionHeader(label: '게임', theme: theme),
            _SettingsTile(
              icon: Icons.vibration,
              label: '진동 효과',
              theme: theme,
              trailing: Switch(
                value: false,
                onChanged: (_) {},
                activeColor: theme.buttonColor,
              ),
            ),
            _SettingsTile(
              icon: Icons.music_note,
              label: '효과음',
              theme: theme,
              trailing: Switch(
                value: false,
                onChanged: (_) {},
                activeColor: theme.buttonColor,
              ),
            ),
            const SizedBox(height: 16),
            _SectionHeader(label: '정보', theme: theme),
            _SettingsTile(
              icon: Icons.info_outline,
              label: '버전',
              theme: theme,
              trailing: Text(
                '1.0.0',
                style: TextStyle(
                  color: theme.textDark.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final dynamic theme;

  const _SectionHeader({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.textDark.withValues(alpha: 0.45),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic theme;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.theme,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.boardColor,
        borderRadius: BorderRadius.circular(theme.tileRadius + 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.buttonColor, size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: theme.textDark,
            fontSize: 15,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
