import 'package:flutter/material.dart';

// KI-Prompt: "Erstelle 5 Themes für die App (Weiß, Schwarz, System, Grün, Gelb).

enum AppTheme {
  light,
  dark,
  system,
  refGreen,
  refYellow,
}

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.deepPurple,
      secondary: Colors.amber,
    ),
  );

  static ThemeData refGreenTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.green[700],
    scaffoldBackgroundColor: const Color(0xFF1B5E20),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E7D32),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.green,
    ),
  );

  static ThemeData refYellowTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.yellow[700],
    scaffoldBackgroundColor: const Color(0xFFFFF9C4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFBC02D),
      foregroundColor: Colors.black,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.yellow,
      brightness: Brightness.light,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.yellow,
    ),
  );

  static ThemeData themeDataFrom(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return lightTheme;
      case AppTheme.dark:
        return darkTheme;
      case AppTheme.refGreen:
        return refGreenTheme;
      case AppTheme.refYellow:
        return refYellowTheme;
      case AppTheme.system:
        return lightTheme;
    }
  }

  static ThemeMode themeModeFrom(AppTheme theme) {
    switch (theme) {
      case AppTheme.system:
        return ThemeMode.system;
      case AppTheme.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  static String displayName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light Theme';
      case AppTheme.dark:
        return 'Dark Theme';
      case AppTheme.system:
        return 'System Theme';
      case AppTheme.refGreen:
        return 'Ref Green Theme';
      case AppTheme.refYellow:
        return 'Ref Yellow Theme';
    }
  }
}

