import 'package:fantasy_fitness/screens/create_challenge.dart';
import 'package:fantasy_fitness/screens/fitmoji.dart';
import 'package:fantasy_fitness/health_factory_manager.dart';
import 'package:fantasy_fitness/screens/history.dart';
import 'package:fantasy_fitness/screens/leaderboard.dart';
import 'package:fantasy_fitness/screens/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final healthFactory = HealthFactoryManager();

  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const FitmojiPage(),
    const LeaderboardPage(),
    const CreateChallengePage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fantasy Fitness'),
      ),
      body: FutureBuilder(
        future: healthFactory.fetchFitnessData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Text('Error getting data');
          } else {
            return _widgetOptions.elementAt(_selectedIndex);
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 45,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.run_circle),
            label: 'FitMoji',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_work),
            label: 'Challenge',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
