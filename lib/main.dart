import 'package:fantasy_fitness/auth_manager.dart';
import 'package:fantasy_fitness/choose_goal.dart';
import 'package:fantasy_fitness/constants.dart';
import 'package:fantasy_fitness/home.dart';
import 'package:fantasy_fitness/signin.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Fitness',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: supabase.auth.currentUser?.id != null
          ? const ChooseGoal()
          : const SignInPage(),
    );
  }
}
