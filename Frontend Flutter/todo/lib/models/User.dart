// Importation du package Dart pour les conversions
import 'dart:convert';

// Classe User pour représenter un utilisateur
class User {
  // ID de l'utilisateur (de l'API)
  final int? id;
  // Email de l'utilisateur
  final String email;
  // Mot de passe (stocké localement pour connexion, mais hashed côté serveur)
  final String password;
  // Chemin de la photo de profil (persistante localement)
  final String? profilePhotoPath;

  // Constructeur avec paramètres requis
  User({
    this.id,
    required this.email,
    required this.password,
    this.profilePhotoPath,
  });

  // Méthode pour convertir l'utilisateur en Map (pour stockage ou API)
  Map<String, dynamic> toMap() {
    return {
      'account_id': id,
      'email': email,
      'password': password,
      'profile_photo_path': profilePhotoPath,
    };
  }

  // Méthode pour créer un User depuis un Map (de l'API ou local)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id:
          map['account_id'] is String
              ? int.parse(map['account_id'])
              : map['account_id'], // Gestion des cas où account_id est une chaîne
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      profilePhotoPath: map['profile_photo_path'],
    );
  }

  // Méthode pour convertir en JSON
  String toJson() => json.encode(toMap());

  // Méthode pour créer depuis JSON
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
