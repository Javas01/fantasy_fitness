import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
const title = [Text('Fitmoji'), Text('Challenge'), Text('Store')];

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}

class Challenge {
  String text;
  ChallengeCategory category;
  ChallengeType type;
  bool isComplete;

  Challenge({
    required this.text,
    required this.category,
    required this.type,
    required this.isComplete,
  });
}

enum ChallengeType {
  mile,
}

enum ChallengeCategory { running, biking, swimming }

/// Environment variables and shared app constants.
abstract class Constants {
  static const String supabaseUrl = 'https://ifmdrwaxqbrlpqtoznqn.supabase.co';

  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: '',
  );
}
