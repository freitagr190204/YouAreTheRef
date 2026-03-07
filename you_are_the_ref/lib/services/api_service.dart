import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scene.dart';

// KI-Prompt: "Erzeuge mir einen ApiService für mein Express-Backend.

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';

  static Future<List<Scene>> fetchScenes({int? difficulty}) async {
    final uri = Uri.parse('$_baseUrl/scenes').replace(queryParameters: {
      if (difficulty != null) 'difficulty': difficulty.toString(),
    });

    final response = await http.get(uri);
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

  static Future<List<dynamic>> fetchHistory({int? difficulty}) async {
    final uri = Uri.parse('$_baseUrl/rounds').replace(queryParameters: {
      if (difficulty != null) 'difficulty': difficulty.toString(),
    });
    final response = await http.get(uri);
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>> fetchHighscores({int? difficulty}) async {
    final uri = Uri.parse('$_baseUrl/highscores').replace(queryParameters: {
      if (difficulty != null) 'difficulty': difficulty.toString(),
    });
    final response = await http.get(uri);
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> deleteRound(int roundId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/rounds/$roundId'));
    return response.statusCode == 200;
  }

  static Future<bool> clearHistory() async {
    final response = await http.delete(Uri.parse('$_baseUrl/rounds'));
    return response.statusCode == 200;
  }
}