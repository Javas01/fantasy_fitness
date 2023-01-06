import 'package:fantasy_fitness/auth_manager.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SettingsPage());

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authManager = AuthManager();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              _authManager.logOut(
                context,
              );
            },
            child: const Text('L og Out'),
          )
        ],
      ),
    );
  }
}
