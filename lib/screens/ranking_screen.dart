import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RankEntry> _normalRanks = [];
  List<RankEntry> _itemRanks = [];
  int? _normalMyRank;
  int? _itemMyRank;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      SupabaseService.instance.fetchRanking(gameMode: 'normal'),
      SupabaseService.instance.fetchRanking(gameMode: 'item'),
      SupabaseService.instance.fetchMyRank(gameMode: 'normal'),
      SupabaseService.instance.fetchMyRank(gameMode: 'item'),
    ]);
    if (!mounted) return;
    setState(() {
      _normalRanks = results[0] as List<RankEntry>;
      _itemRanks = results[1] as List<RankEntry>;
      _normalMyRank = results[2] as int?;
      _itemMyRank = results[3] as int?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a1e4a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a1e4a),
        foregroundColor: Colors.white,
        title: const Text(
          'Ranking',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6DDDD0),
          labelColor: const Color(0xFF6DDDD0),
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Normal'),
            Tab(text: 'Item Mode'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6DDDD0)))
          : TabBarView(
              controller: _tabController,
              children: [
                _RankList(
                  entries: _normalRanks,
                  myRank: _normalMyRank,
                  onRefresh: _load,
                ),
                _RankList(
                  entries: _itemRanks,
                  myRank: _itemMyRank,
                  onRefresh: _load,
                ),
              ],
            ),
    );
  }
}

class _RankList extends StatelessWidget {
  final List<RankEntry> entries;
  final int? myRank;
  final VoidCallback onRefresh;

  const _RankList({
    required this.entries,
    required this.myRank,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No scores yet',
          style: TextStyle(
            fontFamily: 'Nunito',
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: const Color(0xFF6DDDD0),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: entries.length + (myRank != null ? 1 : 0),
        itemBuilder: (context, index) {
          // 상단 내 순위 배너
          if (index == 0 && myRank != null) {
            return _MyRankBanner(rank: myRank!);
          }
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
        color: const Color(0xFF6DDDD0).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6DDDD0), width: 1),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(
            'My Rank: #$rank',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF6DDDD0),
            ),
          ),
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
    final rankColors = [
      const Color(0xFFFFD700), // 1st gold
      const Color(0xFFC0C0C0), // 2nd silver
      const Color(0xFFCD7F32), // 3rd bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isMe
            ? const Color(0xFF6DDDD0).withValues(alpha: 0.1)
            : const Color(0xFF1a2d6e),
        borderRadius: BorderRadius.circular(12),
        border: entry.isMe
            ? Border.all(color: const Color(0xFF6DDDD0), width: 1)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              isTop3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
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
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: entry.isMe ? const Color(0xFF6DDDD0) : Colors.white,
              ),
            ),
          ),
          Text(
            _formatScore(entry.score),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFFFFD95C),
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) return '${(score / 1000000).toStringAsFixed(1)}M';
    if (score >= 1000) return '${(score / 1000).toStringAsFixed(1)}K';
    return '$score';
  }
}
