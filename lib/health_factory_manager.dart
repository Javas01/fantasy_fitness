import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthFactoryManager {
  HealthFactoryManager() {}
  HealthFactory health = HealthFactory();

  Future<List<HealthDataPoint>> fetchStepData() async {
    List<HealthDataPoint> steps;

    final now = DateTime.now();
    await Permission.activityRecognition.request();
    await Permission.locationWhenInUse.request();

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getHealthDataFromTypes(
          now.subtract(const Duration(days: 30)),
          now,
          [
            HealthDataType.STEPS,
            // HealthDataType.DISTANCE_WALKING_RUNNING,
          ],
        );
        print(steps);

        return steps;
      } catch (error) {
        print('Caught error: $error');
        return [];
      }
    } else {
      print('Authorization not granted - error in authorization');
      return [];
    }
  }

  Future fetchHeightData() async {
    List<HealthDataPoint> height;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.HEIGHT]);

    if (requested) {
      try {
        height = await health.getHealthDataFromTypes(
          midnight.subtract(const Duration(days: 10)),
          now,
          [HealthDataType.HEIGHT],
        );

        print(height.map((e) => e.value));
      } catch (error) {
        print('Caught error: $error');
      }
    } else {
      print('Authorization not granted - error in authorization');
    }
  }
}
