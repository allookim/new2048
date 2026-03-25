import 'package:flutter/material.dart';

/// 타일 애니메이션 설정.
/// 테마마다 merge/spawn 이펙트를 다르게 설정할 수 있다.
class TileAnimationConfig {
  /// 병합 애니메이션 전체 길이
  final Duration mergeDuration;

  /// 병합 시 최대 scale 배율 (1.2 = 20% 커졌다 돌아옴)
  final double mergeScalePeak;

  /// 새 타일 등장 애니메이션 길이
  final Duration spawnDuration;

  /// 타일 이동 애니메이션 길이
  final Duration moveDuration;

  const TileAnimationConfig({
    this.mergeDuration = const Duration(milliseconds: 150),
    this.mergeScalePeak = 1.2,
    this.spawnDuration = const Duration(milliseconds: 150),
    this.moveDuration = const Duration(milliseconds: 120),
  });
}

class GameThemeData {
  final String id;
  final String displayName;

  // Colors
  final Color backgroundColor;
  final Color boardColor;
  final Color cellColor;
  final Color textDark;
  final Color textLight;
  final Color scoreBackground;
  final Color buttonColor;
  final Color winOverlayColor;
  final Color overlayTextColor;
  final Map<int, Color> tileColors;
  final Map<int, Color>? tileTextColors;

  // Typography
  final String? fontFamily;

  // Geometry
  final double boardPadding;
  final double gap;
  final double boardRadius;
  final double tileRadius;

  // Animation
  final TileAnimationConfig animationConfig;

  // Metadata
  final bool isDefault;
  final bool isPremium;
  final int? unlockCost;

  /// 픽셀 아트 스타일 렌더링 사용 여부
  final bool isPixelStyle;

  const GameThemeData({
    required this.id,
    required this.displayName,
    required this.backgroundColor,
    required this.boardColor,
    required this.cellColor,
    required this.textDark,
    required this.textLight,
    required this.scoreBackground,
    required this.buttonColor,
    required this.winOverlayColor,
    required this.overlayTextColor,
    required this.tileColors,
    this.tileTextColors,
    this.fontFamily,
    this.boardPadding = 12.0,
    this.gap = 12.0,
    this.boardRadius = 22.0,
    this.tileRadius = 14.0,
    this.animationConfig = const TileAnimationConfig(),
    this.isDefault = false,
    this.isPremium = false,
    this.unlockCost,
    this.isPixelStyle = false,
  });

  Color tileColor(int value) {
    return tileColors[value] ?? const Color(0xFF3C3A32);
  }

  Color tileTextColor(int value) {
    if (tileTextColors != null && tileTextColors!.containsKey(value)) {
      return tileTextColors![value]!;
    }
    return value <= 4 ? textDark : textLight;
  }

  double tileFontSize(int value, [double cellSize = 80.0]) {
    if (value < 16) return cellSize * 0.58;
    if (value < 128) return cellSize * 0.48;
    if (value < 1024) return cellSize * 0.38;
    return cellSize * 0.29;
  }

  double cellSize(double boardWidth) {
    return (boardWidth - 2 * boardPadding - 5 * gap) / 4;
  }

  double boardHeight(double boardWidth) {
    final cs = cellSize(boardWidth);
    return 4 * cs + 5 * gap + 2 * boardPadding;
  }

  double tileLeft(int col, double boardWidth) {
    return boardPadding + col * (cellSize(boardWidth) + gap) + gap;
  }

  double tileTop(int row, double boardWidth) {
    return boardPadding + row * (cellSize(boardWidth) + gap) + gap;
  }
}
