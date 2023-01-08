import 'package:fantasy_fitness/constants.dart';
import 'package:fantasy_fitness/models/user.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: supabase
          .from('users')
          .select<List>('fit_points, user_name')
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
          return const Center(child: CircularProgressIndicator());
        } else {
          final users = snapshot.data!.map((e) => User.fromJson(e));
          return ListView(
            children: users
                .map(
                  (user) => ListTile(
                    title: Text(
                      user.userName,
                    ),
                    trailing: Text(user.fitPoints.toString()),
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }
}
