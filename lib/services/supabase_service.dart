import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final _client = Supabase.instance.client;

  String? get userId => _client.auth.currentUser?.id;
  bool get isLoggedIn => userId != null;
  // 실제 익명 로그인 상태 (로그인 안 된 경우는 false)
  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? false;
  String? get userEmail => _client.auth.currentUser?.email;

  /// 앱 시작 시 세션 복원 (자동 익명 로그인 제거 — LoginScreen이 담당)
  Future<void> init() async {
    try {
      if (_client.auth.currentUser != null && !isAnonymous) {
        await _syncNicknameFromGoogle();
      }
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }

  /// Guest (익명) 로그인
  Future<void> signInAsGuest() async {
    try {
      await _client.auth.signInAnonymously();
    } catch (e) {
      debugPrint('Anonymous sign in error: $e');
    }
  }

  /// Google 로그인 or 연동
  /// - 익명 유저: linkIdentity로 기존 데이터 유지, 중복 계정 없음
  /// - 미로그인: signInWithOAuth로 신규 로그인
  Future<void> signInWithGoogle() async {
    try {
      final redirectTo = kIsWeb
          ? 'https://allookim.github.io/new2048'
          : 'io.supabase.hifomhsghpjceidveplk://login-callback/';
      if (isLoggedIn && isAnonymous) {
        await _client.auth.linkIdentity(OAuthProvider.google, redirectTo: redirectTo);
      } else {
        await _client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: redirectTo);
      }
    } catch (e) {
      debugPrint('Google sign in error: $e');
    }
  }

  /// Apple 로그인 or 연동 (iOS only)
  Future<void> signInWithApple() async {
    try {
      final redirectTo = kIsWeb
          ? 'https://allookim.github.io/new2048'
          : 'io.supabase.hifomhsghpjceidveplk://login-callback/';
      if (isLoggedIn && isAnonymous) {
        await _client.auth.linkIdentity(OAuthProvider.apple, redirectTo: redirectTo);
      } else {
        await _client.auth.signInWithOAuth(OAuthProvider.apple, redirectTo: redirectTo);
      }
    } catch (e) {
      debugPrint('Apple sign in error: $e');
    }
  }

  /// 로그아웃 후 익명 세션으로 복귀
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await _client.auth.signInAnonymously();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// 세션만 제거 (익명 재로그인 없음) — 닉네임 설정 취소 시 사용
  Future<void> signOutOnly() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Google 프로필 이름으로 닉네임 자동 설정 (기본값 'Player'인 경우만)
  Future<void> _syncNicknameFromGoogle() async {
    final googleName =
        _client.auth.currentUser?.userMetadata?['name'] as String?;
    if (googleName == null) return;
    final existing = await getNickname();
    if (existing == null || existing == 'Player') {
      await setNickname(googleName);
    }
  }

  /// 닉네임 설정
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
