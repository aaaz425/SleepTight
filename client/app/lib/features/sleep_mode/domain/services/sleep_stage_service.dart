import 'package:sleep_tight/features/health/services/health_service.dart';
import 'package:health/health.dart';

Future<List<Map<String, dynamic>>> getSleepStages({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final healthService = HealthService();

  try {
    List<HealthDataPoint> sleepData = await healthService.fetchSleepData(
      startDate,
      endDate,
    );

    if (sleepData.isEmpty) {
      return [];
    }

    return sleepData.map((stage) {
      return {
        "stageType": stage.typeString.replaceAll(
          'SLEEP_',
          '',
        ), // 예: 'AWAKE', 'LIGHT' 등
        "startTime": stage.dateFrom.toUtc().toIso8601String(),
        "endTime": stage.dateTo.toUtc().toIso8601String(),
      };
    }).toList();
  } catch (e) {
    return [];
  }
}
