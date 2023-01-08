import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';

class HealthFactoryManager {
  HealthFactory health = HealthFactory();
  static List<HealthDataPoint> allData = [];
  static List<HealthDataPoint> steps = [];
  static List<HealthDataPoint> workouts = [];
  static List<HealthDataPoint> sleep = [];

  Future<void> fetchFitnessData() async {
    if (supabase.auth.currentUser == null) {
      return;
    }
    Map data = await supabase
        .from('users')
        .select('last_opened')
        .eq('id', supabase.auth.currentUser?.id ?? '')
        .single();
    String? lastOpened = data['last_opened'];
    final now = DateTime.now();
    await Permission.activityRecognition.request();
    await Permission.locationWhenInUse.request();

    bool requested = await health.requestAuthorization(
      [
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.WORKOUT
      ],
    );

    if (requested) {
      try {
        List<HealthDataPoint> data = await health.getHealthDataFromTypes(
          lastOpened != null
              ? DateTime.parse(lastOpened)
              : now.subtract(
                  const Duration(days: 1),
                ),
          now,
          [
            HealthDataType.SLEEP_ASLEEP,
            HealthDataType.STEPS,
            HealthDataType.WORKOUT,
          ],
        );
        allData = data;
        steps = data.where((e) => e.type == HealthDataType.STEPS).toList();
        workouts = data.where((e) => e.type == HealthDataType.WORKOUT).toList();
        sleep =
            data.where((e) => e.type == HealthDataType.SLEEP_ASLEEP).toList();
      } catch (error) {
        throw Error();
      }
    } else {
      throw ErrorDescription(
          'Authorization not granted - error in authorization');
    }
  }
}
