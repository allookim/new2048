import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tile.dart';
import '../models/game_state.dart';
import '../skills/skill.dart';
import '../skills/skill_inventory.dart';
import '../skills/skill_registry.dart';
import 'board_logic.dart';
import 'board_snapshot.dart';
import 'spawn_config.dart';

class GameController extends ChangeNotifier {
  static const String _bestScoreKey = 'best_score';
  static const int _maxHistorySize = 5;

  List<List<Tile?>> _board = List.generate(4, (_) => List.filled(4, null));
  int _score = 0;
  int _bestScore = 0;
  GameStatus _status = GameStatus.playing;
  bool _hasSeenWin = false;
  final Random _random = Random();
  final List<BoardSnapshot> _history = [];
  SpawnConfig _spawnConfig = const SpawnConfig();

  // Skill system
  late SkillInventory _skillInventory;
  String? _activeSkillId;

  List<List<Tile?>> get board => _board;
  int get score => _score;
  int get bestScore => _bestScore;
  GameStatus get status => _status;
  bool get canUndo => _history.isNotEmpty;
  SkillInventory get skillInventory => _skillInventory;
  String? get activeSkillId => _activeSkillId;
  bool get isTargeting => _activeSkillId != null;

  static List<Skill> get defaultSkills => defaultSkillSet;

  GameController() {
    _skillInventory = SkillInventory(defaultSkills);
    _loadBestScore().then((_) => newGame());
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt(_bestScoreKey) ?? 0;
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, _bestScore);
  }

  void _pushHistory() {
    _history.add(BoardSnapshot.capture(_board, _score, _status));
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
  }

  void undo() {
    if (_history.isEmpty) return;
    final snapshot = _history.removeLast();
    _board = snapshot.board;
    _score = snapshot.score;
    _status = snapshot.status;
    _activeSkillId = null;
    notifyListeners();
  }

  /// 외부(스킬 등)에서 스폰 설정을 변경할 때 사용
  void setSpawnConfig(SpawnConfig config) {
    _spawnConfig = config;
  }

  void resetSpawnConfig() {
    _spawnConfig = const SpawnConfig();
  }

  void newGame() {
    _board = List.generate(4, (_) => List.filled(4, null));
    _score = 0;
    _status = GameStatus.playing;
    _hasSeenWin = false;
    _history.clear();
    _skillInventory = SkillInventory(defaultSkills);
    _activeSkillId = null;
    _spawnConfig = const SpawnConfig();
    _spawnTile();
    _spawnTile();
    notifyListeners();
  }

  void move(Direction direction) {
    if (_status == GameStatus.gameOver) return;
    if (isTargeting) {
      _activeSkillId = null;
      notifyListeners();
      return;
    }

    final result = applyMove(_board, direction);
    if (!result.didChange) return;

    _pushHistory();

    _board = result.board;
    _score += result.scoreGained;

    if (_score > _bestScore) {
      _bestScore = _score;
      _saveBestScore();
    }

    _spawnTile();

    if (!_hasSeenWin && hasWon(_board)) {
      _status = GameStatus.won;
    } else if (isGameOver(_board)) {
      _status = GameStatus.gameOver;
    }

    notifyListeners();
  }

  /// Activate a skill. For targeted skills, enters targeting mode.
  void activateSkill(String skillId) {
    if (_status == GameStatus.gameOver) return;

    final skill = _skillInventory.getSkill(skillId);
    if (skill == null) return;
    if (!_skillInventory.canUse(skillId)) return;
    if (!skill.canUse(_board, _score)) return;

    if (skill.requiresTarget) {
      // Toggle targeting: tap same skill again to cancel
      if (_activeSkillId == skillId) {
        _activeSkillId = null;
      } else {
        _activeSkillId = skillId;
      }
      notifyListeners();
    }
  }

  /// Apply a targeted skill to a specific tile.
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
    _board[cell.$1][cell.$2] = Tile(
      value: value,
      row: cell.$1,
      col: cell.$2,
      isNew: true,
    );
  }
}
