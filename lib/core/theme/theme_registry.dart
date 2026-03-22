import 'game_theme_data.dart';
import 'themes/classic_theme.dart';
import 'themes/dark_neon_theme.dart';

final Map<String, GameThemeData> themeRegistry = {
  classicTheme.id: classicTheme,
  darkNeonTheme.id: darkNeonTheme,
};
