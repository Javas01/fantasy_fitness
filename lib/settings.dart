import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const SettingsPage());

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<HealthDataPoint> _healthDataList = [];
  int _nofSteps = 10;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  Future fetchStepData() async {
    List<HealthDataPoint> steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health
            .getHealthDataFromTypes(midnight, now, [HealthDataType.STEPS]);

        print(steps.map((e) => e.value));
      } catch (error) {
        print('Caught exception in getTotalStepsInInterval: $error');
      }

      // setState(() {
      //   _nofSteps = (steps == null) ? 0 : steps;
      //   _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      // });
    } else {
      print('Authorization not granted - error in authorization');
    }
  }

  Future fetchHeightData() async {
    List<HealthDataPoint> height;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.HEIGHT]);

    if (requested) {
      try {
        height = await health
            .getHealthDataFromTypes(midnight, now, [HealthDataType.HEIGHT]);

        print(height.map((e) => e.value));
      } catch (error) {
        print('Caught exception in getTotalStepsInInterval: $error');
      }

      // setState(() {
      //   _nofSteps = (steps == null) ? 0 : steps;
      //   _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      // });
    } else {
      print('Authorization not granted - error in authorization');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.height),
            onPressed: () {
              fetchHeightData();
            },
          ),
          IconButton(
            onPressed: () {
              fetchStepData();
            },
            icon: const Icon(Icons.nordic_walking),
          ),
        ],
      ),
    );
  }
}
