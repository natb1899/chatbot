import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:chatbot/utils/gender_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GenderProvider _genderProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _genderProvider = Provider.of<GenderProvider>(context);
  }

  void _handleSexChange(bool value) {
    _genderProvider.isMan = value;
  }

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
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text(
              'Select your sex',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                  value: true,
                  groupValue: _genderProvider.isMan,
                  onChanged: (value) => _handleSexChange(value!),
                  activeColor:
                      Colors.blue, // Change the color of the radio button
                ),
                Radio(
                  value: false,
                  groupValue: _genderProvider.isMan,
                  onChanged: (value) => _handleSexChange(value!),
                  activeColor:
                      Colors.blue, // Change the color of the radio button
                ),
              ],
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
