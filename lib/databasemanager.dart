import 'package:activite2/modele/redacteur.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  DatabaseManager._init();

  Database? _database; // ✅ DÉCLARATION DE _database

  // Getter sécurisé pour la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    await initialisation();
    return _database!;
  }

  Future<void> initialisation() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'redacteurs_database.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE redacteurs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT
          )
        ''');
      },
    );
  }

  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('redacteurs');

    return List.generate(maps.length, (i) {
      return Redacteur(
        id: maps[i]['id'],
        nom: maps[i]['nom'],
        prenom: maps[i]['prenom'],
        email: maps[i]['email'],
      );
    });
  }

  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.insert('redacteurs', redacteur.toMap());
  }

  Future<void> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    await db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  Future<void> deleteRedacteur(int id) async {
    final db = await database;
    await db.delete('redacteurs', where: 'id = ?', whereArgs: [id]);
  }
}
