import 'package:flutter/material.dart';

// ── Warm fixed palette (메뉴와 동일 계열) ────────────────────
const _kBg     = Color(0xFFD9A84D); // 메뉴 배경과 동일
const _kCard   = Color(0xFFC08030); // 카드 (약간 어두운 브라운)
const _kAccent = Color(0xFF7A4A00); // 아이콘 강조 (진한 브라운)
const _kText   = Colors.white;
const _kDim    = Color(0xB3FFFFFF); // 보조 텍스트
const _kLabel  = Color(0x80FFFFFF); // 섹션 레이블

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibration = false;
  bool _sound = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Title row ──────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back_rounded,
                          color: _kText, size: 24),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _kText,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // balance spacer
                ],
              ),

              const SizedBox(height: 28),

              // ── Section: Game ─────────────────────────────
              _SectionLabel('GAME SETTINGS'),
              const SizedBox(height: 8),
              _ToggleTile(
                icon: Icons.vibration_rounded,
                label: 'Vibration',
                value: _vibration,
                onChanged: (v) => setState(() => _vibration = v),
              ),
              const SizedBox(height: 8),
              _ToggleTile(
                icon: Icons.music_note_rounded,
                label: 'Sound Effects',
                value: _sound,
                onChanged: (v) => setState(() => _sound = v),
              ),

              const SizedBox(height: 24),

              // ── Section: Info ─────────────────────────────
              _SectionLabel('INFO'),
              const SizedBox(height: 8),
              _InfoTile(
                icon: Icons.info_outline_rounded,
                label: 'Version',
                value: '1.0.0',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: _kLabel,
        letterSpacing: 3,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: _kAccent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: _kAccent,
            inactiveThumbColor: _kDim,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: _kAccent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kDim,
            ),
          ),
        ],
      ),
    );
  }
}
