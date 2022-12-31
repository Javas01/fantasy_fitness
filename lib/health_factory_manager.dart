import 'package:health/health.dart';

class HealthFactoryManager {
  HealthFactory health = HealthFactory();

  Future<List<HealthDataPoint>> fetchStepData() async {
    List<HealthDataPoint> steps;

    final now = DateTime.now();

    bool requested = await health.requestAuthorization(
        [HealthDataType.WORKOUT, HealthDataType.DISTANCE_WALKING_RUNNING]);

    if (requested) {
      try {
        steps = await health.getHealthDataFromTypes(
          now.subtract(Duration(days: 300)),
          now,
          [
            HealthDataType.WORKOUT,
            HealthDataType.DISTANCE_WALKING_RUNNING,
          ],
        );

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
          midnight.subtract(Duration(days: 10)),
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
