const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

const dbPath = path.join(__dirname, 'schiri.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) console.error("DB Error: " + err.message);
    else console.log("Verbunden mit SQLite Datenbank.");
});

db.serialize(() => {
    // Tabelle 1: Szenen
    db.run(`CREATE TABLE IF NOT EXISTS scenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        imagePath TEXT,
        correctDecision TEXT,
        explanation TEXT,
        isVar BOOLEAN,
        difficulty INTEGER DEFAULT 1
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS rounds (
        roundId INTEGER PRIMARY KEY AUTOINCREMENT,
        playerName TEXT,
        total INTEGER,
        correct INTEGER,
        difficulty INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    const scenesJsonPath = path.join(__dirname, 'data', 'scenes.json');
    db.get('SELECT COUNT(*) AS count FROM scenes', (err, row) => {
        if (err) {
            console.error('Fehler beim Zählen der Szenen:', err.message);
            return;
        }
        if (row.count === 0) {
            try {
                const raw = fs.readFileSync(scenesJsonPath, 'utf8');
                const scenes = JSON.parse(raw);
                const stmt = db.prepare(`INSERT INTO scenes 
                    (id, title, imagePath, correctDecision, explanation, isVar, difficulty)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                `);
                scenes.forEach((s) => {
                    stmt.run(
                        s.id,
                        s.title || null,
                        s.imagePath,
                        s.correctDecision,
                        s.explanation || null,
                        0,
                        s.difficulty || 1
                    );
                });
                stmt.finalize();
                console.log(`Initial ${scenes.length} Szenen aus scenes.json importiert.`);
            } catch (e) {
                console.error('Fehler beim Import der Szenen aus JSON:', e);
            }
        }
    });
});

// KI-Prompt: Express-Server mit SQLite einrichten, zwei Tabellen
// scenes und rounds anlegen, beim Start mit JSON-Datei scenes.json befüllen. 
// 2 Endpunkte: GET -> random 10 Szenen und POST Ergebnis speichern

app.get('/scenes', (req, res) => {
    const difficulty = parseInt(req.query.difficulty, 10);

    let sql = "SELECT * FROM scenes";
    const params = [];

    if (!isNaN(difficulty)) {
        sql += " WHERE difficulty = ?";
        params.push(difficulty);
    }

    sql += " ORDER BY RANDOM() LIMIT 10";

    db.all(sql, params, (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.post('/rounds', (req, res) => {
    const { playerName, total, correct, difficulty } = req.body;
    const sql = "INSERT INTO rounds (playerName, total, correct, difficulty) VALUES (?, ?, ?, ?)";
    db.run(sql, [playerName, total, correct, difficulty || null], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ id: this.lastID });
    });
});

app.listen(PORT, () => console.log(`Backend läuft auf http://localhost:${PORT}`));