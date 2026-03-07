import 'package:shared_preferences/shared_preferences.dart';

import '../themes/app_themes.dart';

// KI-Prompt: "Erstelle einen ThemePrefsService, der das ausgewählte Theme speichert und mit SharedPreference arbeitet.

class ThemePrefsService {
  static const String _keySelectedTheme = 'selected_theme';

  static Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTheme, theme.name);
  }

  static Future<AppTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keySelectedTheme);

    if (value == null) return AppTheme.system;

    return AppTheme.values.firstWhere(
      (t) => t.name == value,
      orElse: () => AppTheme.system,
    );
  }
}

