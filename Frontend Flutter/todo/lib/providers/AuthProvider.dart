// Importation foundation
import 'package:flutter/foundation.dart';

// Importation shared_preferences
import 'package:shared_preferences/shared_preferences.dart';

// Importation ApiService
import '../services/ApiService.dart';

// Importation model User
import '../models/User.dart';

// Importation image_picker pour photo
import 'package:image_picker/image_picker.dart';

// Importation dart:io pour fichiers
import 'dart:io';

// Classe AuthProvider pour gestion authentification et profil
class AuthProvider with ChangeNotifier {
  // Utilisateur actuel
  User? _currentUser;

  // Getter pour utilisateur
  User? get currentUser => _currentUser;

  // Chemin photo profil
  String? _profilePhotoPath;

  // Getter pour photo
  String? get profilePhotoPath => _profilePhotoPath;

  // Indicateur chargement
  bool _isLoading = false;

  // Getter chargement
  bool get isLoading => _isLoading;

  // Erreur
  String? _errorMessage;

  // Getter erreur
  String? get errorMessage => _errorMessage;

  // Instance ApiService
  final ApiService _apiService = ApiService();

  // Constructeur : charger depuis preferences
  AuthProvider() {
    debugPrint('AuthProvider: Initialisation');
    _loadFromPrefs();
  }

  // Charger user et photo depuis prefs (persistance)
  Future<void> _loadFromPrefs() async {
    debugPrint('AuthProvider: Chargement des préférences partagées');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        _currentUser = User.fromJson(userJson);
        debugPrint(
          'AuthProvider: Utilisateur chargé depuis prefs: ${_currentUser!.email}',
        );
      } else {
        debugPrint(
          'AuthProvider: Aucun utilisateur trouvé dans les préférences',
        );
      }
      _profilePhotoPath = prefs.getString('profile_photo_path');
      if (_profilePhotoPath != null) {
        debugPrint('AuthProvider: Photo de profil chargée: $_profilePhotoPath');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider: Erreur lors du chargement des prefs: $e');
    }
  }

  // Sauvegarder user et photo dans prefs
  Future<void> _saveToPrefs() async {
    debugPrint('AuthProvider: Sauvegarde dans les préférences partagées');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('current_user', _currentUser!.toJson());
        debugPrint(
          'AuthProvider: Utilisateur sauvegardé: ${_currentUser!.email}',
        );
      } else {
        await prefs.remove('current_user');
        debugPrint('AuthProvider: Utilisateur supprimé des préférences');
      }
      if (_profilePhotoPath != null) {
        await prefs.setString('profile_photo_path', _profilePhotoPath!);
        debugPrint(
          'AuthProvider: Photo de profil sauvegardée: $_profilePhotoPath',
        );
      } else {
        await prefs.remove('profile_photo_path');
        debugPrint('AuthProvider: Photo de profil supprimée des préférences');
      }
    } catch (e) {
      debugPrint('AuthProvider: Erreur lors de la sauvegarde des prefs: $e');
    }
  }

  // Inscription
  Future<void> register(User user) async {
    debugPrint('AuthProvider: Début de l\'inscription pour ${user.email}');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(user);
      debugPrint(
        'AuthProvider: Réponse API inscription: ${response.toString()}',
      );
      if (response['success'] == true) {
        // Connexion automatique après inscription
        debugPrint('AuthProvider: Inscription réussie, connexion automatique');
        await login(user);
      } else {
        _errorMessage =
            response['message'] ?? 'Erreur inconnue lors de l\'inscription';
        debugPrint('AuthProvider: Erreur d\'inscription: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Échec de l\'inscription: $e';
      debugPrint('AuthProvider: Exception lors de l\'inscription: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider: Fin de l\'inscription');
    }
  }

  // Connexion
  Future<void> login(User user) async {
    debugPrint('AuthProvider: Début de la connexion pour ${user.email}');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(user);
      debugPrint('AuthProvider: Réponse API connexion: ${response.toString()}');
      if (response['success'] == true && response['data'] != null) {
        _currentUser = User.fromMap(response['data']);
        await _saveToPrefs();
        debugPrint(
          'AuthProvider: Connexion réussie, utilisateur: ${_currentUser!.email}',
        );
      } else {
        _errorMessage =
            response['message'] ?? 'Email ou mot de passe incorrect';
        debugPrint('AuthProvider: Erreur de connexion: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Échec de la connexion: $e';
      debugPrint('AuthProvider: Exception lors de la connexion: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider: Fin de la connexion');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    debugPrint('AuthProvider: Début de la déconnexion');
    _currentUser = null;
    _profilePhotoPath = null;
    await _saveToPrefs();
    notifyListeners();
    debugPrint('AuthProvider: Déconnexion réussie');
  }

  // Choisir photo profil
  Future<void> pickProfilePhoto() async {
    debugPrint('AuthProvider: Début de la sélection de photo de profil');
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _profilePhotoPath = pickedFile.path;
        await _saveToPrefs();
        debugPrint(
          'AuthProvider: Photo de profil sélectionnée: $_profilePhotoPath',
        );
      } else {
        debugPrint('AuthProvider: Aucune photo sélectionnée');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider: Erreur lors de la sélection de la photo: $e');
    }
  }
}
