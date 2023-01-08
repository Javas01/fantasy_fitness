import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController smsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.black,
                  ),
                  foregroundColor: MaterialStatePropertyAll(
                    Colors.white,
                  ),
                ),
                onPressed: () async {
                  try {
                    await supabase.auth.signInWithOAuth(
                      Provider.apple,
                      redirectTo:
                          'com.Jawwaad.FantasyFitness://login-callback/',
                    );
                  } on AuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message)),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.apple,
                      size: 30,
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    Text(
                      'Sign In With Apple',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  // minimumSize: MaterialStateProperty.all(const Size(100, 50)),
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.white,
                  ),
                  foregroundColor: MaterialStatePropertyAll(Colors.black),
                ),
                onPressed: () async {
                  try {
                    await supabase.auth.signInWithOAuth(
                      Provider.google,
                      redirectTo:
                          'com.Jawwaad.FantasyFitness://login-callback/',
                    );
                  } on AuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message)),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.network(
                        'http://pngimg.com/uploads/google/google_PNG19635.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    const Text(
                      'Sign In With Google',
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
