import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

class GameCenterService {
  GameCenterService._();
  static final GameCenterService instance = GameCenterService._();

  static const String normalLeaderboardId = 'high_score_v1';

  bool _signedIn = false;
  bool get signedIn => _signedIn;

  bool get _supported => !kIsWeb && Platform.isIOS;

  Future<void> signIn() async {
    if (!_supported) return;
    try {
      await GamesServices.signIn();
      _signedIn = true;
    } catch (e) {
      debugPrint('GameCenter signIn failed: $e');
    }
  }

  Future<void> submitNormalScore(int score) async {
    if (!_supported || score <= 0) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          iOSLeaderboardID: normalLeaderboardId,
          androidLeaderboardID: '',
          value: score,
        ),
      );
    } catch (e) {
      debugPrint('GameCenter submit failed: $e');
    }
  }

  Future<String?> showLeaderboard() async {
    if (!_supported) return 'iOS 기기에서만 사용 가능합니다.';
    try {
      if (!_signedIn) {
        await GamesServices.signIn();
        _signedIn = true;
      }
      await GamesServices.showLeaderboards(
        iOSLeaderboardID: normalLeaderboardId,
        androidLeaderboardID: '',
      );
      return null;
    } catch (e) {
      debugPrint('GameCenter showLeaderboard failed: $e');
      return e.toString();
    }
  }
}
