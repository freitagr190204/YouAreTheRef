import 'package:flutter/foundation.dart';
import '../models/scene.dart';
import '../services/api_service.dart';

// KI-Prompt: Erstelle mir eine Klasse GameProvider, welche alle Spieldaten verwaltet.

class GameProvider extends ChangeNotifier {
  List<Scene> _scenes = [];
  int _currentSceneIndex = 0;
  int _correctCount = 0;
  String? _userDecision;
  String _playerName = 'Schiri';
  int _currentDifficulty = 1;
  bool _isLoadingScenes = false;
  bool _roundAlreadySaved = false;

  List<Scene> get scenes => _scenes;
  int get currentSceneIndex => _currentSceneIndex;
  int get correctCount => _correctCount;
  String? get userDecision => _userDecision;
  String get playerName => _playerName;
  int get currentDifficulty => _currentDifficulty;
  bool get isLoadingScenes => _isLoadingScenes;
  bool get roundAlreadySaved => _roundAlreadySaved;

  Scene? get currentScene {
    if (_scenes.isEmpty || _currentSceneIndex < 0 || _currentSceneIndex >= _scenes.length) {
      return null;
    }
    return _scenes[_currentSceneIndex];
  }

  bool get hasNextScene => _currentSceneIndex + 1 < _scenes.length;
  bool get isGameFinished => _scenes.isNotEmpty && _currentSceneIndex >= _scenes.length;

  void setPlayerName(String name) {
    _playerName = name.isEmpty ? 'Anonym' : name;
    notifyListeners();
  }

  void setDifficulty(int difficulty) {
    _currentDifficulty = difficulty;
    notifyListeners();
  }

  Future<void> loadScenes({int? difficulty}) async {
    // KI-Prompt: Erstelle die Methode loadScenes.
    final diff = difficulty ?? _currentDifficulty;
    _isLoadingScenes = true;
    _roundAlreadySaved = false;
    notifyListeners();
    try {
      final list = await ApiService.fetchScenes(difficulty: diff);
      _scenes = list;
      _currentSceneIndex = 0;
      _correctCount = 0;
      _userDecision = null;
      _currentDifficulty = diff;
      notifyListeners();
    } catch (e) {
      debugPrint('Fehler beim Laden: $e');
    } finally {
      _isLoadingScenes = false;
      notifyListeners();
    }
  }

  void setDecision(String decision) {
    _userDecision = decision;
    if (currentScene != null && decision == currentScene!.correctDecision) {
      _correctCount++;
    }
    notifyListeners();
  }

  void nextScene() {
    _currentSceneIndex++;
    _userDecision = null;
    notifyListeners();
  }

  Future<void> finishGame() async {
    // KI-Prompt: Jede Runde darf nur einmal gespeichert werden, ändere die Methode so dass es funktioniert.
    if (_roundAlreadySaved) return;
    _roundAlreadySaved = true;
    notifyListeners();
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
    notifyListeners();
  }

  void resetForNewGame() {
    _userDecision = null;
    notifyListeners();
  }
}
