import 'dart:ui';
import 'package:flutter/material.dart';

// KI-Prompt: Start-Screen mit Zidane Hintergrund und Buttons für Spielstart, Historie, Highscore und Einstellungen bauen.
class HomeScreen extends StatelessWidget {
  static const String routeName = '/';
  final VoidCallback onStartGame;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenHighscore;

  const HomeScreen({
    super.key,
    required this.onStartGame,
    required this.onOpenSettings,
    required this.onOpenHistory,
    required this.onOpenHighscore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/zidane.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                const Text(
                  'YOU ARE\nTHE REF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 0.9,
                  ),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      _buildGlassCard(
                        context,
                        'Spiel starten',
                        'Prüfung beginnen',
                        Icons.play_arrow,
                        Colors.green,
                        onStartGame,
                      ),
                      const SizedBox(height: 15),
                      _buildGlassCard(
                        context,
                        'Historie',
                        'Letzte Runden',
                        Icons.history,
                        Colors.orange,
                        onOpenHistory,
                      ),
                      const SizedBox(height: 15),
                      _buildGlassCard(
                        context,
                        'Top 10 Schiris',
                        'Bestenliste',
                        Icons.emoji_events,
                        Colors.amber,
                        onOpenHighscore,
                      ),
                      const SizedBox(height: 15),
                      _buildGlassCard(
                        context,
                        'Einstellungen',
                        'Anpassungen',
                        Icons.settings,
                        Colors.blueGrey,
                        onOpenSettings,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color col,
    VoidCallback tap,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: col.withValues(alpha: 0.2),
              child: Icon(icon, color: col),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
            onTap: tap,
          ),
        ),
      ),
    );
  }
}