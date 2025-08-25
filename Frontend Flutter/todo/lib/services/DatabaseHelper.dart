// Importation sqflite
import 'package:sqflite/sqflite.dart';

// Importation path
import 'package:path/path.dart';

// Importation foundation pour debugPrint
import 'package:flutter/foundation.dart';

// Importation model Todo
import '../models/Todo.dart';

// Classe DatabaseHelper pour base locale (offline)
class DatabaseHelper {
  // Instance statique
  static Database? _database;

  // Getter pour database
  Future<Database> get database async {
    if (_database != null) {
      debugPrint('DatabaseHelper: Base déjà initialisée');
      return _database!;
    }
    debugPrint('DatabaseHelper: Initialisation base');
    _database = await _initDb('todo.db');
    return _database!;
  }

  // Initialisation
  Future<Database> _initDb(String databaseName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    debugPrint('DatabaseHelper: Chemin : $path');

    return await openDatabase(
      path,
      version: 2, // Incrémenté pour gérer la migration
      onCreate: (db, version) async {
        debugPrint('DatabaseHelper: Création table todo_tables');
        await db.execute('''
          CREATE TABLE todo_tables (
            todo_id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            todo TEXT,
            done INTEGER,
            sync_flag TEXT DEFAULT 'pending'  -- Flag for sync: 'pending', 'synced'
          )
        ''');
        debugPrint('DatabaseHelper: Table créée');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          debugPrint('DatabaseHelper: Migration de la base vers version 2');
          // Supprimer l'ancienne table TODO
          await db.execute('DROP TABLE IF EXISTS TODO');
          // Créer la nouvelle table todo_tables
          await db.execute('''
            CREATE TABLE todo_tables (
              todo_id INTEGER PRIMARY KEY AUTOINCREMENT,
              account_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              todo TEXT,
              done INTEGER,
              sync_flag TEXT DEFAULT 'pending'
            )
          ''');
          debugPrint('DatabaseHelper: Migration terminée');
        }
      },
    );
  }

  // Insert local
  Future<int> insertTodo(Todo todo, {String syncFlag = 'pending'}) async {
    final db = await database;
    final map = todo.toMap();
    map['sync_flag'] = syncFlag;
    debugPrint('DatabaseHelper: Insertion d\'une tâche: ${map['todo']}');
    return await db.insert('todo_tables', map);
  }

  // Get local todos
  Future<List<Todo>> getTodos(int accountId) async {
    final db = await database;
    final maps = await db.query(
      'todo_tables',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
    debugPrint(
      'DatabaseHelper: Récupération des tâches locales: ${maps.length}',
    );
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  // Update local
  Future<int> updateTodo(Todo todo, {String syncFlag = 'pending'}) async {
    final db = await database;
    final map = todo.toMap();
    map['sync_flag'] = syncFlag;
    debugPrint('DatabaseHelper: Mise à jour d\'une tâche: ${map['todo']}');
    return await db.update(
      'todo_tables',
      map,
      where: 'todo_id = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete local
  Future<int> deleteTodo(int id) async {
    final db = await database;
    debugPrint('DatabaseHelper: Suppression d\'une tâche: $id');
    return await db.delete(
      'todo_tables',
      where: 'todo_id = ?',
      whereArgs: [id],
    );
  }

  // Get pending sync todos
  Future<List<Todo>> getPendingTodos(int accountId) async {
    final db = await database;
    final maps = await db.query(
      'todo_tables',
      where: 'account_id = ? AND sync_flag = ?',
      whereArgs: [accountId, 'pending'],
    );
    debugPrint(
      'DatabaseHelper: Récupération des tâches pending: ${maps.length}',
    );
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  // Mark as synced
  Future<void> markAsSynced(int id) async {
    final db = await database;
    debugPrint('DatabaseHelper: Marquage d\'une tâche comme synchronisée: $id');
    await db.update(
      'todo_tables',
      {'sync_flag': 'synced'},
      where: 'todo_id = ?',
      whereArgs: [id],
    );
  }
}
