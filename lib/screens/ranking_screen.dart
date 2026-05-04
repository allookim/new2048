import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/game_center_service.dart';
import '../utils/nickname_filter.dart';

const _kBg    = Color(0xFF0a1e4a);
const _kCard  = Color(0xFF1a2d6e);
const _kTeal  = Color(0xFF6DDDD0);
const _kGold  = Color(0xFFFFD95C);

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _tabIndex = 0;
  List<RankEntry> _normalRanks = [];
  List<RankEntry> _itemRanks = [];
  int? _normalMyRank;
  int? _itemMyRank;
  bool _loading = true;
  String? _myNickname;

  @override
  void initState() {
    super.initState();
    _load();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // 로그인 안 된 경우 → 로그인 선택 팝업
    if (!SupabaseService.instance.isLoggedIn) {
      await _showLoginDialog();
      if (!mounted) return;
      _load(); // 로그인 후 랭킹 갱신
      return;
    }

    // 이미 로그인된 경우 → 닉네임 체크
    final nickname = await SupabaseService.instance.getNickname();
    if (!mounted) return;
    setState(() => _myNickname = nickname);
    if (nickname == null || nickname == 'Player') {
      if (mounted) await _showNicknameDialog(isFirst: true);
    }
  }

  Future<void> _showLoginDialog() async {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign in to use Ranking',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign in with Google to save your scores.\nGuest data may be lost on reinstall.',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.white60, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E1460),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                SupabaseService.instance.signInWithGoogle();
              },
              child: const Text('Continue with Google', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            if (isIOS) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  SupabaseService.instance.signInWithApple();
                },
                child: const Text(' Continue with Apple', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _kTeal,
                side: const BorderSide(color: _kTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await SupabaseService.instance.signInAsGuest();
                if (mounted) {
                  final nickname = await SupabaseService.instance.getNickname();
                  setState(() => _myNickname = nickname);
                  if (nickname == null || nickname == 'Player') {
                    if (mounted) await _showNicknameDialog(isFirst: true);
                  }
                }
              },
              child: const Text('Play as Guest', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        SupabaseService.instance.fetchRanking(gameMode: 'normal'),
        SupabaseService.instance.fetchRanking(gameMode: 'item'),
        SupabaseService.instance.fetchMyRank(gameMode: 'normal'),
        SupabaseService.instance.fetchMyRank(gameMode: 'item'),
      ]).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _normalRanks = results[0] as List<RankEntry>;
        _itemRanks   = results[1] as List<RankEntry>;
        _normalMyRank = results[2] as int?;
        _itemMyRank   = results[3] as int?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showAccountSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              // 현재 계정 정보
              Row(
                children: [
                  const Icon(Icons.person_rounded, color: _kTeal, size: 20),
                  const SizedBox(width: 10),
                  if (SupabaseService.instance.isAnonymous) ...[
                    const Text('Guest', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white54)),
                    if (_myNickname != null && _myNickname != 'Player') ...[
                      const SizedBox(width: 8),
                      Text(_myNickname!, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                    ],
                  ] else ...[
                    Text(_myNickname ?? 'Player', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _kTeal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                      child: const Text('Google', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 11, color: _kTeal)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 8),
              // 닉네임 변경
              _SheetOption(
                icon: Icons.edit_rounded,
                label: 'Change Nickname',
                onTap: () {
                  Navigator.pop(ctx);
                  _showNicknameDialog();
                },
              ),
              // Google 연동 (익명일 때만)
              if (SupabaseService.instance.isAnonymous) ...[
                _SheetOption(
                  icon: Icons.login_rounded,
                  label: 'Link with Google',
                  color: _kTeal,
                  onTap: () {
                    Navigator.pop(ctx);
                    SupabaseService.instance.signInWithGoogle();
                  },
                ),
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                  _SheetOption(
                    icon: Icons.phone_iphone_rounded,
                    label: ' Link with Apple',
                    color: Colors.white,
                    onTap: () {
                      Navigator.pop(ctx);
                      SupabaseService.instance.signInWithApple();
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNicknameDialog({bool isFirst = false}) async {
    final controller = TextEditingController(
      text: (_myNickname == null || _myNickname == 'Player') ? '' : _myNickname,
    );
    try {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          backgroundColor: _kCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isFirst ? 'Set your nickname' : 'Change nickname',
            style: const TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w900,
              fontSize: 20, color: Colors.white,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 14,
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter nickname',
              hintStyle: const TextStyle(color: Colors.white38),
              counterStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: _kBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kTeal, width: 1.5)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (isFirst) {
                  // 닉네임 설정 취소 → 세션 제거 → 다음 방문 시 로그인 선택 팝업 재표시
                  await SupabaseService.instance.signOutOnly();
                  if (mounted) setState(() => _myNickname = null);
                }
              },
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', color: Colors.white54, fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                final error = NicknameFilter.validate(name);
                if (error != null) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
                    );
                  }
                  return;
                }
                await SupabaseService.instance.setNickname(name);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) {
                  setState(() => _myNickname = name);
                  _load();
                }
              },
              child: const Text('Save', style: TextStyle(fontFamily: 'Nunito', color: _kTeal, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ],
        ),
      );
    } finally {
      // Delay dispose until dialog closing animation completes (~300ms)
      Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        'Ranking',
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                            IconButton(
                              icon: const Icon(Icons.emoji_events_rounded, color: Colors.white70, size: 26),
                              tooltip: 'Game Center',
                              onPressed: () async {
                                final err = await GameCenterService.instance.showLeaderboard();
                                if (err != null && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Game Center: $err')),
                                  );
                                }
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.person_rounded, color: Colors.white70, size: 26),
                            onPressed: _showAccountSheet,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Pill Tab ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _PillTab(
                labels: const ['Normal', 'Item Mode'],
                selectedIndex: _tabIndex,
                onTap: (i) => setState(() => _tabIndex = i),
              ),
            ),

            const SizedBox(height: 8),

            // ── Body ─────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _kTeal))
                  : IndexedStack(
                      index: _tabIndex,
                      children: [
                        _RankList(entries: _normalRanks, myRank: _normalMyRank, onRefresh: _load),
                        _RankList(entries: _itemRanks,  myRank: _itemMyRank,  onRefresh: _load),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pill Tab ───────────────────────────────────────────────────

class _PillTab extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _PillTab({required this.labels, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final isSelected = selectedIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 8, right: i == labels.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _kTeal : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isSelected ? const Color(0xFF1E1460) : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Account Sheet Option ───────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SheetOption({
    this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ── Rank List ──────────────────────────────────────────────────

class _RankList extends StatelessWidget {
  final List<RankEntry> entries;
  final int? myRank;
  final VoidCallback onRefresh;

  const _RankList({required this.entries, required this.myRank, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No scores yet', style: TextStyle(fontFamily: 'Nunito', color: Colors.white54, fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: _kTeal,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: entries.length + (myRank != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0 && myRank != null) return _MyRankBanner(rank: myRank!);
          final i = myRank != null ? index - 1 : index;
          return _RankRow(entry: entries[i], rank: i + 1);
        },
      ),
    );
  }
}

class _MyRankBanner extends StatelessWidget {
  final int rank;
  const _MyRankBanner({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kTeal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kTeal, width: 1),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text('My Rank: #$rank', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: _kTeal)),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final RankEntry entry;
  final int rank;
  const _RankRow({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    const rankColors = [Color(0xFFFFD700), Color(0xFFC0C0C0), Color(0xFFCD7F32)];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isMe ? _kTeal.withValues(alpha: 0.1) : _kCard,
        borderRadius: BorderRadius.circular(12),
        border: entry.isMe ? Border.all(color: _kTeal, width: 1) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              isTop3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                fontSize: isTop3 ? 22 : 15,
                color: isTop3 ? rankColors[rank - 1] : Colors.white54,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.nickname,
              style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16,
                color: entry.isMe ? _kTeal : Colors.white,
              ),
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 18, color: _kGold),
          ),
        ],
      ),
    );
  }
}
