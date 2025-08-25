// Importation foundation
import 'package:flutter/foundation.dart';

// Importation ApiService
import '../services/ApiService.dart';

// Importation DatabaseHelper
import '../services/DatabaseHelper.dart';

// Importation ConnectivityService
import '../services/ConnectivityService.dart';

// Importation model Todo
import '../models/Todo.dart';

// Classe TodoProvider pour gestion tâches online/offline
class TodoProvider with ChangeNotifier {
  // Liste tâches
  List<Todo> _todos = [];

  // Getter tâches
  List<Todo> get todos => _todos;

  // Historique (tâches done)
  List<Todo> get history => _todos.where((todo) => todo.done).toList();

  // Chargement
  bool _isLoading = false;

  // Getter chargement
  bool get isLoading => _isLoading;

  // Erreur
  String? _errorMessage;

  // Getter erreur
  String? get errorMessage => _errorMessage;

  // Recherche
  String _searchQuery = '';

  // Getter recherche
  String get searchQuery => _searchQuery;

  // Instances services
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivity = ConnectivityService();

  // Constructeur : charger local et sync si online
  TodoProvider() {
    fetchTodos();
  }

  // Fetch tâches : local d'abord, sync si online
  Future<void> fetchTodos({int? accountId}) async {
    debugPrint('TodoProvider: Début de fetchTodos');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (accountId != null) {
        _todos = await _dbHelper.getTodos(accountId);
        debugPrint(
          'TodoProvider: Tâches chargées depuis la base locale: ${_todos.length}',
        );
      }
      if (await _connectivity.isOnline()) {
        debugPrint(
          'TodoProvider: Connexion internet détectée, synchronisation en cours',
        );
        if (accountId != null) {
          final remoteTodos = await _apiService.getTodos(accountId);
          _todos = remoteTodos;
          debugPrint(
            'TodoProvider: Tâches chargées depuis l\'API: ${remoteTodos.length}',
          );
          // Sync local with remote
          for (var todo in remoteTodos) {
            await _dbHelper.insertTodo(todo, syncFlag: 'synced');
          }
          debugPrint(
            'TodoProvider: Synchronisation des tâches locales avec remote réussie',
          );
          // Sync pending local to remote
          final pending = await _dbHelper.getPendingTodos(accountId);
          for (var pendingTodo in pending) {
            await _apiService.insertTodo(pendingTodo);
            await _dbHelper.markAsSynced(pendingTodo.id!);
          }
          debugPrint(
            'TodoProvider: Synchronisation des tâches pending vers remote réussie',
          );
        }
      } else {
        debugPrint(
          'TodoProvider: Pas de connexion internet, utilisation des tâches locales',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('TodoProvider: Erreur lors de fetchTodos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('TodoProvider: Fin de fetchTodos');
    }
  }

  // Add todo : local, sync if online
  Future<void> addTodo(Todo todo) async {
    debugPrint('TodoProvider: Début d\'addTodo');
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.insertTodo(todo);
      debugPrint('TodoProvider: Tâche ajoutée localement');
      if (await _connectivity.isOnline()) {
        await _apiService.insertTodo(todo);
        await _dbHelper.markAsSynced(todo.id!);
        debugPrint('TodoProvider: Tâche synchronisée avec l\'API');
      }
      await fetchTodos(accountId: todo.accountId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('TodoProvider: Erreur lors d\'addTodo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('TodoProvider: Fin d\'addTodo');
    }
  }

  // Update todo : local, sync if online
  Future<void> updateTodo(Todo todo) async {
    debugPrint('TodoProvider: Début d\'updateTodo');
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateTodo(todo);
      debugPrint('TodoProvider: Tâche mise à jour localement');
      if (await _connectivity.isOnline()) {
        await _apiService.updateTodo(todo);
        await _dbHelper.markAsSynced(todo.id!);
        debugPrint('TodoProvider: Tâche mise à jour sur l\'API');
      }
      await fetchTodos(accountId: todo.accountId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('TodoProvider: Erreur lors d\'updateTodo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('TodoProvider: Fin d\'updateTodo');
    }
  }

  // Delete todo : local, sync if online
  Future<void> deleteTodo(int id, int accountId) async {
    debugPrint('TodoProvider: Début de deleteTodo');
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.deleteTodo(id);
      debugPrint('TodoProvider: Tâche supprimée localement');
      if (await _connectivity.isOnline()) {
        await _apiService.deleteTodo(id);
        debugPrint('TodoProvider: Tâche supprimée sur l\'API');
      }
      await fetchTodos(accountId: accountId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('TodoProvider: Erreur lors de deleteTodo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('TodoProvider: Fin de deleteTodo');
    }
  }

  // Recherche
  void searchTodos(String query) {
    debugPrint('TodoProvider: Recherche mise à jour avec query: $query');
    _searchQuery = query;
    notifyListeners();
  }

  // Filtered todos
  List<Todo> get filteredTodos {
    debugPrint('TodoProvider: Filtrage des tâches avec query: $_searchQuery');
    if (_searchQuery.isEmpty) {
      return _todos;
    }
    return _todos
        .where(
          (todo) =>
              todo.todo.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // Sync when online
  Future<void> syncTodos(int accountId) async {
    debugPrint('TodoProvider: Début de syncTodos');
    if (await _connectivity.isOnline()) {
      await fetchTodos(accountId: accountId);
      debugPrint('TodoProvider: Synchronisation réussie');
    } else {
      debugPrint('TodoProvider: Pas de connexion, synchronisation reportée');
    }
  }
}
