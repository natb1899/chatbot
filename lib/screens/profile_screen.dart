import 'package:chatbot/services/auth.dart';
import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:chatbot/utils/helper_widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DatabaseReference _dbRef;
  late Auth _auth;

  @override
  void initState() {
    super.initState();
    _auth = Auth();
    _dbRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(_auth.currentUser!.uid)
        .child('chats');
  }

  Future<void> _signOut(BuildContext context) async {
    await Auth().signOut(context);
  }

  Widget _buttonSubmit() {
    return ElevatedButton(
      onPressed: () {
        List<Map<String, String>> messages = [
          {'name': 'John Doe', 'email': ''},
          {'name': 'John Doe', 'email': ''},
          {'name': 'John Doe', 'email': ''},
          {'name': 'John Doe', 'email': ''}
        ];
        _dbRef.push().set(messages);
      },
      child: const Text('saves'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Profile'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buttonSubmit(),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50'),
            ),
            const VerticalSpace(16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const VerticalSpace(16),
            const Text(
              'johndoe@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const VerticalSpace(16),
            ElevatedButton(
              onPressed: () {
                _signOut(context);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
