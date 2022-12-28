import 'package:fantasy_fitness/home.dart';
import 'package:fantasy_fitness/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthManager {
  Future<void> signInUser(
    context, {
    required String phone,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        phone: phone,
        password: password,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
