import 'package:fantasy_fitness/home.dart';
import 'package:flutter/material.dart';

class ChooseGoal extends StatefulWidget {
  const ChooseGoal({
    super.key,
  });

  @override
  State<ChooseGoal> createState() => _ChooseGoalState();
}

class _ChooseGoalState extends State<ChooseGoal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Pick a Fitness Goal')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('images/skinny_guy.jpg'),
                          const Text(
                            'This is what your fitmoji will look like to start',
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const HomePage(),
                            ),
                            (route) => false,
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      'Strength',
                      textScaleFactor: 2,
                    ),
                    Image.asset('images/strength_goal.jpg'),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('images/fat_guy.jpg'),
                          const Text(
                            'This is what your fitmoji will look like to start',
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const HomePage(),
                            ),
                            (route) => false,
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      'Cardio',
                      textScaleFactor: 2,
                    ),
                    Image.asset('images/cardio_goal.jpg'),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
