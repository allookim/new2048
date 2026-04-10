import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_theme_data.dart';
import 'theme_registry.dart';
import 'themes/classic_theme.dart';
import 'themes/sea_theme.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'active_theme';

  GameThemeData _currentTheme = seaTheme;
  String _currentThemeId = 'sea';
  final Set<String> _unlockedThemes = {'classic', 'dark_neon', 'pixel', 'basic', 'sea'};

  GameThemeData get theme => _currentTheme;
  String get currentThemeId => _currentThemeId;
  Map<String, GameThemeData> get availableThemes => themeRegistry;
  Set<String> get unlockedThemes => Set.unmodifiable(_unlockedThemes);

  ThemeController() {
    _loadSavedTheme();
  }

  bool isUnlocked(String themeId) => _unlockedThemes.contains(themeId);

  void unlockTheme(String themeId) {
    _unlockedThemes.add(themeId);
    notifyListeners();
  }

  void switchTheme(String themeId) {
    final theme = themeRegistry[themeId];
    if (theme == null) return;
    if (!_unlockedThemes.contains(themeId)) return;

    _currentTheme = theme;
    _currentThemeId = themeId;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_themeKey);
    if (savedId != null && themeRegistry.containsKey(savedId) && _unlockedThemes.contains(savedId)) {
      _currentTheme = themeRegistry[savedId]!;
      _currentThemeId = savedId;
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _currentThemeId);
  }
}
