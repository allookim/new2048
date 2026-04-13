import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tile.dart';
import '../models/tile.dart' show TileType;
import '../services/supabase_service.dart';
import '../models/game_state.dart';
import '../models/game_mode.dart';
import '../skills/skill.dart';
import '../skills/skill_inventory.dart';
import '../skills/skill_registry.dart';
import 'board_logic.dart';
import 'board_snapshot.dart';
import 'spawn_config.dart';

class GameController extends ChangeNotifier {
  static const String _bestScoreKey = 'best_score';
  static const String _bestItemScoreKey = 'best_item_score';
  static const int _maxHistorySize = 5;
  static const double _speedInitialSeconds = 60.0;

  List<List<Tile?>> _board = List.generate(4, (_) => List.filled(4, null));
  int _score = 0;
  int _bestScore = 0;
  int _bestItemScore = 0;
  GameStatus _status = GameStatus.playing;
  bool _hasSeenWin = false;
  final Random _random = Random();
  final List<BoardSnapshot> _history = [];
  SpawnConfig _spawnConfig = const SpawnConfig();
  GameMode _gameMode = GameMode.normal;

  // Skill system
  late SkillInventory _skillInventory;
  String? _activeSkillId;

  // Speed mode
  Timer? _speedTimer;
  double _remainingSeconds = _speedInitialSeconds;
  int _combo = 0;
  double _comboMultiplier = 1.0;
  DateTime? _lastMoveTime;
  int _maxCombo = 0;

  bool _isPaused = false;

  List<List<Tile?>> get board => _board;
  int get score => _score;
  int get bestScore => _bestScore;
  int get bestItemScore => _bestItemScore;
  GameStatus get status => _status;
  bool get isPaused => _isPaused;
  bool get canUndo => _history.isNotEmpty && _gameMode != GameMode.item;
  SkillInventory get skillInventory => _skillInventory;
  String? get activeSkillId => _activeSkillId;
  bool get isTargeting => _activeSkillId != null;
  GameMode get gameMode => _gameMode;
  double get remainingSeconds => _remainingSeconds;
  int get combo => _combo;
  double get comboMultiplier => _comboMultiplier;
  int get maxCombo => _maxCombo;

  static List<Skill> get defaultSkills => defaultSkillSet;

  GameController() {
    _skillInventory = SkillInventory(defaultSkills);
    _loadBestScores().then((_) => newGame());
  }

  Future<void> _loadBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    _bestItemScore = prefs.getInt(_bestItemScoreKey) ?? 0;
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, _bestScore);
    SupabaseService.instance.submitScore(score: _bestScore, gameMode: 'normal');
  }

  Future<void> _saveBestItemScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestItemScoreKey, _bestItemScore);
    SupabaseService.instance.submitScore(score: _bestItemScore, gameMode: 'item');
  }

  void _pushHistory() {
    _history.add(BoardSnapshot.capture(_board, _score, _status));
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
  }

  void undo() {
    if (_history.isEmpty || _gameMode == GameMode.item) return;
    final snapshot = _history.removeLast();
    _board = snapshot.board;
    _score = snapshot.score;
    _status = snapshot.status;
    _activeSkillId = null;
    notifyListeners();
  }

  void setSpawnConfig(SpawnConfig config) => _spawnConfig = config;
  void resetSpawnConfig() => _spawnConfig = const SpawnConfig();

  /// 게임 모드를 지정해서 새 게임 시작
  void startGame(GameMode mode) {
    _speedTimer?.cancel();
    _gameMode = mode;
    newGame();
  }

  void pause() {
    if (_isPaused || _status != GameStatus.playing) return;
    _isPaused = true;
    if (_gameMode == GameMode.item) _speedTimer?.cancel();
    notifyListeners();
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    if (_gameMode == GameMode.item && _status == GameStatus.playing) {
      _startSpeedTimer();
    }
    notifyListeners();
  }

  void newGame() {
    _speedTimer?.cancel();
    _isPaused = false;
    _board = List.generate(4, (_) => List.filled(4, null));
    _score = 0;
    _status = GameStatus.playing;
    _hasSeenWin = _gameMode == GameMode.item; // 스피드 모드는 2048 후에도 계속
    _history.clear();
    _skillInventory = SkillInventory(defaultSkills);
    _activeSkillId = null;

    if (_gameMode == GameMode.item) {
      _spawnConfig = const SpawnConfig(fourSpawnRate: 0.25);
      _remainingSeconds = _speedInitialSeconds;
      _combo = 0;
      _comboMultiplier = 1.0;
      _lastMoveTime = null;
      _maxCombo = 0;
      _startSpeedTimer();
    } else {
      _spawnConfig = const SpawnConfig();
    }

    _spawnTile();
    _spawnTile();
    notifyListeners();
  }

  void _startSpeedTimer() {
    _speedTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _remainingSeconds -= 0.1;
      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        _speedTimer?.cancel();
        _status = GameStatus.timeUp;
        if (_score > _bestItemScore) {
          _bestItemScore = _score;
          _saveBestItemScore();
        }
      }
      notifyListeners();
    });
  }

  void move(Direction direction) {
    if (_status == GameStatus.gameOver || _status == GameStatus.timeUp) return;
    if (_isPaused) return;
    if (isTargeting) {
      _activeSkillId = null;
      notifyListeners();
      return;
    }

    final result = applyMove(_board, direction);
    if (!result.didChange) return;

    _pushHistory();
    _board = result.board;

    if (_gameMode == GameMode.item) {
      // 콤보 계산
      final now = DateTime.now();
      if (result.mergeCount > 0) {
        final timeSinceLast = _lastMoveTime != null
            ? now.difference(_lastMoveTime!).inMilliseconds
            : 9999;
        _combo = timeSinceLast <= 800 ? _combo + 1 : 1;
        if (_combo > _maxCombo) _maxCombo = _combo;
      } else {
        _combo = 0;
      }
      _lastMoveTime = now;
      _comboMultiplier = _comboToMultiplier(_combo);

      // 점수에 콤보 배수 적용
      final multipliedScore = (result.scoreGained * _comboMultiplier).round();
      _score += multipliedScore;

      // 시간 보너스 계산
      double timeBonus = result.mergeCount * 0.5;
      if (result.mergeCount >= 2) timeBonus += 1.0;

      // 이번 이동에서 생성된 최고 머지 값 확인
      int maxMergedValue = 0;
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          final tile = _board[r][c];
          if (tile != null && tile.isMerged && tile.value > maxMergedValue) {
            maxMergedValue = tile.value;
          }
        }
      }
      if (maxMergedValue >= 512) timeBonus += 2.0;
      if (maxMergedValue >= 2048) timeBonus += 10.0;

      _remainingSeconds = (_remainingSeconds + timeBonus).clamp(0, 999);

      // 스피드 베스트 갱신
      if (_score > _bestItemScore) {
        _bestItemScore = _score;
        _saveBestItemScore();
      }

    } else {
      _score += result.scoreGained;

      if (_score > _bestScore) {
        _bestScore = _score;
        _saveBestScore();
      }

      // 폭탄 폭발 처리
      for (final (r, c) in result.bombPositions) {
        _explodeBomb(r, c);
      }

      // 얼음 타일 카운트다운 & 자동 해동
      _decrementFrozenTiles();

      if (!_hasSeenWin && hasWon(_board)) {
        _status = GameStatus.won;
        _spawnTile();
        notifyListeners();
        return;
      }
    }

    _spawnTile();

    if (isGameOver(_board)) {
      _status = GameStatus.gameOver;
      if (_gameMode == GameMode.item) _speedTimer?.cancel();
    }

    notifyListeners();
  }

  double _comboToMultiplier(int combo) {
    if (combo <= 1) return 1.0;
    if (combo == 2) return 1.5;
    if (combo == 3) return 2.0;
    return 3.0;
  }

  /// 얼음·잠금 타일 카운트다운: 매 턴 1씩 감소, 0이 되면 일반 타일로 전환
  void _decrementFrozenTiles() {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final tile = _board[r][c];
        if (tile == null) continue;
        if (tile.tileType != TileType.ice && tile.tileType != TileType.lock) continue;

        final remaining = tile.frozenTurns - 1;
        if (remaining <= 0) {
          _board[r][c] = tile.copyWith(
            tileType: TileType.normal,
            frozenTurns: 0,
            isMerged: true,
          );
        } else {
          _board[r][c] = tile.copyWith(frozenTurns: remaining);
        }
      }
    }
  }

  /// 폭탄 폭발: 해당 위치의 폭탄을 일반 타일로 변환 후 4방향 인접 타일 제거
  void _explodeBomb(int r, int c) {
    // 폭탄 자신은 남기되 일반 타일로 전환
    if (_board[r][c] != null) {
      _board[r][c] = _board[r][c]!.copyWith(tileType: TileType.normal);
    }
    // 상하좌우 타일 제거
    const offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dr, dc) in offsets) {
      final nr = r + dr;
      final nc = c + dc;
      if (nr >= 0 && nr < 4 && nc >= 0 && nc < 4) {
        _board[nr][nc] = null;
      }
    }
  }

  void activateSkill(String skillId) {
    if (_status == GameStatus.gameOver) return;
    if (_gameMode != GameMode.item) return;

    final skill = _skillInventory.getSkill(skillId);
    if (skill == null) return;
    if (!_skillInventory.canUse(skillId)) return;
    if (!skill.canUse(_board, _score)) return;

    if (skill.requiresTarget) {
      _activeSkillId = (_activeSkillId == skillId) ? null : skillId;
      notifyListeners();
    }
  }

  void applyTargetedSkill(int row, int col) {
    if (_activeSkillId == null) return;

    final skill = _skillInventory.getSkill(_activeSkillId!);
    if (skill == null) {
      _activeSkillId = null;
      notifyListeners();
      return;
    }

    final result = skill.apply(_board, _score, targetRow: row, targetCol: col);
    if (!result.wasApplied) return;

    _pushHistory();
    _board = result.newBoard;
    _score += result.scoreChange;

    if (_score > _bestScore) {
      _bestScore = _score;
      _saveBestScore();
    }

    _skillInventory.use(_activeSkillId!);
    _activeSkillId = null;

    if (!_hasSeenWin && hasWon(_board)) {
      _status = GameStatus.won;
    } else if (isGameOver(_board)) {
      _status = GameStatus.gameOver;
    }

    notifyListeners();
  }

  void cancelTargeting() {
    if (_activeSkillId != null) {
      _activeSkillId = null;
      notifyListeners();
    }
  }

  void continueAfterWin() {
    _hasSeenWin = true;
    _status = GameStatus.playing;
    notifyListeners();
  }

  void _spawnTile() {
    final emptyCells = <(int, int)>[];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (_board[r][c] == null) emptyCells.add((r, c));
      }
    }
    if (emptyCells.isEmpty) return;

    final cell = emptyCells[_random.nextInt(emptyCells.length)];
    final value = _spawnConfig.nextValue(_random);
    final tileType = _pickTileType();

    _board[cell.$1][cell.$2] = Tile(
      value: value,
      row: cell.$1,
      col: cell.$2,
      isNew: true,
      tileType: tileType,
      frozenTurns: tileType == TileType.ice ? 3 : (tileType == TileType.lock ? 8 : 0),
    );
  }

  TileType _randomArrow() {
    const arrows = [TileType.arrowLeft, TileType.arrowRight, TileType.arrowUp, TileType.arrowDown];
    return arrows[_random.nextInt(4)];
  }

  /// 아이템 모드에서 특수 타일 타입 랜덤 결정
  /// 노멀/스피드 모드에서는 항상 normal 반환
  TileType _pickTileType() {
    if (_gameMode != GameMode.item) return TileType.normal;

    final roll = _random.nextDouble();
    if (roll < 0.06) return TileType.golden; // 6%
    if (roll < 0.10) return TileType.bomb;   // 4%
    if (roll < 0.13) return TileType.ice;    // 3%
    if (roll < 0.16) return TileType.wild;   // 3%
    if (roll < 0.19) return TileType.lock;   // 3%
    if (roll < 0.22) return _randomArrow();  // 3%
    return TileType.normal;                   // 78%
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    super.dispose();
  }
}
