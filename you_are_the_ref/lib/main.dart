import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'models/scene.dart';
import 'providers/game_provider.dart';
import 'screens/decision_result_screen.dart';
import 'screens/home_screen.dart';
import 'screens/score_screen.dart';
import 'screens/scenario_screen.dart';

// KI-Prompt: Mache Szenen, aktuelle Frage, Punkte, Entscheidung, Name, Schwierigkeit mit dem Provider

// KI-Prompt: Navigation soll auch mit Dialoge und Provider funktionieren, also ohne BuildContext

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(390, 844),
      minimumSize: Size(390, 844),
      maximumSize: Size(390, 844),
      center: true,
      title: "You Are The Ref",
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'You Are The Ref',
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(
                onStartGame: _showNameDialog,
              ),
          ScenarioScreen.routeName: (context) => _buildScenarioRoute(context),
          DecisionResultScreen.routeName: (context) => _buildDecisionResultRoute(context),
          ScoreScreen.routeName: (context) => _buildScoreRoute(context),
        },
      ),
    );
  }

  void _showNameDialog() {
    final game = _navigatorKey.currentContext!.read<GameProvider>();
    int tempDifficulty = game.currentDifficulty;
    final nameController = TextEditingController();

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
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name für Highscore'),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Schwierigkeit', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    if (value != null) setLocalState(() => tempDifficulty = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  game.setPlayerName(nameController.text);
                  game.setDifficulty(tempDifficulty);
                  Navigator.pop(context);
                  await game.loadScenes(difficulty: tempDifficulty);
                  if (!context.mounted) return;
                  if (game.scenes.isNotEmpty) {
                    _navigatorKey.currentState?.pushNamed(ScenarioScreen.routeName);
                  }
                },
                child: const Text('Start'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScenarioRoute(BuildContext context) {
    final game = context.read<GameProvider>();
    if (game.scenes.isEmpty || game.currentSceneIndex < 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.popUntil((r) => r.isFirst);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (game.currentSceneIndex >= game.scenes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await game.finishGame();
        _navigatorKey.currentState?.pushReplacementNamed(ScoreScreen.routeName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final scene = game.currentScene!;
    return ScenarioScreen(
      scene: scene,
      sceneNumber: game.currentSceneIndex + 1,
      totalScenes: game.scenes.length,
      onDecision: (decision) {
        game.setDecision(decision);
        _navigatorKey.currentState?.pushNamed(DecisionResultScreen.routeName);
      },
    );
  }

  Widget _buildDecisionResultRoute(BuildContext context) {
    final game = context.read<GameProvider>();
    if (game.scenes.isEmpty || game.currentSceneIndex < 0 || game.userDecision == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.popUntil((r) => r.isFirst);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (game.currentSceneIndex >= game.scenes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await game.finishGame();
        _navigatorKey.currentState?.pushReplacementNamed(ScoreScreen.routeName);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final scene = game.currentScene!;
    return DecisionResultScreen(
      scene: scene,
      sceneNumber: game.currentSceneIndex + 1,
      userDecision: game.userDecision!,
      onNextScene: () {
        game.nextScene();
        if (game.currentSceneIndex < game.scenes.length) {
          _navigatorKey.currentState?.pushReplacementNamed(ScenarioScreen.routeName);
        } else {
          game.finishGame().then((_) {
            _navigatorKey.currentState?.pushReplacementNamed(ScoreScreen.routeName);
          });
        }
      },
    );
  }

  Widget _buildScoreRoute(BuildContext context) {
    final game = context.read<GameProvider>();
    return ScoreScreen(
      totalScenes: game.scenes.length,
      correctDecisions: game.correctCount,
      onNewGame: () => _showNameDialog(),
      onBackToMenu: () => _navigatorKey.currentState?.popUntil((r) => r.isFirst),
    );
  }
}
