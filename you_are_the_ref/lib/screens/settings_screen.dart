import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

// KI-Prompt: "Erstelle einen Themes-Screen, auf dem man zwischen 5 Themes (Weiß, Schwarz, System, Grün, Gelb) auswählen kann.

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  final AppTheme currentTheme;
  final ValueChanged<AppTheme> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themes = AppTheme.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView.builder(
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final theme = themes[index];
          final selected = theme == currentTheme;

          return RadioListTile<AppTheme>(
            title: Text(AppThemes.displayName(theme)),
            value: theme,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                onThemeChanged(value);
              }
            },
            secondary:
                selected ? const Icon(Icons.check, color: Colors.green) : null,
          );
        },
      ),
    );
  }
}

