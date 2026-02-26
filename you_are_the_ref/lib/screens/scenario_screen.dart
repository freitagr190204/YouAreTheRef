import 'package:flutter/material.dart';
import '../models/scene.dart';
import '../widgets/scene_image.dart';

class ScenarioScreen extends StatelessWidget {
  static const String routeName = '/scenario';
  final Scene scene;
  final int sceneNumber;
  final int totalScenes;
  final ValueChanged<String> onDecision;

  const ScenarioScreen({
    super.key, 
    required this.scene, 
    required this.sceneNumber, 
    required this.totalScenes, 
    required this.onDecision
  });

  @override
  Widget build(BuildContext context) {
    double progress = sceneNumber / totalScenes;

    return Scaffold(
      appBar: AppBar(
        title: Text('Frage $sceneNumber von $totalScenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            tooltip: 'Abbrechen',
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SceneImage(imagePath: scene.imagePath, showVarOverlay: true),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text('Was ist deine Entscheidung?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => onDecision('Foul'),
                    icon: const Icon(Icons.flag),
                    label: const Text('FOUL', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () => onDecision('Kein Foul'),
                    icon: const Icon(Icons.check),
                    label: const Text('KEIN FOUL', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}