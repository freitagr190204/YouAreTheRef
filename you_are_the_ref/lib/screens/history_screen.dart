import 'package:flutter/material.dart';
import '../services/api_service.dart';

// KI-Prompt: "Erstelle einen History-Screen, der die letzten Runden anzeigt. Oben soll ein Filter Schwierigkeit eingebaut werden. Man soll die History löschen können.

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Key _refreshKey = UniqueKey();
  int? _selectedDifficulty; // null = alle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historie'),
        actions: [
          DropdownButton<int?>(
            value: _selectedDifficulty,
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
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
                _refreshKey = UniqueKey();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await ApiService.clearHistory();
              setState(() => _refreshKey = UniqueKey());
            },
          )
        ],
      ),
          body: FutureBuilder<List<dynamic>>(
        key: _refreshKey,
        future: ApiService.fetchHistory(difficulty: _selectedDifficulty),
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
                      onPressed: () => setState(() => _refreshKey = UniqueKey()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut laden'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Noch keine Runden in der Historie.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Spiele eine Runde zu Ende – dein Ergebnis wird hier automatisch gespeichert.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final round = snapshot.data![index];
              final String name = round['playerName']?.toString() ?? 'Anonym';
              final int? difficulty = round['difficulty'] as int?;

              String diffLabel = 'Alle';
              if (difficulty == 1) diffLabel = 'Leicht';
              if (difficulty == 2) diffLabel = 'Mittel';
              if (difficulty == 3) diffLabel = 'Schwer';
              
              return Dismissible(
                key: Key(round['roundId']?.toString() ?? index.toString()),
                onDismissed: (dir) => ApiService.deleteRound(round['roundId']),
                background: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Icon(Icons.delete, color: Colors.white)),
                child: Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(
                      'Ergebnis: ${round['correct']} / ${round['total']} • $diffLabel',
                    ),
                    trailing: Text(round['timestamp'] != null ? round['timestamp'].toString().substring(0, 10) : ''),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}