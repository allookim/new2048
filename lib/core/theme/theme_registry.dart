import 'game_theme_data.dart';
import 'themes/basic_theme.dart';
import 'themes/classic_theme.dart';
import 'themes/dark_neon_theme.dart';
import 'themes/pixel_theme.dart';
import 'themes/sea_theme.dart';

final Map<String, GameThemeData> themeRegistry = {
  classicTheme.id: classicTheme,
  darkNeonTheme.id: darkNeonTheme,
  pixelTheme.id: pixelTheme,
  basicTheme.id: basicTheme,
  seaTheme.id: seaTheme,
};
