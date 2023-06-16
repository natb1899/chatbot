import 'package:chatbot/screens/home_screen.dart';
import 'package:chatbot/screens/login_register_screen.dart';
import 'package:chatbot/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Tree extends StatefulWidget {
  const Tree({super.key});

  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
