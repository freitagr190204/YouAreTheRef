import 'package:flutter/material.dart';

// KI-Prompt: "Baue ein Widget SceneImage, das ein Bild anzeigt. Arbeite mit Animationen.

class SceneImage extends StatelessWidget {
  final String imagePath;
  final bool showVarOverlay;

  const SceneImage({
    super.key,
    required this.imagePath,
    this.showVarOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey.shade600),
                    const SizedBox(height: 8),
                    Text(
                      'Bild nicht geladen',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showVarOverlay)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VAR',
                style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
}