import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final _client = Supabase.instance.client;

  String? get userId => _client.auth.currentUser?.id;
  bool get isLoggedIn => userId != null;

  /// 앱 시작 시 익명 로그인 (이미 세션 있으면 유지)
  Future<void> init() async {
    try {
      if (_client.auth.currentUser != null) return;
      await _client.auth.signInAnonymously();
    } catch (e) {
      // 로그인 실패해도 앱은 정상 실행
      debugPrint('Supabase init error: $e');
    }
  }

  /// 닉네임 설정 (처음 한 번)
  Future<void> setNickname(String nickname) async {
    if (userId == null) return;
    await _client.from('profiles').upsert({
      'id': userId,
      'nickname': nickname,
    });
  }

  /// 현재 닉네임 조회
  Future<String?> getNickname() async {
    if (userId == null) return null;
    final data = await _client
        .from('profiles')
        .select('nickname')
        .eq('id', userId!)
        .maybeSingle();
    return data?['nickname'] as String?;
  }

  /// 점수 업로드 (best score만 갱신)
  Future<void> submitScore({
    required int score,
    required String gameMode, // 'normal' | 'item'
  }) async {
    if (userId == null) return;
    final col = gameMode == 'item' ? 'best_item_score' : 'best_score';
    // 현재 저장된 값보다 높을 때만 업데이트
    final existing = await _client
        .from('profiles')
        .select(col)
        .eq('id', userId!)
        .maybeSingle();

    final current = (existing?[col] as int?) ?? 0;
    if (score <= current) return;

    await _client.from('profiles').upsert({
      'id': userId,
      col: score,
    });
  }

  /// 랭킹 조회 (mode: 'normal' | 'item')
  Future<List<RankEntry>> fetchRanking({
    String gameMode = 'normal',
    int limit = 50,
  }) async {
    final col = gameMode == 'item' ? 'best_item_score' : 'best_score';
    final data = await _client
        .from('profiles')
        .select('id, nickname, best_score, best_item_score')
        .gt(col, 0)
        .order(col, ascending: false)
        .limit(limit);

    return (data as List).map((e) => RankEntry.fromMap(e, gameMode)).toList();
  }

  /// 내 순위 조회
  Future<int?> fetchMyRank({String gameMode = 'normal'}) async {
    if (userId == null) return null;
    final col = gameMode == 'item' ? 'best_item_score' : 'best_score';
    final myData = await _client
        .from('profiles')
        .select(col)
        .eq('id', userId!)
        .maybeSingle();
    final myScore = (myData?[col] as int?) ?? 0;
    if (myScore == 0) return null;

    final result = await _client
        .from('profiles')
        .select('id')
        .gt(col, myScore);
    return (result as List).length + 1;
  }
}

class RankEntry {
  final String id;
  final String nickname;
  final int score;
  final bool isMe;

  RankEntry({
    required this.id,
    required this.nickname,
    required this.score,
    required this.isMe,
  });

  factory RankEntry.fromMap(Map<String, dynamic> map, String gameMode) {
    final col = gameMode == 'item' ? 'best_item_score' : 'best_score';
    return RankEntry(
      id: map['id'] as String,
      nickname: (map['nickname'] as String?) ?? 'Player',
      score: (map[col] as int?) ?? 0,
      isMe: map['id'] == Supabase.instance.client.auth.currentUser?.id,
    );
  }
}
