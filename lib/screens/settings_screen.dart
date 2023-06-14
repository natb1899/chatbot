import 'package:chatbot/screens/profile_screen.dart';
import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Settings'),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Profile'),
            subtitle: const Text(
              'View and edit your profile',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the profile screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Dark mode'),
            subtitle: const Text(
              'Enable or disable dark mode',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text(
              'Select your language',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: DropdownButton<String>(
              value: 'English',
              onChanged: (value) {},
              items: const [
                DropdownMenuItem(
                  value: 'English',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'Spanish',
                  child: Text('German'),
                ),
                DropdownMenuItem(
                  value: 'French',
                  child: Text('French'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
