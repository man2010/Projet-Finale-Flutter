// Importation du package Flutter pour les widgets Material Design
import 'package:flutter/material.dart';

// Importation du package provider pour accéder au provider
import 'package:provider/provider.dart';

// Importation de fluttertoast pour afficher des messages
import 'package:fluttertoast/fluttertoast.dart';

// Importation de RegisterScreen pour la navigation
import 'RegisterScreen.dart';

// Importation d'AuthProvider pour gérer l'authentification
import '../providers/AuthProvider.dart';

// Importation du modèle User
import '../models/User.dart';

// Importation de HomeScreen pour la redirection après connexion
import 'HomeScreen.dart';

// Classe LoginScreen pour l'écran de connexion
class LoginScreen extends StatefulWidget {
  // Constructeur constant
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// État de LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs pour les champs email et mot de passe
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Méthode pour gérer la connexion
  Future<void> _login() async {
    debugPrint('LoginScreen: Début de la tentative de connexion');
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      final user = User(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint('LoginScreen: Connexion avec email: ${user.email}');
      await provider.login(user);
      if (provider.currentUser != null) {
        debugPrint(
          'LoginScreen: Connexion réussie, redirection vers HomeScreen',
        );
        Fluttertoast.showToast(
          msg: 'Connexion réussie',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (provider.errorMessage != null) {
        debugPrint(
          'LoginScreen: Erreur de connexion: ${provider.errorMessage}',
        );
        Fluttertoast.showToast(
          msg: provider.errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        debugPrint('LoginScreen: Échec de connexion sans message d\'erreur');
        Fluttertoast.showToast(
          msg: 'Échec de la connexion, veuillez réessayer',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      debugPrint('LoginScreen: Validation du formulaire échouée');
      Fluttertoast.showToast(
        msg: 'Veuillez vérifier vos informations',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Méthode build pour construire l'interface
  @override
  Widget build(BuildContext context) {
    debugPrint('LoginScreen: Construction de l\'interface');
    // Accès à AuthProvider
    final provider = Provider.of<AuthProvider>(context);

    // Scaffold pour l'écran
    return Scaffold(
      // Barre d'application
      appBar: AppBar(
        // Titre centré
        title: const Text('Connexion'),
        centerTitle: true,
      ),
      // Corps de l'écran
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Champ pour l'email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    debugPrint('LoginScreen: Champ email vide');
                    return 'Veuillez entrer un email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    debugPrint('LoginScreen: Format email invalide');
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              // Espacement vertical
              const SizedBox(height: 16),
              // Champ pour le mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    debugPrint('LoginScreen: Champ mot de passe vide');
                    return 'Veuillez entrer un mot de passe';
                  }
                  return null;
                },
              ),
              // Espacement vertical
              const SizedBox(height: 16),
              // Indicateur de chargement
              if (provider.isLoading) const CircularProgressIndicator(),
              // Affichage des erreurs
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              // Bouton de connexion
              ElevatedButton(
                onPressed: _login,
                child: const Text('Se connecter'),
              ),
              // Espacement vertical
              const SizedBox(height: 8),
              // Bouton pour aller à l'inscription
              TextButton(
                onPressed: () {
                  debugPrint('LoginScreen: Navigation vers RegisterScreen');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
