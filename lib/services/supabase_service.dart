import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String get _redirectTo {
  if (kIsWeb) {
    final host = Uri.base.host;
    if (host == 'localhost' || host == '127.0.0.1') {
      // 로컬 개발: 현재 포트로 리다이렉트
      return '${Uri.base.scheme}://$host:${Uri.base.port}';
    }
    // 프로덕션 (GitHub Pages): 경로 포함 필수
    return 'https://allookim.github.io/new2048';
  }
  return 'io.supabase.hifomhsghpjceidveplk://login-callback/';
}

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

  /// 익명 데이터를 임시 저장 (Google/Apple 로그인 전 호출)
  Future<void> _saveAnonData() async {
    if (!isLoggedIn || !isAnonymous) return;
    final nickname = await getNickname();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_anon_nickname', nickname ?? '');
    await prefs.setInt('_anon_best_score', prefs.getInt('best_score') ?? 0);
    await prefs.setInt('_anon_best_item_score', prefs.getInt('best_item_score') ?? 0);
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    try {
      await _saveAnonData();
      if (!kIsWeb && isLoggedIn && isAnonymous) {
        await _client.auth.signOut();
      }
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectTo,
        queryParams: {'prompt': 'select_account'},
        authScreenLaunchMode: !kIsWeb && Platform.isIOS
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } catch (e) {
      debugPrint('Google sign in error: $e');
    }
  }

  /// Apple 로그인 (iOS only)
  Future<void> signInWithApple() async {
    try {
      await _saveAnonData();
      if (!kIsWeb && isLoggedIn && isAnonymous) {
        await _client.auth.signOut();
      }
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _redirectTo,
        authScreenLaunchMode: !kIsWeb && Platform.isIOS
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } catch (e) {
      debugPrint('Apple sign in error: $e');
    }
  }

  /// 로그인 후 점수 동기화
  /// - 신규 계정 (서버 점수 없음): 익명 데이터 승계 (닉네임 + 점수)
  /// - 기존 계정 (서버 점수 있음): 서버 점수로 교체
  Future<({int bestScore, int bestItemScore})> syncLocalScores(int localBest, int localBestItem) async {
    if (userId == null) return (bestScore: localBest, bestItemScore: localBestItem);
    try {
      final serverData = await _client
          .from('profiles')
          .select('best_score, best_item_score')
          .eq('id', userId!)
          .maybeSingle();
      final serverBest = (serverData?['best_score'] as int?) ?? 0;
      final serverBestItem = (serverData?['best_item_score'] as int?) ?? 0;

      // 기존 계정: 서버 점수로 교체
      if (serverData != null && (serverBest > 0 || serverBestItem > 0)) {
        _clearAnonData();
        return (bestScore: serverBest, bestItemScore: serverBestItem);
      }

      // 신규 계정: 익명 데이터 승계
      final prefs = await SharedPreferences.getInstance();
      final anonNickname = prefs.getString('_anon_nickname') ?? '';
      final anonBest = prefs.getInt('_anon_best_score') ?? 0;
      final anonBestItem = prefs.getInt('_anon_best_item_score') ?? 0;

      if (anonBest > 0 || anonBestItem > 0 || anonNickname.isNotEmpty) {
        // 닉네임 승계
        if (anonNickname.isNotEmpty) {
          await setNickname(anonNickname);
        }
        // 점수 승계
        if (anonBest > 0) await submitScore(score: anonBest, gameMode: 'normal');
        if (anonBestItem > 0) await submitScore(score: anonBestItem, gameMode: 'item');
        _clearAnonData();
        return (bestScore: anonBest, bestItemScore: anonBestItem);
      }

      _clearAnonData();
      return (bestScore: 0, bestItemScore: 0);
    } catch (e) {
      debugPrint('syncLocalScores error: $e');
      return (bestScore: localBest, bestItemScore: localBestItem);
    }
  }

  Future<void> _clearAnonData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('_anon_nickname');
    await prefs.remove('_anon_best_score');
    await prefs.remove('_anon_best_item_score');
  }

  /// 완전 로그아웃 (익명 재로그인 없음)
  Future<void> signOut() async {
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
    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('id', userId!)
        .maybeSingle();
    if (existing == null) {
      await _client.from('profiles').insert({
        'id': userId,
        'nickname': nickname,
      });
    } else {
      await _client.from('profiles').update({'nickname': nickname}).eq('id', userId!);
    }
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
    if (userId == null) {
      debugPrint('[submitScore] userId is null, skip');
      return;
    }
    final col = gameMode == 'item' ? 'best_item_score' : 'best_score';
    try {
      final existing = await _client
          .from('profiles')
          .select(col)
          .eq('id', userId!)
          .maybeSingle();

      final current = (existing?[col] as int?) ?? 0;
      if (score <= current) return;

      debugPrint('[submitScore] uploading $col=$score for $userId (existing: ${existing != null})');
      if (existing == null) {
        await _client.from('profiles').insert({
          'id': userId,
          'nickname': 'Player',
          col: score,
        });
      } else {
        await _client.from('profiles').update({col: score}).eq('id', userId!);
      }
      debugPrint('[submitScore] success');
    } catch (e) {
      debugPrint('[submitScore] ERROR: $e');
    }
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
