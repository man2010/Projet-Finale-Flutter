// Importation du package Flutter pour les widgets Material Design
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// Importation du package provider pour accéder aux providers
import 'package:provider/provider.dart';

// Importation de geolocator pour la localisation
import 'package:geolocator/geolocator.dart';

// Importation du package weather pour la météo
import 'package:weather/weather.dart';

// Importation de dart:io pour manipuler les fichiers (photo de profil)
import 'dart:io';

// Importation de ConnectivityService pour vérifier la connexion
import '../services/ConnectivityService.dart';

// Importation de LoginScreen pour la déconnexion
import 'LoginScreen.dart';

// Importation de fluttertoast pour afficher des messages
import 'package:fluttertoast/fluttertoast.dart';

// Importation de intl pour formater les dates
import 'package:intl/intl.dart';

// Importation d'AuthProvider pour gérer l'authentification et la photo de profil
import '../providers/AuthProvider.dart';

// Importation de TodoProvider pour gérer les tâches
import '../providers/TodoProvider.dart';

// Importation du modèle Todo
import '../models/Todo.dart';

// Classe HomeScreen pour l'écran principal, stateful pour écouter la connectivité
class HomeScreen extends StatefulWidget {
  // Constructeur constant
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// État de HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  // Instance de ConnectivityService pour vérifier la connexion
  final ConnectivityService _connectivity = ConnectivityService();

  // Clé API OpenWeatherMap (remplacez par votre clé)
  final String weatherApiKey = '5a1ae0c78aa66eed9c07828b7056f285';

  // Position de l'utilisateur
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    debugPrint('HomeScreen: Initialisation');
    // Écouter les changements de connectivité pour synchroniser les tâches
    _connectivity.connectivityStream.listen((event) {
      // Vérification si l'appareil est connecté (wifi ou mobile)
      if (event == ConnectivityResult.mobile ||
          event == ConnectivityResult.wifi) {
        // Récupération des providers
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final todoProvider = Provider.of<TodoProvider>(context, listen: false);
        // Synchronisation des tâches si utilisateur connecté
        if (authProvider.currentUser != null) {
          debugPrint(
            'HomeScreen: Connexion détectée, synchronisation des tâches',
          );
          todoProvider.syncTodos(authProvider.currentUser!.id!);
          // Affichage d'un message toast pour indiquer la synchronisation
          Fluttertoast.showToast(msg: 'Synchronisation des tâches en cours');
        } else {
          debugPrint(
            'HomeScreen: Pas d\'utilisateur connecté, pas de synchronisation',
          );
        }
      } else {
        debugPrint('HomeScreen: Pas de connexion, synchronisation reportée');
      }
    });
    // Chargement initial des tâches
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      debugPrint(
        'HomeScreen: Chargement initial des tâches pour utilisateur ${authProvider.currentUser!.email}',
      );
      Provider.of<TodoProvider>(
        context,
        listen: false,
      ).fetchTodos(accountId: authProvider.currentUser!.id!);
    } else {
      debugPrint(
        'HomeScreen: Aucun utilisateur connecté, redirection vers LoginScreen',
      );
    }
    // Charger la localisation
    _loadLocation();
  }

  // Méthode pour charger la localisation
  Future<void> _loadLocation() async {
    debugPrint('HomeScreen: Chargement de la localisation');
    try {
      final position = await _getLocation();
      setState(() {
        _currentPosition = position;
      });
      debugPrint(
        'HomeScreen: Localisation chargée: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      debugPrint(
        'HomeScreen: Erreur lors du chargement de la localisation: $e',
      );
      Fluttertoast.showToast(
        msg: 'Erreur de localisation: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Méthode pour obtenir la position de l'utilisateur
  Future<Position> _getLocation() async {
    debugPrint('HomeScreen: Récupération de la localisation');
    // Vérification si le service de localisation est activé
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('HomeScreen: Service de localisation désactivé');
      Fluttertoast.showToast(
        msg: 'Veuillez activer la localisation',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      throw Exception('Service de localisation désactivé');
    }
    // Vérification des permissions de localisation
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('HomeScreen: Demande de permission de localisation');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('HomeScreen: Permission de localisation refusée');
        Fluttertoast.showToast(
          msg: 'Permission de localisation refusée',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        throw Exception('Permission de localisation refusée');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint(
        'HomeScreen: Permission de localisation refusée définitivement',
      );
      Fluttertoast.showToast(
        msg:
            'Permission de localisation refusée définitivement. Veuillez l\'activer dans les paramètres.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      throw Exception('Permission de localisation refusée définitivement');
    }
    // Retour de la position actuelle
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    debugPrint(
      'HomeScreen: Position obtenue: ${position.latitude}, ${position.longitude}',
    );
    return position;
  }

  // Méthode pour obtenir la température en fonction de la localisation
  Future<double> _getTemperature(Position position) async {
    debugPrint('HomeScreen: Récupération de la température');
    try {
      // Création d'une instance de WeatherFactory avec la clé API
      WeatherFactory wf = WeatherFactory(weatherApiKey);
      // Récupération de la météo pour la position donnée
      Weather weather = await wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      debugPrint(
        'HomeScreen: Température obtenue: ${weather.temperature!.celsius}°C',
      );
      // Retour de la température en Celsius
      return weather.temperature!.celsius!;
    } catch (e) {
      debugPrint('HomeScreen: Erreur lors de la récupération de la météo: $e');
      rethrow;
    }
  }

  // Méthode pour afficher un dialogue d'ajout ou de modification de tâche
  void _showTodoDialog(BuildContext context, {Todo? todo}) {
    debugPrint(
      'HomeScreen: Affichage du dialogue pour ${todo == null ? 'nouvelle tâche' : 'modification tâche ${todo.id}'}',
    );
    // Contrôleur pour le contenu de la tâche
    final TextEditingController todoController = TextEditingController(
      text: todo?.todo,
    );
    // Statut accompli (par défaut false si nouvelle tâche)
    bool done = todo?.done ?? false;

    // Affichage du dialogue
    showDialog(
      context: context,
      builder: (context) {
        // Utilisation de StatefulBuilder pour gérer l'état local du dialogue
        return StatefulBuilder(
          builder: (context, setState) {
            // Dialogue avec formulaire
            return AlertDialog(
              // Titre du dialogue
              title: Text(
                todo == null ? 'Ajouter une tâche' : 'Modifier la tâche',
              ),
              // Contenu du dialogue
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Champ de texte pour la tâche
                  TextField(
                    controller: todoController,
                    decoration: const InputDecoration(
                      labelText: 'Tâche',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  // Checkbox pour marquer la tâche comme accomplie
                  CheckboxListTile(
                    title: const Text('Accomplie'),
                    value: done,
                    onChanged: (value) {
                      // Mise à jour de l'état local
                      setState(() => done = value!);
                      debugPrint('HomeScreen: Statut accompli changé à $value');
                    },
                  ),
                ],
              ),
              // Actions du dialogue
              actions: [
                // Bouton Annuler
                TextButton(
                  onPressed: () {
                    // Fermeture du dialogue sans sauvegarde
                    Navigator.pop(context);
                    debugPrint('HomeScreen: Dialogue annulé');
                  },
                  child: const Text('Annuler'),
                ),
                // Bouton Enregistrer
                ElevatedButton(
                  onPressed: () {
                    // Validation du champ
                    if (todoController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Veuillez entrer une tâche');
                      debugPrint(
                        'HomeScreen: Tâche vide, enregistrement annulé',
                      );
                      return;
                    }
                    // Récupération de AuthProvider
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    // Création de la tâche
                    final newTodo = Todo(
                      id: todo?.id,
                      accountId: authProvider.currentUser!.id!,
                      date: DateTime.now().toIso8601String(),
                      todo: todoController.text,
                      done: done,
                    );
                    // Récupération de TodoProvider
                    final todoProvider = Provider.of<TodoProvider>(
                      context,
                      listen: false,
                    );
                    // Ajout ou mise à jour de la tâche
                    if (todo == null) {
                      todoProvider.addTodo(newTodo);
                      Fluttertoast.showToast(msg: 'Tâche ajoutée');
                      debugPrint('HomeScreen: Nouvelle tâche ajoutée');
                    } else {
                      todoProvider.updateTodo(newTodo);
                      Fluttertoast.showToast(msg: 'Tâche modifiée');
                      debugPrint('HomeScreen: Tâche ${newTodo.id} modifiée');
                    }
                    // Fermeture du dialogue
                    Navigator.pop(context);
                    debugPrint(
                      'HomeScreen: Dialogue fermé après enregistrement',
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Méthode build pour construire l'interface
  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen: Début de construction de l\'interface');
    // Accès aux providers
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);

    // Vérification si utilisateur connecté
    if (authProvider.currentUser == null) {
      debugPrint(
        'HomeScreen: Aucun utilisateur connecté, redirection vers LoginScreen',
      );
      // Redirection vers LoginScreen si non connecté
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
      // Retour d'un widget vide en attendant la redirection
      return const SizedBox();
    }

    // Scaffold pour l'écran principal
    return Scaffold(
      // Barre d'application
      appBar: AppBar(
        // Titre centré
        title: const Text('Mes Tâches'),
        centerTitle: true,
        // Boutons d'action
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              debugPrint('HomeScreen: Déconnexion initiée');
              // Déconnexion
              await authProvider.logout();
              // Redirection vers LoginScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
              // Message de déconnexion
              Fluttertoast.showToast(msg: 'Déconnexion réussie');
              debugPrint('HomeScreen: Déconnexion terminée');
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      // Corps de l'écran
      body: Column(
        children: [
          // Section profil et météo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar pour la photo de profil
                GestureDetector(
                  onTap: () async {
                    debugPrint('HomeScreen: Sélection de photo de profil');
                    // Sélection de la photo de profil
                    await authProvider.pickProfilePhoto();
                    // Message de confirmation
                    Fluttertoast.showToast(msg: 'Photo de profil mise à jour');
                  },
                  child: CircleAvatar(
                    radius: 30,
                    // Affichage de la photo si disponible
                    backgroundImage:
                        authProvider.profilePhotoPath != null
                            ? FileImage(File(authProvider.profilePhotoPath!))
                            : null,
                    // Icône par défaut si pas de photo
                    child:
                        authProvider.profilePhotoPath == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                  ),
                ),
                // Affichage de la température
                _currentPosition != null
                    ? FutureBuilder<double>(
                      future: _getTemperature(_currentPosition!),
                      builder: (context, weatherSnapshot) {
                        if (weatherSnapshot.hasData) {
                          // Affichage de la température
                          return Text(
                            'Temp: ${weatherSnapshot.data!.toStringAsFixed(1)} °C',
                            style: const TextStyle(fontSize: 16),
                          );
                        } else if (weatherSnapshot.hasError) {
                          debugPrint(
                            'HomeScreen: Erreur météo: ${weatherSnapshot.error}',
                          );
                          // Affichage de l'erreur
                          return Text(
                            'Erreur météo: ${weatherSnapshot.error}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        // Indicateur de chargement
                        return const CircularProgressIndicator();
                      },
                    )
                    : const Text(
                      'Localisation non disponible',
                      style: TextStyle(fontSize: 16),
                    ),
              ],
            ),
          ),
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              // Mise à jour du terme de recherche
              onChanged: todoProvider.searchTodos,
              decoration: InputDecoration(
                labelText: 'Rechercher une tâche',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: const Icon(Icons.search),
                // Bouton pour vider la recherche
                suffixIcon:
                    todoProvider.searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            // Réinitialisation de la recherche
                            todoProvider.searchTodos('');
                            debugPrint('HomeScreen: Recherche réinitialisée');
                          },
                        )
                        : null,
              ),
            ),
          ),
          // Liste des tâches
          Expanded(
            child:
                todoProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : todoProvider.errorMessage != null
                    ? Center(child: Text(todoProvider.errorMessage!))
                    : todoProvider.filteredTodos.isEmpty
                    ? const Center(child: Text('Aucune tâche trouvée'))
                    : ListView.builder(
                      itemCount: todoProvider.filteredTodos.length,
                      itemBuilder: (context, index) {
                        // Récupération de la tâche
                        final todo = todoProvider.filteredTodos[index];
                        // Carte pour la tâche avec animation
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              // Titre de la tâche
                              title: Text(
                                todo.todo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              // Sous-titre avec date et statut
                              subtitle: Text(
                                'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(todo.date))} - ${todo.done ? 'Accomplie' : 'Non accomplie'}',
                              ),
                              // Boutons d'action
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Bouton modifier
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed:
                                        () => _showTodoDialog(
                                          context,
                                          todo: todo,
                                        ),
                                  ),
                                  // Bouton supprimer
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      todoProvider.deleteTodo(
                                        todo.id!,
                                        todo.accountId,
                                      );
                                      // Message de confirmation
                                      Fluttertoast.showToast(
                                        msg: 'Tâche supprimée',
                                      );
                                      debugPrint(
                                        'HomeScreen: Tâche ${todo.id} supprimée',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          // Historique des tâches accomplies
          ExpansionTile(
            title: const Text('Historique des tâches accomplies'),
            children:
                todoProvider.history
                    .map(
                      (todo) => ListTile(
                        title: Text(todo.todo),
                        subtitle: Text(
                          'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(todo.date))}',
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
      // Bouton flottant pour ajouter une tâche
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Ajouter une tâche',
      ),
    );
  }
}
