import 'package:flutter/material.dart';

class ScoreScreen extends StatelessWidget {
  static const String routeName = '/score';
  final int totalScenes;
  final int correctDecisions;
  final VoidCallback onNewGame;
  final VoidCallback onBackToMenu;

  const ScoreScreen({super.key, required this.totalScenes, required this.correctDecisions, required this.onNewGame, required this.onBackToMenu});

  @override
  Widget build(BuildContext context) {
    final double quote = totalScenes == 0 ? 0 : (correctDecisions / totalScenes) * 100;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auswertung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Prüfung beendet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: quote / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Text(
                  '${quote.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('$correctDecisions von $totalScenes richtig gelöst'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onNewGame,
                child: const Text('Neuer Versuch'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: onBackToMenu,
                child: const Text('Zum Hauptmenü'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}