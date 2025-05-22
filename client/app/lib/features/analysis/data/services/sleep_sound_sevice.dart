import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_sound_model.dart';

Future<List<SleepSoundModel>> fetchSleepSounds(
  WidgetRef ref,
  int reportId,
) async {
  final dio = ref.read(dioClientProvider);

  final response = await dio.get(
    AppConfig.api.sleep.eventsByReportId(reportId),
  );

  final sounds = response['sounds'] as List;

  final firstTen = sounds.take(10).toList();

  return firstTen.map((e) => SleepSoundModel.fromJson(e)).toList();
}
