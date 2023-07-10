import 'package:chatbot/presentation/provider/model_provider.dart';
import 'package:chatbot/theme/app_bar_theme.dart';
import 'package:chatbot/presentation/provider/gender_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GenderProvider _genderProvider;
  late ModelProvider _modelProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _genderProvider = Provider.of<GenderProvider>(context);
    _modelProvider = Provider.of<ModelProvider>(context);
  }

  void _handleGenderChange(bool value) {
    _genderProvider.isMan = value;
  }

  void _handleModelChange(String value) {
    _modelProvider.setModel = value;
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
              'Select your gender',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                  value: true,
                  groupValue: _genderProvider.isMan,
                  onChanged: (value) => _handleGenderChange(value!),
                  activeColor:
                      Colors.blue, // Change the color of the radio button
                ),
                Radio(
                  value: false,
                  groupValue: _genderProvider.isMan,
                  onChanged: (value) => _handleGenderChange(value!),
                  activeColor:
                      Colors.blue, // Change the color of the radio button
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('GPT-Model'),
            subtitle: const Text(
              'Select the model',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: DropdownButton<String>(
              value: _modelProvider.model,
              onChanged: (value) => _handleModelChange(value!),
              items: const [
                DropdownMenuItem(
                  value: 'gpt-3.5-turbo',
                  child: Text('GPT3.5-Turbo'),
                ),
                DropdownMenuItem(
                  value: 'gpt-4',
                  child: Text('GPT-4'),
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
