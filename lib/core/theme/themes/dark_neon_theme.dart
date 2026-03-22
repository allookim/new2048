import 'package:flutter/material.dart';
import '../game_theme_data.dart';

const darkNeonTheme = GameThemeData(
  id: 'dark_neon',
  displayName: 'Dark Neon',
  backgroundColor: Color(0xFF1A1A2E),
  boardColor: Color(0xFF16213E),
  cellColor: Color(0xFF0F3460),
  textDark: Color(0xFFE94560),
  textLight: Color(0xFFF1F1F1),
  scoreBackground: Color(0xFF16213E),
  buttonColor: Color(0xFFE94560),
  winOverlayColor: Color(0xFF533483),
  overlayTextColor: Color(0xFFF1F1F1),
  tileColors: {
    2: Color(0xFF0F3460),
    4: Color(0xFF16213E),
    8: Color(0xFFE94560),
    16: Color(0xFFFC5185),
    32: Color(0xFF533483),
    64: Color(0xFF6C63FF),
    128: Color(0xFF00D2D3),
    256: Color(0xFF01CBC6),
    512: Color(0xFF1DD1A1),
    1024: Color(0xFFFECA57),
    2048: Color(0xFFFF6B6B),
  },
  tileTextColors: {
    2: Color(0xFF00D2D3),
    4: Color(0xFF00D2D3),
  },
  // Dark Neon: 더 빠르고 강렬한 merge 이펙트
  animationConfig: TileAnimationConfig(
    mergeDuration: Duration(milliseconds: 120),
    mergeScalePeak: 1.3,
    spawnDuration: Duration(milliseconds: 100),
    moveDuration: Duration(milliseconds: 90),
  ),
);
