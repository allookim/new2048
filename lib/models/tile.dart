import 'package:uuid/uuid.dart';

/// 특수 타일 종류 (아이템 게임 전용)
enum TileType {
  normal,     // 일반 타일
  golden,     // 황금 타일: 합쳐질 때 점수 ×2
  bomb,       // 폭탄 타일: 합쳐질 때 주변 타일 제거
  ice,        // 얼음 타일: 이동은 되지만 합쳐지지 않음
  wild,       // 와일드 타일: 어떤 값과도 합쳐짐
  lock,       // 잠금 타일: 위치 고정 + 머지 불가
  arrowLeft,  // 화살표 타일 ←: 왼쪽 스와이프 시 해당 행 왼쪽 끝까지 최댓값으로 수렴
  arrowRight, // 화살표 타일 →: 오른쪽 스와이프 시 해당 행 오른쪽 끝까지 최댓값으로 수렴
  arrowUp,    // 화살표 타일 ↑: 위쪽 스와이프 시 해당 열 위쪽 끝까지 최댓값으로 수렴
  arrowDown,  // 화살표 타일 ↓: 아래쪽 스와이프 시 해당 열 아래쪽 끝까지 최댓값으로 수렴
}

class Tile {
  final String id;
  final int value;
  final int row;
  final int col;
  final bool isNew;
  final bool isMerged;
  final TileType tileType;

  /// 얼음 타일 전용: 해동까지 남은 턴 수 (3→2→1→0에서 일반 타일로 전환)
  final int frozenTurns;

  Tile({
    String? id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.isMerged = false,
    this.tileType = TileType.normal,
    this.frozenTurns = 0,
  }) : id = id ?? const Uuid().v4();

  Tile copyWith({
    int? value,
    int? row,
    int? col,
    bool? isNew,
    bool? isMerged,
    TileType? tileType,
    int? frozenTurns,
  }) {
    return Tile(
      id: id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
      tileType: tileType ?? this.tileType,
      frozenTurns: frozenTurns ?? this.frozenTurns,
    );
  }
}
