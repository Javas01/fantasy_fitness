import 'package:fantasy_fitness/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class FitmojiPage extends StatefulWidget {
  const FitmojiPage({super.key});

  @override
  State<FitmojiPage> createState() => _FitmojiPageState();
}

class _FitmojiPageState extends State<FitmojiPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          FutureBuilder(
            future: supabase.from('users').select().single(),
            builder: (context, snapshot) {
              if (snapshot.hasError ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Text('');
              } else {
                String name = snapshot.data['name'] as String;
                int level = snapshot.data['level'] as int;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      textScaleFactor: 2,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '- FitLvl $level',
                      textScaleFactor: 2,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Image.asset(
              'images/skinny_guy.jpg',
              width: 300,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // ignore: prefer_const_constructors
          LinearProgressIndicator(
            value: 0.1,
            minHeight: 30,
            semanticsLabel: 'Level up progress indicator',
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(
            'Daily Challenges/Quests',
            textScaleFactor: 2,
          ),
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      child: Icon(Icons.check),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text('Run a mile')
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    CircleAvatar(
                      child: Icon(Icons.check),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text('bike a mile')
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    CircleAvatar(
                      child: Icon(Icons.check),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text('swim a mile')
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    CircleAvatar(
                      child: Icon(Icons.check),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text('walk a mile')
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
