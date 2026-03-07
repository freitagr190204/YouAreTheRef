import 'package:flutter/material.dart';
import '../services/api_service.dart';

// KI-Prompt: "Erstelle einen Highscore-Screen, der die besten 10 Runden. Oben soll ein Filter Schwierigkeit eingebaut werden. Platz 1–3 hervorgehoben
class HighscoreScreen extends StatelessWidget {
  static const String routeName = '/highscore';
  const HighscoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Highscore')),
      body: _HighscoreBody(),
    );
  }
}

class _HighscoreBody extends StatefulWidget {
  @override
  State<_HighscoreBody> createState() => _HighscoreBodyState();
}

class _HighscoreBodyState extends State<_HighscoreBody> {
  int? _selectedDifficulty; // null = alle

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Schwierigkeit: '),
              DropdownButton<int?>(
                value: _selectedDifficulty,
                items: const [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Alle'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 1,
                    child: Text('Leicht'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 2,
                    child: Text('Mittel'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 3,
                    child: Text('Schwer'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            key: ValueKey(_selectedDifficulty),
            future: ApiService.fetchHighscores(difficulty: _selectedDifficulty),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Verbindung zum Server fehlgeschlagen.\nBackend unter http://localhost:3000 starten.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Erneut laden'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Noch keine Daten vorhanden.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final round = snapshot.data![index];
                  final String name = round['playerName']?.toString() ?? 'Unbekannt';
                  final int? difficulty = round['difficulty'] as int?;

                  String diffLabel = 'Alle';
                  if (difficulty == 1) diffLabel = 'Leicht';
                  if (difficulty == 2) diffLabel = 'Mittel';
                  if (difficulty == 3) diffLabel = 'Schwer';

                  return Card(
                    elevation: index < 3 ? 4 : 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            index == 0 ? Colors.amber : (index == 1 ? Colors.grey : Colors.brown),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${round['correct']} / ${round['total']} richtig • $diffLabel',
                      ),
                      trailing: const Icon(Icons.star, color: Colors.amber, size: 20),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}