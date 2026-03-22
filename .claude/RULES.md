# 코드 작성 규칙

## 1. 상태관리 규칙

### Provider 사용 원칙
- 모든 `ChangeNotifierProvider`는 `main.dart`의 `MultiProvider`에서만 생성
- 화면(Screen) 위젯 내부에 `ChangeNotifierProvider` 절대 금지
- 상태 **읽기**: `context.watch<T>()` (리빌드 필요), `context.read<T>()` (액션 호출)
- `setState`로 Provider가 관리해야 할 상태를 절대 관리하지 말 것

### Controller 원칙
- Controller는 `package:flutter/material.dart` import 금지 (foundation.dart만 허용)
- `BuildContext`를 Controller/Logic 레이어에 전달 금지
- `notifyListeners()`는 상태 변경이 완료된 후 마지막에 1번만 호출

---

## 2. 모델 규칙

- `Tile` 클래스의 모든 필드는 반드시 `final` (immutable)
- 상태 변경은 오직 `copyWith()`를 통해서만
- 보드의 어떤 변경도 반드시 `GameController._pushHistory()` 후 수행

---

## 3. 테마 규칙

- Flutter `ThemeData`와 게임 `GameThemeData`는 완전히 별개 시스템
- 위젯에서 색상/스타일 참조: `context.watch<ThemeController>().theme.xxx`
- 하드코딩된 `Color(0xFFxxxxxx)` 값 위젯에 직접 작성 금지
- 새 테마 추가 방법:
  1. `lib/core/theme/themes/` 에 `xxx_theme.dart` 파일 생성
  2. `lib/core/theme/theme_registry.dart` 에 등록 1줄 추가

---

## 4. 스킬 규칙

- 새 스킬은 `Skill` 추상 클래스를 구현하는 파일 1개 추가
- `GameController`에 스킬별 메서드 추가 금지 (ex: `removeTile()`, `upgradeTile()`)
- `SkillInventory`는 `GameController` 내부에 포함 (별도 ChangeNotifier 금지)
- 스킬의 보드 변환 로직은 순수 함수로 작성 (`Skill.apply()`)

---

## 5. 절대 금지 패턴

| 금지 | 이유 | 대안 |
|------|------|------|
| `_board[r][c].row = r` | Tile이 immutable | `tile.copyWith(row: r, col: c)` |
| Controller에 `BuildContext` 전달 | 레이어 위반 | 필요한 값만 파라미터로 전달 |
| 보드 상태를 JSON으로 SharedPreferences 저장 | 직렬화 복잡, 취약 | 메모리만 사용, 요약 데이터만 영속 |
| `SkillInventory`를 ChangeNotifier로 | 이중 notify 버그 | GameController 내부 포함 |
| 구체 스킬 클래스를 위젯에서 직접 import | 결합도 증가 | 추상 `Skill` 타입 사용 |
| Screen 위젯 내부에 Provider 생성 | 화면 이탈 시 소멸 | main.dart MultiProvider |

---

## 6. 네이밍 규칙

- 파일명: `snake_case.dart`
- 클래스명: `PascalCase`
- private 멤버: `_camelCase`
- 상수: `camelCase` (Dart 관례)
- 테마 ID: 소문자 `snake_case` 문자열 (ex: `'dark_neon'`, `'forest'`)
- 스킬 ID: 소문자 `snake_case` 문자열 (ex: `'remove_tile'`, `'upgrade_tile'`)
