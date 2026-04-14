import 'game_theme_data.dart';
import 'themes/basic_theme.dart';
import 'themes/sea_theme.dart';
import 'themes/dark_neon_theme.dart';
import 'themes/pixel_theme.dart';

final Map<String, GameThemeData> themeRegistry = {
  basicTheme.id: basicTheme,
  seaTheme.id: seaTheme,
  darkNeonTheme.id: darkNeonTheme,
  pixelTheme.id: pixelTheme,
};
