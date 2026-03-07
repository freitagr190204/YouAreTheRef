import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import 'models/scene.dart';
import 'screens/decision_result_screen.dart';
import 'screens/home_screen.dart';
import 'screens/score_screen.dart';
import 'screens/scenario_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/history_screen.dart';
import 'screens/highscore_screen.dart';
import 'services/api_service.dart';
import 'services/theme_prefs_service.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(390, 844), 
        minimumSize: Size(390, 844),
        maximumSize: Size(390, 844),
        center: true,
        title: "You Are The Ref - Mockup Mode",
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  runApp(const YouAreTheRefApp());
}

class YouAreTheRefApp extends StatefulWidget {
  const YouAreTheRefApp({super.key});

  @override
  State<YouAreTheRefApp> createState() => _YouAreTheRefAppState();
}

class _YouAreTheRefAppState extends State<YouAreTheRefApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final TextEditingController _nameController = TextEditingController();
  
  List<Scene> _scenes = [];
  int _currentSceneIndex = 0;
  int _correctCount = 0;
  String? _userDecision;
  String _playerName = "Schiri";
  int _currentDifficulty = 1;
  AppTheme _currentTheme = AppTheme.system;
  bool _isLoadingScenes = false;
  bool _roundAlreadySaved = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final theme = await ThemePrefsService.loadTheme();
    setState(() => _currentTheme = theme);
  }

  Future<void> _loadScenes({int? difficulty}) async {
    final diff = difficulty ?? _currentDifficulty;
    setState(() => _isLoadingScenes = true);
    try {
      final scenes = await ApiService.fetchScenes(difficulty: diff);
      setState(() {
        _scenes = scenes;
        _currentSceneIndex = 0;
        _correctCount = 0;
        _currentDifficulty = diff;
        _roundAlreadySaved = false;
      });
    } catch (e) {
      debugPrint("Fehler beim Laden: $e");
      final ctx = _navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text(
              'Szenen konnten nicht geladen werden. '
              'Bitte Backend (npm start im backend-Ordner) prüfen.',
            ),
          ),
        );
      }
      setState(() {
        _scenes = [];
        _currentSceneIndex = 0;
        _correctCount = 0;
      });
    } finally {
      setState(() => _isLoadingScenes = false);
    }
  }

  void _showNameDialog() {
    int tempDifficulty = _currentDifficulty;

    showDialog(
      context: _navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: const Text('Spielstart'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name für Highscore",
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Schwierigkeit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: tempDifficulty,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Leicht')),
                    DropdownMenuItem(value: 2, child: Text('Mittel')),
                    DropdownMenuItem(value: 3, child: Text('Schwer')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setLocalState(() => tempDifficulty = value);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  setState(() {
                    _playerName =
                        _nameController.text.isEmpty ? "Anonym" : _nameController.text;
                    _currentDifficulty = tempDifficulty;
                  });
                  Navigator.pop(context);
                  await _loadScenes(difficulty: tempDifficulty);
                  _startGame();
                },
                child: const Text('Start'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startGame() {
    if (_scenes.isEmpty) return;
    _navigatorKey.currentState?.pushNamed(ScenarioScreen.routeName);
  }

  void _finishGame() async {
    if (_roundAlreadySaved) return;
    _roundAlreadySaved = true;

    try {
      await ApiService.postRoundResult(
        _scenes.length,
        _correctCount,
        _playerName,
        difficulty: _currentDifficulty,
      );
    } catch (e) {
      debugPrint('Runde konnte nicht gespeichert werden: $e');
    }
    if (!mounted) return;
    _navigatorKey.currentState?.pushReplacementNamed(ScoreScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.themeDataFrom(_currentTheme),
      themeMode: AppThemes.themeModeFrom(_currentTheme),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(
          onStartGame: _showNameDialog,
          onOpenSettings: () => _navigatorKey.currentState?.pushNamed(SettingsScreen.routeName),
          onOpenHistory: () => _navigatorKey.currentState?.pushNamed(HistoryScreen.routeName),
          onOpenHighscore: () => _navigatorKey.currentState?.pushNamed(HighscoreScreen.routeName),
        ),
        ScenarioScreen.routeName: (context) {
          if (_scenes.isEmpty || _currentSceneIndex < 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigatorKey.currentState?.popUntil((r) => r.isFirst);
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (_currentSceneIndex >= _scenes.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _finishGame());
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return ScenarioScreen(
            scene: _scenes[_currentSceneIndex],
            sceneNumber: _currentSceneIndex + 1,
            totalScenes: _scenes.length,
            onDecision: (decision) {
              final bool isCorrect = decision == _scenes[_currentSceneIndex].correctDecision;
              setState(() {
                _userDecision = decision;
                if (isCorrect) _correctCount++;
              });
              _navigatorKey.currentState?.pushNamed(DecisionResultScreen.routeName);
            },
          );
        },
        DecisionResultScreen.routeName: (context) {
          if (_scenes.isEmpty || _currentSceneIndex < 0 || _userDecision == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigatorKey.currentState?.popUntil((r) => r.isFirst);
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (_currentSceneIndex >= _scenes.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _finishGame());
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return DecisionResultScreen(
            scene: _scenes[_currentSceneIndex],
            sceneNumber: _currentSceneIndex + 1,
            userDecision: _userDecision!,
            onNextScene: () {
              setState(() => _currentSceneIndex++);
              if (_currentSceneIndex < _scenes.length) {
                _navigatorKey.currentState?.pushReplacementNamed(ScenarioScreen.routeName);
              } else {
                _finishGame();
              }
            },
          );
        },
        ScoreScreen.routeName: (context) => ScoreScreen(
          totalScenes: _scenes.length,
          correctDecisions: _correctCount,
          onNewGame: () {
            _showNameDialog();
          },
          onBackToMenu: () => _navigatorKey.currentState?.popUntil((r) => r.isFirst),
        ),
        SettingsScreen.routeName: (context) => SettingsScreen(
          currentTheme: _currentTheme,
          onThemeChanged: (theme) {
            setState(() => _currentTheme = theme);
            ThemePrefsService.saveTheme(theme);
          },
        ),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
        HighscoreScreen.routeName: (context) => const HighscoreScreen(),
      },
    );
  }
}