import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:chatbot/utils/helper_widgets.dart';
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
          const VerticalSpace(50),
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
          ListTile(
            title: const Text('Logout'),
            subtitle: const Text('Log out of your account'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
