import 'package:flutter/material.dart';
import '../game_theme_data.dart';

/// PICO-8 / NES 팔레트에서 영감을 받은 픽셀 아트 테마.
/// - 날카로운 모서리 (tileRadius = 0)
/// - 비트맵 폰트 숫자
/// - 머지 시 도트 파티클 이펙트
final GameThemeData pixelTheme = const GameThemeData(
  id: 'pixel',
  displayName: 'PIXEL',
  isPixelStyle: true,

  // ── 배경 ───────────────────────────────────────────
  backgroundColor: Color(0xFF0D0D1A),
  boardColor: Color(0xFF2A2A4A),   // 버튼에 사용 → 배경과 구분
  cellColor: Color(0xFF1C1C3A),
  scoreBackground: Color(0xFF1C1C3A),

  // ── 텍스트 / 버튼 ──────────────────────────────────
  // 어두운 배경이므로 textDark도 밝은 색으로
  textDark: Color(0xFFF7F7F0),
  textLight: Color(0xFFF7F7F0),
  buttonColor: Color(0xFF29ADFF),
  winOverlayColor: Color.fromRGBO(29, 43, 83, 0.92),
  overlayTextColor: Color(0xFFFFEC27),

  // ── 타일 색상 (PICO-8 팔레트) ─────────────────────
  tileColors: {
    2: Color(0xFF8A8070),   // 더 밝은 회갈색
    4: Color(0xFF9B8FBD),   // 더 밝은 라벤더
    8: Color(0xFF29ADFF),
    16: Color(0xFF00E436),
    32: Color(0xFFFFEC27),
    64: Color(0xFFFFA300),
    128: Color(0xFFFF004D),
    256: Color(0xFFFF77A8),
    512: Color(0xFF7E2553),
    1024: Color(0xFFAB5236),
    2048: Color(0xFFFFF1E8),
  },

  // ── 타일별 텍스트 색상 ────────────────────────────
  tileTextColors: {
    2: Color(0xFF0D0D1A),
    4: Color(0xFF0D0D1A),
    2048: Color(0xFF0D0D1A),
  },

  // ── 지오메트리: 픽셀 아트 = 날카로운 모서리 ──────
  boardPadding: 10.0,
  gap: 6.0,
  boardRadius: 0.0,
  tileRadius: 0.0,

  // ── 애니메이션 ────────────────────────────────────
  animationConfig: TileAnimationConfig(
    mergeDuration: Duration(milliseconds: 220),
    mergeScalePeak: 1.18,
    spawnDuration: Duration(milliseconds: 160),
    moveDuration: Duration(milliseconds: 110),
  ),

  isDefault: false,
  isPremium: false,
);
