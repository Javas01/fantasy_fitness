import 'package:fantasy_fitness/home.dart';
import 'package:fantasy_fitness/signin.dart';
import 'package:fantasy_fitness/verify_otp.dart';
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
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> signUpUser(
    context, {
    required String phone,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signUp(
        phone: phone,
        password: password,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOTPPage(
            phone: phone,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> verifyOTPPage(
    context, {
    required String phone,
    required String token,
  }) async {
    try {
      await Supabase.instance.client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
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
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> logOut(context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }
}
