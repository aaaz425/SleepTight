import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/coach/data/models/sleep_coach_model.dart';

Future<List<SleepCoachModel>> fetchSleepCoach(
  WidgetRef ref,
  DateTime date,
) async {
  final dio = ref.read(dioClientProvider);
  final response = await dio.get(
    AppConfig.api.sleep.coaching(date.toIso8601String()),
  );

  final data = response as List;

  return data.map((e) => SleepCoachModel.fromJson(e)).toList();
}
