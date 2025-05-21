import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/coach/data/models/sleep_coach_model.dart';
import 'package:sleep_tight/features/coach/data/models/sleep_coach_type_enum.dart';

Future<List<SleepCoachModel>> fetchSleepCoach(
  WidgetRef ref,
  DateTime date,
  List<Map<String, dynamic>> healthDataList,
) async {
  final dio = ref.read(dioClientProvider);
  final response = await dio.get(
    AppConfig.api.sleep.coaching(date.toIso8601String()),
  );

  final data = response as List;

  return data.map((json) {
    final model = SleepCoachModel.fromJson(json);

    final match = healthDataList.firstWhere((item) {
      final dataTypeStr = item['dataType'].toString().toUpperCase();
      final enumFromData = dataTypeToEnumMap[dataTypeStr];
      return enumFromData == model.activity;
    }, orElse: () => {'value': 0});

    return SleepCoachModel(
      activity: model.activity,
      type: model.type,
      value: double.tryParse(match['value'].toString()) ?? 0.0,
      target: model.target,
      description: model.description,
    );
  }).toList();
}

final Map<String, ActivityDataType> dataTypeToEnumMap = {
  'WATER': ActivityDataType.water,
  'TOTAL_ENERGY_BURNED': ActivityDataType.momentum,
  'WALK': ActivityDataType.walk,
  'CAFFEINE': ActivityDataType.caffeine,
};
