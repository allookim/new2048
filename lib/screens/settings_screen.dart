import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

// ── Warm fixed palette (메뉴와 동일 계열) ────────────────────
const _kBg     = Color(0xFFD9A84D);
const _kCard   = Color(0xFFC08030);
const _kAccent = Color(0xFF7A4A00);
const _kText   = Colors.white;
const _kDim    = Color(0xB3FFFFFF);
const _kLabel  = Color(0x80FFFFFF);

// 카드 라운드: 풀라운드 기준 50%
const _kRadiusFull = 999.0; // version (pill)
const _kRadius     = 24.0;  // 일반 카드

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibration = false;
  bool _sound = false;
  String? _nickname;
  bool _isAnonymous = true;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    final svc = SupabaseService.instance;
    final nickname = await svc.getNickname();
    if (!mounted) return;
    setState(() {
      _isAnonymous = svc.isAnonymous;
      _nickname = nickname;
      _email = svc.userEmail;
    });
  }

  Future<void> _changeNickname() async {
    final controller = TextEditingController(text: _nickname ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Change nickname',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: _kText),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 14,
          style: const TextStyle(fontFamily: 'Nunito', color: _kText),
          decoration: InputDecoration(
            hintText: 'Enter nickname',
            hintStyle: const TextStyle(color: _kDim),
            counterStyle: const TextStyle(color: _kDim),
            filled: true,
            fillColor: _kBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kText, width: 1.5)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: _kDim, fontFamily: 'Nunito'))),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await SupabaseService.instance.setNickname(name);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() => _nickname = name);
            },
            child: const Text('Save', style: TextStyle(color: _kText, fontFamily: 'Nunito', fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    controller.dispose();
  }

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
                      child: Icon(Icons.arrow_back_rounded, color: _kText, size: 24),
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
                  const SizedBox(width: 36),
                ],
              ),

              const SizedBox(height: 28),

              // ── Section: Account ──────────────────────────
              _SectionLabel('ACCOUNT'),
              const SizedBox(height: 8),
              _AccountCard(
                isAnonymous: _isAnonymous,
                nickname: _nickname,
                email: _email,
                onLoginWithGoogle: () async {
                  await SupabaseService.instance.signInWithGoogle();
                },
                onChangeNickname: _changeNickname,
              ),

              const SizedBox(height: 24),

              // ── Section: Game ─────────────────────────────
              _SectionLabel('GAME SETTINGS'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(_kRadius),
                ),
                child: Column(
                  children: [
                    _ToggleTile(
                      icon: Icons.vibration_rounded,
                      label: 'Vibration',
                      value: _vibration,
                      onChanged: (v) => setState(() => _vibration = v),
                    ),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.1), indent: 16, endIndent: 16),
                    _ToggleTile(
                      icon: Icons.music_note_rounded,
                      label: 'Sound Effects',
                      value: _sound,
                      onChanged: (v) => setState(() => _sound = v),
                    ),
                  ],
                ),
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

// ── Account Card ──────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final bool isAnonymous;
  final String? nickname;
  final String? email;
  final VoidCallback onLoginWithGoogle;
  final VoidCallback onChangeNickname;

  const _AccountCard({
    required this.isAnonymous,
    required this.nickname,
    required this.email,
    required this.onLoginWithGoogle,
    required this.onChangeNickname,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(_kRadius),
      ),
      child: isAnonymous ? _buildAnonymous() : _buildLoggedIn(),
    );
  }

  Widget _buildAnonymous() {
    return Row(
      children: [
        const Icon(Icons.person_outline_rounded, color: _kAccent, size: 22),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: _kText)),
              Text('Not signed in', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: _kDim)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onLoginWithGoogle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _kAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Google',
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 13, color: _kText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedIn() {
    return Row(
      children: [
        const Icon(Icons.person_rounded, color: _kAccent, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nickname ?? 'Player',
                style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: _kText),
              ),
              if (email != null)
                Text(email!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: _kDim)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onChangeNickname,
          child: const Icon(Icons.edit_rounded, color: _kDim, size: 20),
        ),
      ],
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
    return SizedBox(
      height: 56,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    ));
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
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(_kRadiusFull),
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
