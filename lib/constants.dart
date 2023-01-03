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
  ChallengeDifficulty difficulty;
  bool isComplete;

  Challenge({
    required this.text,
    required this.category,
    required this.type,
    required this.isComplete,
    required this.difficulty,
  });
}

enum ChallengeType {
  mile,
}

const pointsToLevelUp = [
  100,
  100,
  200,
  300,
  400,
  500,
  600,
  700,
  800,
  900,
  1000
];

enum ChallengeDifficulty { easy, medium, hard, pro }

enum ChallengeCategory { running, biking, swimming }

/// Environment variables and shared app constants.
abstract class Constants {
  static const String supabaseUrl = 'https://ifmdrwaxqbrlpqtoznqn.supabase.co';

  static const String supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: '',
  );
}
