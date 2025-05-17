import 'package:sleep_tight/features/health/services/health_service.dart';
import 'package:health/health.dart';

Future<List<Map<String, dynamic>>> getActivityData(
  DateTime start,
  DateTime end,
) async {
  final healthService = HealthService();
  final List<HealthDataPoint> data = await healthService.fetchActivityData(
    start,
    end,
  );

  final Map<String, num> totals = {
    "WATER": 0,
    "MOMENTUM": 0,
    "TOTAL_ENERGY_BURNED": 0,
    "WALK": 0,
    "CAFFEINE": 0,
    "CALORIES": 0,
    "CHOLESTEROL": 0,
    "VITAMIN_D": 0,
    "SUGAR": 0,
  };

  for (final point in data) {
    final type = point.type;

    if (type == HealthDataType.WATER && point.value is NumericHealthValue) {
      final value = (point.value as NumericHealthValue).numericValue;
      totals["WATER"] = totals["WATER"]! + value;
    } else if (type == HealthDataType.WORKOUT &&
        point.value is WorkoutHealthValue) {
      final workout = point.value as WorkoutHealthValue;

      final seconds = point.dateTo.difference(point.dateFrom).inSeconds;
      totals["MOMENTUM"] = totals["MOMENTUM"]! + seconds;

      if (workout.totalEnergyBurned != null) {
        totals["TOTAL_ENERGY_BURNED"] =
            totals["TOTAL_ENERGY_BURNED"]! + workout.totalEnergyBurned!;
      }
    } else if (type == HealthDataType.STEPS &&
        point.value is NumericHealthValue) {
      final value = (point.value as NumericHealthValue).numericValue;
      totals["WALK"] = totals["WALK"]! + value;
    } else if (type == HealthDataType.NUTRITION &&
        point.value is NutritionHealthValue) {
      final n = point.value as NutritionHealthValue;

      if (n.caffeine != null) {
        totals["CAFFEINE"] = totals["CAFFEINE"]! + n.caffeine!;
      }
      if (n.calories != null) {
        totals["CALORIES"] = totals["CALORIES"]! + n.calories!;
      }
      if (n.cholesterol != null) {
        totals["CHOLESTEROL"] = totals["CHOLESTEROL"]! + n.cholesterol!;
      }
      if (n.vitaminD != null) {
        totals["VITAMIN_D"] = totals["VITAMIN_D"]! + n.vitaminD!;
      }
      if (n.sugar != null) totals["SUGAR"] = totals["SUGAR"]! + n.sugar!;
    }
  }

  return [
    {"dataType": "WATER", "value": totals["WATER"], "unit": "LITER"},
    {"dataType": "MOMENTUM", "value": totals["MOMENTUM"], "unit": "SECOND"},
    {
      "dataType": "TOTAL_ENERGY_BURNED",
      "value": totals["TOTAL_ENERGY_BURNED"],
      "unit": "KILOCALORIE",
    },
    {"dataType": "WALK", "value": totals["WALK"], "unit": "STEP"},
    {"dataType": "CAFFEINE", "value": totals["CAFFEINE"], "unit": "GRAMS"},
    {
      "dataType": "CALORIES",
      "value": totals["CALORIES"],
      "unit": "KILOCALORIE",
    },
    {
      "dataType": "CHOLESTEROL",
      "value": totals["CHOLESTEROL"],
      "unit": "GRAMS",
    },
    {"dataType": "VITAMIN_D", "value": totals["VITAMIN_D"], "unit": "GRAMS"},
    {"dataType": "SUGAR", "value": totals["SUGAR"], "unit": "GRAMS"},
  ];
}
