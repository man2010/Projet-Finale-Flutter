// Importation du package http pour les appels API
import 'package:http/http.dart' as http;

// Importation du package Dart pour JSON
import 'dart:convert';

// Importation des models
import '../models/User.dart';
import '../models/Todo.dart';

// Importation foundation pour debugPrint
import 'package:flutter/foundation.dart';

// Classe ApiService pour gérer les appels à l'API PHP
class ApiService {
  // URL de base de l'API
  static const String baseUrl = 'http://192.168.1.22/todo/';

  // Méthode pour l'inscription (POST register)
  Future<Map<String, dynamic>> register(User user) async {
    debugPrint('ApiService: Début de l\'inscription pour ${user.email}');
    // Construction de l'URL pour l'endpoint
    final url = Uri.parse('${baseUrl}register');
    // Envoi de la requête POST avec body JSON
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': user.email, 'password': user.password}),
    );
    debugPrint(
      'ApiService: Réponse inscription: ${response.statusCode} - ${response.body}',
    );
    // Vérification du statut de la réponse
    if (response.statusCode == 200) {
      try {
        // Décodage de la réponse JSON
        final jsonResponse = json.decode(response.body);
        debugPrint('ApiService: JSON décodé (inscription): $jsonResponse');
        if (jsonResponse['success'] != null || jsonResponse['data'] != null) {
          return {
            'success': jsonResponse['success'] ?? true,
            'data': jsonResponse['data'] ?? jsonResponse,
            'message': jsonResponse['message'] ?? '',
          };
        } else {
          debugPrint('ApiService: Réponse inscription invalide: $jsonResponse');
          throw Exception('Réponse invalide de l\'API');
        }
      } catch (e) {
        debugPrint(
          'ApiService: Erreur de parsing JSON (inscription): $e - Réponse brute: ${response.body}',
        );
        throw Exception('Erreur de parsing de la réponse: $e');
      }
    } else {
      debugPrint(
        'ApiService: Échec inscription, statut: ${response.statusCode} - Réponse: ${response.body}',
      );
      throw Exception('Échec de l\'inscription: ${response.body}');
    }
  }

  // Méthode pour la connexion (POST login)
  Future<Map<String, dynamic>> login(User user) async {
    debugPrint('ApiService: Début de la connexion pour ${user.email}');
    // Construction de l'URL pour l'endpoint
    final url = Uri.parse('${baseUrl}login');
    // Envoi de la requête POST
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': user.email, 'password': user.password}),
    );
    debugPrint(
      'ApiService: Réponse connexion: ${response.statusCode} - ${response.body}',
    );
    // Vérification du statut
    if (response.statusCode == 200) {
      try {
        // Décodage de la réponse JSON
        final jsonResponse = json.decode(response.body);
        debugPrint('ApiService: JSON décodé (connexion): $jsonResponse');
        if (jsonResponse['data'] != null) {
          return {
            'success': jsonResponse['success'] ?? true,
            'data': jsonResponse['data'],
            'message': jsonResponse['message'] ?? '',
          };
        } else {
          debugPrint('ApiService: Réponse connexion invalide: $jsonResponse');
          throw Exception('Réponse invalide de l\'API');
        }
      } catch (e) {
        debugPrint(
          'ApiService: Erreur de parsing JSON (connexion): $e - Réponse brute: ${response.body}',
        );
        throw Exception('Erreur de parsing de la réponse: $e');
      }
    } else {
      debugPrint(
        'ApiService: Échec connexion, statut: ${response.statusCode} - Réponse: ${response.body}',
      );
      throw Exception('Échec de la connexion: ${response.body}');
    }
  }

  // Méthode pour récupérer les tâches (POST todos)
  Future<List<Todo>> getTodos(int accountId) async {
    debugPrint(
      'ApiService: Début de récupération des tâches pour accountId: $accountId',
    );
    // Construction de l'URL
    final url = Uri.parse('${baseUrl}todos');
    // Envoi POST avec account_id
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'account_id': accountId}),
    );
    debugPrint(
      'ApiService: Réponse todos: ${response.statusCode} - ${response.body}',
    );
    // Vérification du statut
    if (response.statusCode == 200) {
      try {
        // Décodage de la liste JSON
        final jsonResponse = json.decode(response.body);
        debugPrint('ApiService: JSON décodé pour todos: $jsonResponse');
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Todo.fromMap(json)).toList();
        } else {
          debugPrint(
            'ApiService: Aucune tâche trouvée ou réponse invalide: $jsonResponse',
          );
          return [];
        }
      } catch (e) {
        debugPrint(
          'ApiService: Erreur de parsing JSON (todos): $e - Réponse brute: ${response.body}',
        );
        throw Exception('Erreur de parsing des tâches: $e');
      }
    } else {
      debugPrint(
        'ApiService: Échec récupération tâches, statut: ${response.statusCode} - Réponse: ${response.body}',
      );
      throw Exception('Échec récupération tâches: ${response.body}');
    }
  }

  // Méthode pour créer une tâche (POST inserttodo)
  Future<void> insertTodo(Todo todo) async {
    debugPrint('ApiService: Début de l\'insertion de tâche: ${todo.todo}');
    // Construction de l'URL
    final url = Uri.parse('${baseUrl}inserttodo');
    // Envoi POST avec body
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toMap()),
    );
    debugPrint(
      'ApiService: Réponse inserttodo: ${response.statusCode} - ${response.body}',
    );
    // Vérification du statut
    if (response.statusCode != 200) {
      debugPrint(
        'ApiService: Échec insertion tâche, statut: ${response.statusCode} - Réponse: ${response.body}',
      );
      throw Exception('Échec création tâche: ${response.body}');
    }
    try {
      final jsonResponse = json.decode(response.body);
      debugPrint('ApiService: JSON décodé pour inserttodo: $jsonResponse');
      if (jsonResponse['success'] != true) {
        debugPrint(
          'ApiService: Échec logique insertion tâche: ${jsonResponse['message']}',
        );
        throw Exception('Échec création tâche: ${jsonResponse['message']}');
      }
    } catch (e) {
      debugPrint(
        'ApiService: Erreur de parsing JSON (inserttodo): $e - Réponse brute: ${response.body}',
      );
      throw Exception('Erreur de parsing de la réponse: $e');
    }
  }

  // Méthode pour mettre à jour une tâche (POST updatetodo)
  Future<void> updateTodo(Todo todo) async {
    debugPrint('ApiService: Début de la mise à jour de tâche: ${todo.id}');
    // Construction de l'URL
    final url = Uri.parse('${baseUrl}updatetodo');
    // Envoi POST
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toMap()),
    );
    debugPrint(
      'ApiService: Réponse updatetodo: ${response.statusCode} - ${response.body}',
    );
    // Vérification
    if (response.statusCode != 200) {
      debugPrint(
        'ApiService: Échec mise à jour tâche, statut: ${response.statusCode} - Réponse: ${response.body}',
      );
      throw Exception('Échec mise à jour tâche: ${response.body}');
    }
    try {
      final jsonResponse = json.decode(response.body);
      debugPrint('ApiService: JSON décodé pour updatetodo: $jsonResponse');
      if (jsonResponse['success'] != true) {
        debugPrint(
          'ApiService: Échec logique mise à jour tâche: ${jsonResponse['message']}',
        );
        throw Exception('Échec mise à jour tâche: ${jsonResponse['message']}');
      }
    } catch (e) {
      debugPrint(
        'ApiService: Erreur de parsing JSON (updatetodo): $e - Réponse brute: ${response.body}',
      );
      throw Exception('Erreur de parsing de la réponse: $e');
    }
  }

  // Méthode pour supprimer une tâche (POST deletetodo)
  Future<void> deleteTodo(int todoId) async {
    debugPrint('ApiService: Début de la suppression de tâche: $todoId');
    // Construction de l'URL
    final url = Uri.parse('${baseUrl}deletetodo');
    // Envoi POST avec todo_id
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'todo_id': todoId}),
    );
    debugPrint(
      'ApiService: Réponse deletetodo: ${response.statusCode} - ${response.body}',
    );
    // Vérification
    if (response.statusCode != 200) {
      debugPrint(
        'ApiService: Échec suppression tâche, statut: ${response.statusCode} - Réponse: ${response.body}',
      );
      throw Exception('Échec suppression tâche: ${response.body}');
    }
    try {
      final jsonResponse = json.decode(response.body);
      debugPrint('ApiService: JSON décodé pour deletetodo: $jsonResponse');
      if (jsonResponse['success'] != true) {
        debugPrint(
          'ApiService: Échec logique suppression tâche: ${jsonResponse['message']}',
        );
        throw Exception('Échec suppression tâche: ${jsonResponse['message']}');
      }
    } catch (e) {
      debugPrint(
        'ApiService: Erreur de parsing JSON (deletetodo): $e - Réponse brute: ${response.body}',
      );
      throw Exception('Erreur de parsing de la réponse: $e');
    }
  }
}
