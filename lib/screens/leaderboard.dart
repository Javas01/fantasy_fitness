import 'package:fantasy_fitness/constants.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: supabase
          .from('users')
          .select<List>('id, fit_points, user_name')
          .order('fit_points'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Future.delayed(const Duration(milliseconds: 100), () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error getting Data'),
              ),
            );
          });
          return Container();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return ListView(
            children: snapshot.data!
                .map(
                  (e) => ListTile(
                    title: Text(
                      e['user_name'],
                    ),
                    trailing: Text(e['fit_points'].toString()),
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }
}
