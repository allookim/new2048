import 'package:flutter/material.dart';
import '../game_theme_data.dart';

const classicTheme = GameThemeData(
  id: 'classic',
  displayName: 'Classic',
  isDefault: true,
  backgroundColor: Color(0xFFFAF8EF),
  boardColor: Color(0xFFBBADA0),
  cellColor: Color(0xFFCDC1B4),
  textDark: Color(0xFF776E65),
  textLight: Color(0xFFF9F6F2),
  scoreBackground: Color(0xFFBBADA0),
  buttonColor: Color(0xFF8F7A66),
  winOverlayColor: Color(0xFFEDC22E),
  overlayTextColor: Color(0xFFF9F6F2),
  tileColors: {
    2: Color(0xFFEEE4DA),
    4: Color(0xFFEDE0C8),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  },
);
