import 'package:fantasy_fitness/constants.dart';
import 'package:fantasy_fitness/screens/home.dart';
import 'package:fantasy_fitness/screens/signin.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Fitness',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: _getLandingPage(),
    );
  }
}

Widget _getLandingPage() {
  return StreamBuilder(
    stream: supabase.auth.onAuthStateChange,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return FutureBuilder(
          future: supabase
              .from('users')
              .select()
              .eq('id', supabase.auth.currentUser?.id)
              .single(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const HomePage();
            }
          },
        );
      } else {
        return const SignInPage();
      }
    },
  );
}
