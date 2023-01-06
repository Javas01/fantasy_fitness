import 'package:fantasy_fitness/screens/choose_goal.dart';
import 'package:fantasy_fitness/constants.dart';
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
      print('object');
      if (snapshot.hasData) {
        print('this ${snapshot.data}');
        return FutureBuilder(
          future: supabase
              .from('users')
              .select()
              .eq('id', supabase.auth.currentUser?.id)
              .single(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return const ChooseGoal();
            } else {
              return const ChooseGoal();
            }
          },
        );
      } else {
        print('this ${snapshot.data}');

        return const SignInPage();
      }
    },
  );
}
