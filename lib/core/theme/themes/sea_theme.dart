import 'package:flutter/material.dart';
import '../game_theme_data.dart';

const seaTheme = GameThemeData(
  id: 'sea',
  displayName: 'Sea',
  fontFamily: 'Nunito',
  backgroundColor: Color(0xFF00b4e9),
  boardColor: Color(0x330099CC),
  cellColor: Color(0x44FFFFFF),
  textDark: Color(0xFFFFFFFF),
  textLight: Color(0xFFFFFFFF),
  scoreBackground: Color(0x44000000),
  buttonColor: Color(0xFF006494),
  winOverlayColor: Color(0xFF006494),
  overlayTextColor: Color(0xFFFFFFFF),
  boardPadding: 14.0,
  gap: 10.0,
  boardRadius: 16.0,
  tileRadius: 9999.0, // 원형 타일
  isCircleTile: true,
  backgroundAsset: 'assets/images/bg_sea.png',
  backgroundVideoAsset: 'assets/images/bg_sea.mp4',
  tileBgAsset: 'assets/tiles/Tile-sea-bg.png',
  tileFishAsset: 'assets/tiles/Tile-sea-bg-fish-1.png',
  tileColors: {
    2: Color(0x886cded0),
    4: Color(0x885BC9BC),
    8: Color(0x88F5A623),
    16: Color(0x88F08010),
    32: Color(0x88E05A2A),
    64: Color(0x88D0401A),
    128: Color(0x88EDCF72),
    256: Color(0x88EDCC61),
    512: Color(0x88EDC850),
    1024: Color(0x88EDC53F),
    2048: Color(0x88EDC22E),
  },
  tileTextColors: {
    2: Color(0xFFFFFFFF),
    4: Color(0xFFFFFFFF),
    8: Color(0xFFFFFFFF),
    16: Color(0xFFFFFFFF),
  },
  animationConfig: TileAnimationConfig(
    mergeScalePeak: 1.3,
  ),
);
