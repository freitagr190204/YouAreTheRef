class Scene {
  final int id;
  final String imagePath;
  final String correctDecision;
  final String explanation;

  Scene({
    required this.id,
    required this.imagePath,
    required this.correctDecision,
    required this.explanation,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'] as int,
      imagePath: json['imagePath'] as String,
      correctDecision: json['correctDecision'] as String,
      explanation: json['explanation'] ?? 'Keine Erklärung verfügbar.',
    );
  }
}