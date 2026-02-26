import 'package:flutter/material.dart';
import '../models/scene.dart';

class DecisionResultScreen extends StatelessWidget {
  static const String routeName = '/decisionResult';
  final Scene scene;
  final int sceneNumber;
  final String userDecision;
  final VoidCallback onNextScene;

  const DecisionResultScreen({
    super.key, 
    required this.scene, 
    required this.sceneNumber, 
    required this.userDecision, 
    required this.onNextScene
  });

  @override
  Widget build(BuildContext context) {
    final bool correct = userDecision == scene.correctDecision;
    
    return Scaffold(
      appBar: AppBar(title: Text('Ergebnis zu Frage $sceneNumber')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, val, child) => Transform.scale(
                scale: val,
                child: Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red, size: 100),
              ),
            ),
            const SizedBox(height: 10),
            Text(correct ? 'RICHTIG' : 'FALSCH', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: correct ? Colors.green : Colors.red)),
            const SizedBox(height: 30),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) => Opacity(
                opacity: val,
                child: Transform.translate(offset: Offset(0, 50 * (1 - val)), child: child),
              ),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Korrekte Entscheidung: ${scene.correctDecision}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Begründung (Schiri-Analyse)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const Divider(height: 12),
                      Text(
                        scene.explanation,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(onPressed: onNextScene, child: const Text('WEITER')),
            ),
          ],
        ),
      ),
    );
  }
}