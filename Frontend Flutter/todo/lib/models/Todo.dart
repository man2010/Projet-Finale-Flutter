// Importation du package Dart pour les conversions
import 'dart:convert';

// Classe Todo pour représenter une tâche
class Todo {
  // ID de la tâche
  final int? id;
  // ID de l'utilisateur associé
  final int accountId;
  // Date de création
  final String date;
  // Contenu de la tâche
  final String todo;
  // Statut accompli (done)
  final bool done;

  // Constructeur avec paramètres requis
  Todo({
    this.id,
    required this.accountId,
    required this.date,
    required this.todo,
    required this.done,
  });

  // Méthode pour convertir la tâche en Map (pour API ou local)
  Map<String, dynamic> toMap() {
    return {
      'todo_id': id,
      'account_id': accountId,
      'date': date,
      'todo': todo,
      'done': done ? 1 : 0, // Booléen converti en int pour SQLite
    };
  }

  // Méthode pour créer une Todo depuis un Map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id:
          map['todo_id'] ??
          map['id'], // Supporte todo_id (MySQL/SQLite) et id (compatibilité)
      accountId:
          map['account_id'] is String
              ? int.parse(map['account_id'])
              : map['account_id'],
      date: map['date'],
      todo: map['todo'],
      done:
          map['done'] == 1 ||
          map['done'] == true, // Supporte int (SQLite) et bool (MySQL)
    );
  }

  // Méthode pour convertir en JSON
  String toJson() => json.encode(toMap());

  // Méthode pour créer depuis JSON
  factory Todo.fromJson(String source) => Todo.fromMap(json.decode(source));
}
