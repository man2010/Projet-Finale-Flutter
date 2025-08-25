import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/screens/LoginScreen.dart';
import 'package:todo/providers/AuthProvider.dart';
import 'package:todo/providers/TodoProvider.dart';

void main() {
  // Assurer l'initialisation des widgets Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Lancer l'application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
      ),
    );
  }
}
