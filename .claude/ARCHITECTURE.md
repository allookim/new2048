# 아키텍처 문서

## 현재 폴더 구조 (Phase 1 완료 상태)

```
lib/
├── main.dart                          # 앱 진입점, MultiProvider 설정
│
├── core/
│   └── theme/
│       ├── game_theme_data.dart       # 테마 데이터 클래스 (colors, geometry, metadata)
│       ├── theme_controller.dart      # ChangeNotifier - 현재 테마, 전환, 영속성
│       ├── theme_registry.dart        # 모든 테마 등록소 { id: GameThemeData }
│       └── themes/
│           ├── classic_theme.dart     # 기존 2048 디자인
│           └── dark_neon_theme.dart   # 어두운 네온 디자인
│
├── game/
│   ├── board_logic.dart              # 순수 함수: applyMove, slideLineLeft, isGameOver, hasWon
│   ├── game_controller.dart          # ChangeNotifier - 보드, 점수, 히스토리, 스킬
│   ├── move_result.dart              # 데이터 클래스: newBoard, scoreGained, didChange
│   ├── board_snapshot.dart           # Undo용 스냅샷: board deepcopy + score + status
│   └── (예정) spawn_config.dart      # 스폰 확률 설정 (스킬 확장 시 필요)
│
├── models/
│   ├── tile.dart                     # Tile (immutable): id, value, row, col, isNew, isMerged
│   └── game_state.dart               # GameStatus enum: playing, won, gameOver
│
├── skills/
│   ├── skill.dart                    # abstract Skill: id, name, icon, canUse(), apply()
│   ├── skill_result.dart             # 데이터 클래스: newBoard, scoreChange, wasApplied
│   ├── skill_inventory.dart          # 세션별 사용 횟수 관리
│   └── implementations/
│       ├── remove_tile_skill.dart    # 타일 제거 (x2/게임)
│       └── upgrade_tile_skill.dart   # 타일 업그레이드 2배 (x1/게임)
│
├── screens/
│   ├── main_menu_screen.dart         # 메인 메뉴: Play, Themes
│   ├── game_screen.dart              # 게임: ScorePanel + GameBoard + SkillBar
│   └── theme_screen.dart            # 테마 선택 그리드
│
└── widgets/
    ├── game_board.dart               # 보드 렌더링 + 입력 처리 + 타겟팅 모드
    ├── tile_widget.dart              # 타일 + scale 애니메이션
    ├── score_panel.dart              # 점수 + BEST + Undo/New 버튼
    ├── game_over_overlay.dart        # 게임오버 오버레이
    ├── win_overlay.dart              # 승리 오버레이
    ├── skill_bar.dart                # 스킬 버튼들 (아이콘 + 남은 횟수)
    ├── theme_preview_card.dart       # 테마 미리보기 카드
    └── menu_button.dart              # 메뉴 버튼 공통 위젯
```

---

## 레이어 구조

```
UI Layer (screens/, widgets/)
  - context.watch<T>()  →  Provider 읽기 (리빌드 포함)
  - context.read<T>()   →  메서드 호출 (리빌드 없음)
        ↕
Controller Layer (ChangeNotifiers)
  - GameController  : 보드 상태, 점수, undo, 스킬
  - ThemeController : 현재 테마, 전환, 잠금 해제
        ↕
Logic Layer (순수 함수, Flutter 무관)
  - board_logic.dart : applyMove, slideLineLeft, isGameOver, hasWon
  - Skill.apply()    : 보드 변환 순수 함수
        ↕
Data Layer (영속성)
  - SharedPreferences : bestScore, activeThemeId
  - (Phase 2) Supabase : user profile, cloud sync
```

---

## 핵심 데이터 흐름

### 이동 처리
```
GameBoard.onPanEnd / onKeyEvent
  → GameController.move(direction)
    → _pushHistory()                 # 현재 상태 스냅샷
    → board_logic.applyMove()        # 순수 함수
    → _board, _score 업데이트
    → _spawnTile()                   # 새 타일 스폰
    → 승패 판정
    → notifyListeners()
  → UI 리빌드
```

### 스킬 사용 (타겟팅 필요)
```
SkillBar.onTap(skillId)
  → GameController.activateSkill()  # _activeSkillId 설정
  → notifyListeners()               # GameBoard가 타겟팅 모드로 전환

GameBoard.onTap(tile)               # 타겟팅 모드에서 타일 탭
  → GameController.applyTargetedSkill(row, col)
    → _pushHistory()
    → skill.apply()                 # 순수 함수
    → _board, _score 업데이트
    → _skillInventory.use(skillId)
    → _activeSkillId = null
    → notifyListeners()
```

### 테마 전환
```
ThemeScreen.ThemePreviewCard.onTap
  → ThemeController.switchTheme(themeId)
    → _currentTheme 업데이트
    → SharedPreferences 저장
    → notifyListeners()
  → 모든 context.watch<ThemeController>() 위젯 리빌드
```

---

## GameThemeData 구조

```dart
class GameThemeData {
  final String id;                    // 'classic', 'dark_neon'
  final String displayName;
  final Color backgroundColor;
  final Color boardColor;
  final Color cellColor;
  final Color textDark;
  final Color textLight;
  final Color scoreBackground;
  final Color buttonColor;
  final Color winOverlayColor;
  final Color overlayTextColor;
  final Map<int, Color> tileColors;   // value → color
  final Map<int, Color>? tileTextColors;
  final double boardPadding;          // default 12.0
  final double gap;                   // default 8.0
  final double boardRadius;           // default 8.0
  final double tileRadius;            // default 6.0
  final bool isDefault;
  final bool isPremium;
  final int? unlockCost;
}
```

## Skill 구조

```dart
abstract class Skill {
  String get id;
  String get name;
  String get description;
  IconData get icon;
  int get maxUsesPerGame;
  bool get requiresTarget;
  bool canUse(List<List<Tile?>> board, int score);
  SkillResult apply(board, score, {int? targetRow, int? targetCol});
}
```
