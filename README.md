# Projet-Final-Flutter : Application TODO avec Backend PHP et Frontend Flutter

## Description

Ce projet est une application mobile Flutter complète pour la gestion de tâches (TODO) avec un backend PHP pour la gestion des données. L'application permet aux utilisateurs de s'inscrire, se connecter, gérer leurs tâches (création, modification, suppression, recherche, historique), ajouter une photo de profil, afficher la localisation et la météo, et supporter le mode offline avec synchronisation automatique des données lorsque la connexion est rétablie.

Le projet est structuré en deux dossiers principaux :
- **Backend PHP (api)** : Gère les endpoints API pour l'authentification et les tâches, avec connexion à une base de données MySQL.
- **Frontend Flutter** : L'application mobile Flutter qui interagit avec l'API, gère la base locale SQLite pour le mode offline, et affiche l'interface utilisateur.

Ce projet a été développé dans le cadre du Master M1 2024-2025, avec un focus sur l'authentification sécurisée, la synchronisation online/offline, et des fonctionnalités additionnelles comme la géolocalisation et la météo.

## Fonctionnalités

### Gestion des Comptes
- **Inscription** : Création de compte avec email et mot de passe.
- **Connexion** : Authentification avec persistance de session via SharedPreferences (maintient la session même après fermeture de l'application).
- **Déconnexion** : Fermeture de session avec suppression des données locales.

### Gestion des Tâches
- **Affichage** : Liste des tâches de l'utilisateur, avec statut (accomplie/non accomplie) et date.
- **Création** : Ajout de tâches même offline (stockées localement en SQLite, synchronisées online).
- **Modification** : Édition des tâches avec ou sans connexion.
- **Accomplir** : Marquer une tâche comme accomplie.
- **Suppression** : Suppression de tâches.
- **Recherche** : Recherche par contenu de la tâche.
- **Historique** : Affichage des tâches accomplies dans un ExpansionTile.

### Fonctionnalités Additionnelles
- **Photo de profil** : Sélection depuis la galerie et persistance locale (via SharedPreferences).
- **Géolocalisation** : Affichage de la position actuelle.
- **Météo** : Affichage de la température basée sur la localisation (via OpenWeatherMap API).

### Support Offline
- Utilisation de SQLite pour stocker les tâches localement.
- Synchronisation automatique lorsque la connexion internet est détectée (via ConnectivityPlus).

## Prérequis

- **Backend PHP** :
  - PHP 7.4+.
  - MySQL ou MariaDB.
  - Serveur web (ex. XAMPP, WAMP, ou serveur en ligne).

- **Frontend Flutter** :
  - Flutter SDK (version >= 3.0.0).
  - Android Studio ou VS Code pour le développement.
  - Un appareil Android ou émulateur pour les tests.

- **Clés API** :
  - OpenWeatherMap API pour la météo (inscrivez-vous sur [openweathermap.org](https://openweathermap.org) pour obtenir une clé gratuite).

## Installation

### 1. Backend PHP (dossier `api`)
1. Installez XAMPP (ou un serveur PHP équivalent) et démarrez Apache et MySQL.
2. Copiez le dossier `api` dans le répertoire web (ex. `C:\xampp\htdocs\todo`).
3. Créez la base de données MySQL via phpMyAdmin ou ligne de commande :
   ```sql
   -- 1. Créer la base de données
   CREATE DATABASE todo_db;

   -- 2. Créer la table des comptes
   CREATE TABLE accounts_table (
       account_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
       email VARCHAR(100) NOT NULL,
       password VARCHAR(500)
   );

   -- 3. Créer la table des tâches
   CREATE TABLE todo_tables (
       todo_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
       account_id INT NOT NULL,
       date DATE NOT NULL,
       todo VARCHAR(500),
       done BOOLEAN,
       CONSTRAINT fk_account_id FOREIGN KEY (account_id)
           REFERENCES accounts_table(account_id)
   );

   -- 4. Créer l'utilisateur
   CREATE USER 'default-user'@'localhost';

   -- 5. Accorder les permissions
   GRANT INSERT, SELECT, UPDATE, DELETE ON todo_db.* TO 'default-user'@'localhost';
   ```
4. Testez l'API avec Postman :
   - POST `http://localhost/todo/main.php?request=login` avec body JSON : `{ "email": "test@example.com", "password": "test" }`.
   - Vérifiez la réponse (ex. `{"success": false, "message": "Email ou mot de passe incorrect"}`).

### 2. Frontend Flutter (dossier `flutter`)
1. Installez Flutter sur votre machine si ce n'est pas déjà fait.
2. Naviguez vers le dossier `flutter` et exécutez :
   ```bash
   flutter pub get
   ```
3. Configurez la clé API OpenWeatherMap dans `lib/screens/HomeScreen.dart` :
   ```dart
   final String weatherApiKey = 'votre_cle_openweathermap';
   ```
4. Lancez l'application :
   ```bash
   flutter run --debug
   ```
5. Testez sur un émulateur ou appareil physique (assurez-vous que l'appareil est sur le même réseau que le backend pour l'URL `http://192.168.1.22/todo/`).

## Configuration

### Backend PHP
- **Base de données** : Utilisez les scripts SQL fournis ci-dessus pour créer `todo_db`, `accounts_table`, et `todo_tables`.
- **Utilisateur MySQL** : L'utilisateur `default-user` est configuré sans mot de passe. Si vous utilisez un mot de passe, mettez à jour `config/database.php`.
- **IP du serveur** : Si vous testez sur un appareil mobile, utilisez votre IP locale (ex. `192.168.1.22`) dans `ApiService.dart`.

### Frontend Flutter
- **Permissions Android** : Dans `android/app/src/main/AndroidManifest.xml`, assurez-vous que les permissions de localisation sont ajoutées :
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```
- **Clé API** : Remplacez `votre_cle_openweathermap` dans `HomeScreen.dart` par votre clé réelle.

### Mode Offline
- Les tâches sont stockées localement dans SQLite (`todo.db`).
- La synchronisation se fait automatiquement lorsque la connexion est rétablie.

## Utilisation

1. **Inscription** :
   - Ouvrez l'application et allez sur "S'inscrire".
   - Entrez un email et un mot de passe.
   - Vous serez redirigé vers l'écran d'accueil.

2. **Connexion** :
   - Entrez vos identifiants pour vous connecter.

3. **Gestion des tâches** :
   - Ajoutez une tâche via le bouton flottant (+).
   - Modifiez ou supprimez une tâche via les icônes.
   - Recherchez via le champ de recherche.
   - Consultez l'historique des tâches accomplies.

4. **Photo de profil** :
   - Cliquez sur l'avatar pour sélectionner une photo depuis la galerie.

5. **Météo et localisation** :
   - La température s'affiche automatiquement (basée sur la localisation).

## Structure des dossiers

```
Projet-Final-Flutter
├── api  # Backend PHP
│   ├── config
│   │   └── database.php
│   ├── methods
│   │   ├── post.php
│   │   ├── get.php
│   │   ├── put.php
│   │   └── delete.php
│   └── main.php
└── flutter  # Frontend Flutter
    ├── android
    ├── ios
    ├── lib
    │   ├── models
    │   │   ├── Todo.dart
    │   │   └── User.dart
    │   ├── providers
    │   │   ├── AuthProvider.dart
    │   │   └── TodoProvider.dart
    │   ├── screens
    │   │   ├── HomeScreen.dart
    │   │   ├── LoginScreen.dart
    │   │   └── RegisterScreen.dart
    │   ├── services
    │   │   ├── ApiService.dart
    │   │   ├── ConnectivityService.dart
    │   │   └── DatabaseHelper.dart
    │   └── main.dart
    ├── pubspec.lock
    ├── pubspec.yaml
    └── README.md
```

## Dépannage

- **Erreur de connexion API** :
  - Vérifiez l'URL dans `ApiService.dart` (ex. `http://192.168.1.22/todo/`).
  - Assurez-vous que le serveur PHP est en cours d'exécution.

- **Erreur de localisation** :
  - Vérifiez les permissions dans `AndroidManifest.xml`.
  - Activez la localisation sur votre appareil.

- **Erreur de base de données** :
  - Supprimez la base SQLite manuellement (voir instructions dans `main.dart`).
  - Vérifiez la structure de `todo_tables` dans phpMyAdmin.

- **Synchronisation offline** :
  - Testez en déconnectant le Wi-Fi : les tâches sont stockées localement.
  - Reconnectez pour synchroniser.

Si vous rencontrez des erreurs, consultez les logs Flutter (`flutter logs`) pour voir les messages `debugPrint`.

## Contribuer

1. Forkez le repository.
2. Créez une branche (`git checkout -b feature/amélioration`).
3. Committez vos changements (`git commit -m 'Ajout d'une fonctionnalité'`).
4. Poussez la branche (`git push origin feature/amélioration`).
5. Ouvrez une Pull Request.

## Licence


Auteur : Mouhamadou Mansour BALDE
Date : Août 2025  
Projet pour Master M1 2024-2025
