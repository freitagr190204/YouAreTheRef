import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scene.dart';

// KI-Prompt: Ich will GET und POST vom Backend verwenden, mache fetch und post Methoden.

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';

  /// Lädt Szenen; optional gefiltert nach Schwierigkeit (1=leicht, 2=mittel, 3=schwer).
  static Future<List<Scene>> fetchScenes({int? difficulty}) async {
    final uri = Uri.parse('$_baseUrl/scenes').replace(queryParameters: {
      if (difficulty != null) 'difficulty': difficulty.toString(),
    });

    final response = await http.get(uri);
    // --- KI-Prompt: "Query-Parameter nur setzen wenn nicht null. Bei statusCode 200
    // response.body mit jsonDecode parsen, jede Map mit Scene.fromJson zu Scene machen."
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Scene.fromJson(e)).toList();
    }
    throw Exception('Szenen konnten nicht geladen werden');
  }

  static Future<void> postRoundResult(
    int total,
    int correct,
    String playerName, {
    int? difficulty,
  }) async {
    await http.post(
      Uri.parse('$_baseUrl/rounds'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'total': total,
        'correct': correct,
        'playerName': playerName,
        if (difficulty != null) 'difficulty': difficulty,
      }),
    );
  }
}