import 'package:fantasy_fitness/constants.dart';
import 'package:fantasy_fitness/health_factory_manager.dart';
import 'package:flutter/material.dart';

class FitmojiPage extends StatefulWidget {
  const FitmojiPage({super.key});

  @override
  State<FitmojiPage> createState() => _FitmojiPageState();
}

class _FitmojiPageState extends State<FitmojiPage> {
  final healthFactory = HealthFactoryManager();
  List<Challenge> challenges = [
    Challenge(
      text: 'Run a mile',
      category: ChallengeCategory.running,
      type: ChallengeType.mile,
      isComplete: false,
    ),
    Challenge(
      text: 'Swim a mile',
      category: ChallengeCategory.swimming,
      type: ChallengeType.mile,
      isComplete: false,
    ),
    Challenge(
      text: 'Bike a mile',
      category: ChallengeCategory.biking,
      type: ChallengeType.mile,
      isComplete: false,
    )
  ];

  @override
  Widget build(BuildContext context) {
    healthFactory.fetchStepData();
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
                return Text(
                  '$name - FitLvl $level',
                  textScaleFactor: 1.75,
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
          const LinearProgressIndicator(
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
            height: 20,
          ),
          Expanded(
            child: ListView(
              children: challenges
                  .map(
                    (e) => DailyChallengeListItem(challenge: e),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}

class DailyChallengeListItem extends StatelessWidget {
  const DailyChallengeListItem({Key? key, required this.challenge})
      : super(key: key);

  final Challenge challenge;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        children: [
          CircleAvatar(
            child: challenge.isComplete ? const Icon(Icons.check) : null,
          ),
          const SizedBox(
            width: 20,
          ),
          Text(challenge.text)
        ],
      ),
    );
  }
}
