import 'package:flutter/material.dart';
import '../game_theme_data.dart';

const basicTheme = GameThemeData(
  id: 'basic',
  displayName: 'Basic',
  fontFamily: 'Nunito',
  backgroundColor: Color(0xFF0a1e4a),
  boardColor: Color(0xFF0d2560),
  cellColor: Color(0xFF1a3580),
  textDark: Color(0xFFFFFFFF),
  textLight: Color(0xFFFFFFFF),
  scoreBackground: Color(0xFF0d2560),
  buttonColor: Color(0xFF41357b),
  winOverlayColor: Color(0xFF0d2560),
  overlayTextColor: Color(0xFFFFFFFF),
  boardPadding: 12.0,
  gap: 10.0,
  boardRadius: 16.0,
  tileRadius: 14.0,
  tileColors: {
    2: Color(0xFF6cded0),
    4: Color(0xFF5BC9BC),
    8: Color(0xFFC36CEB),
    16: Color(0xFFB05AE0),
    32: Color(0xFFE05A2A),
    64: Color(0xFFD0401A),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  },
  tileTextColors: {
    2: Color(0xFFFFFFFF),
    4: Color(0xFFFFFFFF),
  },
);
