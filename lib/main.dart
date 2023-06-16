import 'package:chatbot/screens/profile_screen.dart';
import 'package:chatbot/screens/settings_screen.dart';
import 'package:chatbot/screens/tree_screen.dart';
import 'package:chatbot/theme/light_theme.dart';
import 'package:chatbot/utils/gender_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GenderProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      //darkTheme: darkTheme,
      home: const Scaffold(
        body: Tree(),
      ),
      routes: {
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const ProfileScreen(), // Register AnotherPage route
      },
    );
  }
}
