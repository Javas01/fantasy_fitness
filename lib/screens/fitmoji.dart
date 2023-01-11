import 'package:fantasy_fitness/constants.dart';
import 'package:fantasy_fitness/health_factory_manager.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FitmojiPage extends StatefulWidget {
  const FitmojiPage({super.key});

  @override
  State<FitmojiPage> createState() => _FitmojiPageState();
}

double healthDataToFitPoints(HealthDataPoint data) {
  switch (data.type) {
    case HealthDataType.STEPS:
      return (data.value as NumericHealthValue).numericValue * 0.005;
    case HealthDataType.WORKOUT:
      return (data.value as WorkoutHealthValue).totalEnergyBurned! * 0.1;
    case HealthDataType.SLEEP_ASLEEP:
      return (data.value as NumericHealthValue).numericValue / 60;
    default:
      return 0;
  }
}

int getCurrentLevel(points) {
  if (points >= 0 && points < 100) {
    return 1;
  } else if (points >= 100 && points < 200) {
    return 2;
  } else if (points >= 200 && points < 300) {
    return 3;
  } else if (points >= 300 && points < 400) {
    return 4;
  } else if (points >= 400 && points < 500) {
    return 5;
  } else if (points >= 500 && points < 600) {
    return 6;
  } else if (points >= 600 && points < 700) {
    return 7;
  } else if (points >= 700 && points < 800) {
    return 8;
  } else if (points >= 800 && points < 900) {
    return 9;
  } else if (points >= 900) {
    return 10;
  } else {
    return 0;
  }
}

class _FitmojiPageState extends State<FitmojiPage> {
  final healthFactory = HealthFactoryManager();
  final _stream = supabase.from('users').stream(primaryKey: ['id']).eq(
      'id', Supabase.instance.client.auth.currentUser?.id ?? '');

  List<Challenge> challenges = [
    Challenge(
      text: 'Run a mile',
      category: ChallengeCategory.running,
      type: ChallengeType.mile,
      isComplete: false,
      difficulty: ChallengeDifficulty.easy,
    ),
    Challenge(
      text: 'Run 2 miles',
      category: ChallengeCategory.running,
      type: ChallengeType.mile,
      isComplete: false,
      difficulty: ChallengeDifficulty.medium,
    ),
    Challenge(
      text: 'Run 5 mile',
      category: ChallengeCategory.running,
      type: ChallengeType.mile,
      isComplete: false,
      difficulty: ChallengeDifficulty.hard,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: supabase
          .from('users')
          .select()
          .eq('id', supabase.auth.currentUser?.id ?? '')
          .single(),
      builder: (context, snapshot) {
        if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Text('');
        } else {
          double fitPoints = snapshot.data['fit_points'] as double;
          if (HealthFactoryManager.allData.isNotEmpty) {
            Future.delayed(
              const Duration(milliseconds: 10),
              () {
                double total = HealthFactoryManager.steps.fold(
                      0.0,
                      (value, element) =>
                          value + healthDataToFitPoints(element),
                    ) +
                    HealthFactoryManager.workouts.fold(
                      0.0,
                      (value, element) =>
                          value + healthDataToFitPoints(element),
                    ) +
                    HealthFactoryManager.sleep.fold(
                      0.0,
                      (value, element) =>
                          value + healthDataToFitPoints(element),
                    );

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Column(
                      children: [
                        const Text('Fitpoints summary'),
                        Text('Total points = $total points'),
                      ],
                    ),
                    content: Column(
                      children: [
                        Text(
                          'Steps = ${HealthFactoryManager.steps.fold(0.0, (value, element) => value + healthDataToFitPoints(element))} points',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Column(
                          children: HealthFactoryManager.steps
                              .map(
                                (e) => Row(
                                  children: [
                                    Text(
                                      '${e.value}= ${healthDataToFitPoints(e)} points',
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Workouts = ${HealthFactoryManager.workouts.fold(0.0, (value, element) => value + healthDataToFitPoints(element))} points',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Column(
                          children: HealthFactoryManager.workouts
                              .map(
                                (e) => Column(
                                  children: [
                                    Text(
                                      '${(e.value as WorkoutHealthValue).workoutActivityType.toString().substring(26)} = ${healthDataToFitPoints(e)} points',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Calories Burned: ${(e.value as WorkoutHealthValue).totalEnergyBurned}',
                                    ),
                                    (e.value as WorkoutHealthValue)
                                                .totalDistance !=
                                            null
                                        ? Text(
                                            'Distance: ${(e.value as WorkoutHealthValue).totalDistance}',
                                          )
                                        : const Text('No distance Avaliable'),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Sleep = ${HealthFactoryManager.sleep.fold(0.0, (value, element) => value + healthDataToFitPoints(element))} points',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Column(
                          children: HealthFactoryManager.sleep
                              .map(
                                (e) => Row(
                                  children: [
                                    Text(
                                      '${e.value.toString()} = ${healthDataToFitPoints(e)} points',
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          try {
                            await supabase.from('users').update({
                              'fit_points': fitPoints + total,
                              'last_opened': DateTime.now().toIso8601String(),
                            }).match({
                              'id':
                                  Supabase.instance.client.auth.currentUser!.id,
                            });
                            final dataToInsert = HealthFactoryManager.allData
                                .map(
                                  (healthData) => ({
                                    'user_id': currUser!.id,
                                    ...healthData.toJson()
                                  }),
                                )
                                .toList();
                            await supabase
                                .from('fit_data')
                                .insert(dataToInsert);

                            Navigator.pop(context);
                          } catch (e) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
        return StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error getting data');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Getting data');
            }
            double fitPoints = snapshot.data![0]['fit_points'] as double;
            int currLevel = getCurrentLevel(fitPoints);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    supabase.auth.currentUser?.userMetadata?['name'] ?? '',
                    textScaleFactor: 1.75,
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
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(
                      begin: 0,
                      end: fitPoints / pointsToLevelUp[currLevel],
                    ),
                    builder: (context, value, _) => Column(
                      children: [
                        Stack(children: [
                          LinearProgressIndicator(
                            value: value,
                            minHeight: 30,
                            semanticsLabel: 'Level up progress indicator',
                          ),
                          Center(
                            child: Text(
                              'level $currLevel',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ]),
                        Align(
                          alignment: AlignmentGeometry.lerp(
                              const Alignment(-1.04, -1),
                              const Alignment(1.04, -1),
                              value) as AlignmentGeometry,
                          child: Text(
                            '${fitPoints.toString()} / ${pointsToLevelUp[currLevel]}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'Bonus Points',
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
          },
        );
      },
    );
  }
}

class DailyChallengeListItem extends StatelessWidget {
  const DailyChallengeListItem({
    Key? key,
    required this.challenge,
  }) : super(key: key);
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(challenge.difficulty == ChallengeDifficulty.easy
                ? '+5'
                : challenge.difficulty == ChallengeDifficulty.medium
                    ? '+10'
                    : '+25'),
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
