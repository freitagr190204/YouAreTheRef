const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const db = new sqlite3.Database('./schiri.db');
const jsonPath = path.join(__dirname, 'data', 'scenes.json');

if (!fs.existsSync(jsonPath)) {
    console.error("Fehler: data/scenes.json wurde nicht gefunden!");
    process.exit(1);
}

const scenes = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS scenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        imagePath TEXT,
        correctDecision TEXT,
        explanation TEXT,
        isVar BOOLEAN
    )`);

    console.log("Tabelle 'scenes' ist bereit. Starte Import...");

    const stmt = db.prepare("INSERT INTO scenes (title, imagePath, correctDecision, explanation, isVar) VALUES (?, ?, ?, ?, ?)");
    
    scenes.forEach(s => {
        stmt.run(s.title, s.imagePath, s.correctDecision, s.explanation, s.isVar ? 1 : 0);
    });

    stmt.finalize((err) => {
        if (err) {
            console.error("Fehler beim Finalisieren: " + err.message);
        } else {
            console.log(`${scenes.length} Szenen erfolgreich in SQLite importiert!`);
        }
        db.close();
    });
});