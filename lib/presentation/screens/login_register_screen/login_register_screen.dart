import 'package:chatbot/data/datasources/firebase/auth.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = "";
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      // Calls the signInWithEmailAndPassword method from the Auth class
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text
            .trim(), // Retrieves the email value from the _emailController
        password: _passwordController.text
            .trim(), // Retrieves the password value from the _passwordController
      );
    } on FirebaseAuthException catch (e) {
      // Catches any FirebaseAuthException that occurs during the sign-in process
      setState(
        () {
          errorMessage =
              e.message; // Sets the error message to the exception's message
        },
      );
    }
  }

  Future<void> signUpWithEmailAndPassword() async {
    try {
      // Calls the signUpWithEmailAndPassword method from the Auth class
      await Auth().signUpWithEmailAndPassword(
        email: _emailController.text
            .trim(), // Retrieves the email value from the _emailController
        password: _passwordController.text
            .trim(), // Retrieves the password value from the _passwordController
      );
    } on FirebaseAuthException catch (e) {
      // Catches any FirebaseAuthException that occurs during the sign-up process
      setState(
        () {
          errorMessage =
              e.message; // Sets the error message to the exception's message
        },
      );
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      obscureText: title == "password" ? true : false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == "" ? "" : "Humm ? $errorMessage");
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : signUpWithEmailAndPassword,
      child: Text(isLogin ? "Login" : "Register"),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(
          () {
            isLogin = !isLogin;
          },
        );
      },
      child: Text(
        isLogin
            ? "Don't have an account? Register"
            : "Already have an account? Login",
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: isLogin ? Colors.white : Colors.grey[200],
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 50,
              width: 50,
            ),
            const VerticalSpace(20),
            _entryField("email", _emailController),
            const VerticalSpace(20),
            _entryField("password", _passwordController),
            _errorMessage(),
            _submitButton(),
            const VerticalSpace(10),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
