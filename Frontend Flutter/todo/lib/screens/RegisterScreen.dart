// Importation du package Flutter pour les widgets Material Design
import 'package:flutter/material.dart';

// Importation du package provider pour accéder au provider
import 'package:provider/provider.dart';

// Importation de fluttertoast pour afficher des messages
import 'package:fluttertoast/fluttertoast.dart';

// Importation d'AuthProvider pour gérer l'authentification
import '../providers/AuthProvider.dart';

// Importation du modèle User
import '../models/User.dart';

// Importation de LoginScreen pour la navigation
import 'LoginScreen.dart';

// Importation de HomeScreen pour la redirection après inscription
import 'HomeScreen.dart';

// Classe RegisterScreen pour l'écran d'inscription
class RegisterScreen extends StatefulWidget {
  // Constructeur constant
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

// État de RegisterScreen
class _RegisterScreenState extends State<RegisterScreen> {
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

  // Méthode pour gérer l'inscription
  Future<void> _register() async {
    debugPrint('RegisterScreen: Début de la tentative d\'inscription');
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      final user = User(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint('RegisterScreen: Inscription avec email: ${user.email}');
      await provider.register(user);
      if (provider.currentUser != null) {
        debugPrint(
          'RegisterScreen: Inscription réussie, redirection vers HomeScreen',
        );
        Fluttertoast.showToast(
          msg: 'Inscription réussie',
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
          'RegisterScreen: Erreur d\'inscription: ${provider.errorMessage}',
        );
        Fluttertoast.showToast(
          msg: provider.errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        debugPrint(
          'RegisterScreen: Échec d\'inscription sans message d\'erreur',
        );
        Fluttertoast.showToast(
          msg: 'Échec de l\'inscription, veuillez réessayer',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      debugPrint('RegisterScreen: Validation du formulaire échouée');
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
    debugPrint('RegisterScreen: Construction de l\'interface');
    // Accès à AuthProvider
    final provider = Provider.of<AuthProvider>(context);

    // Scaffold pour l'écran
    return Scaffold(
      // Barre d'application
      appBar: AppBar(
        // Titre centré
        title: const Text('Inscription'),
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
                    debugPrint('RegisterScreen: Champ email vide');
                    return 'Veuillez entrer un email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    debugPrint('RegisterScreen: Format email invalide');
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
                    debugPrint('RegisterScreen: Champ mot de passe vide');
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
              // Bouton d'inscription
              ElevatedButton(
                onPressed: _register,
                child: const Text('S\'inscrire'),
              ),
              // Espacement vertical
              const SizedBox(height: 8),
              // Bouton pour aller à la connexion
              TextButton(
                onPressed: () {
                  debugPrint('RegisterScreen: Navigation vers LoginScreen');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
