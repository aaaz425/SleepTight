import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report.dart';

Future<List<SleepReport>> fetchSleepReports(
  WidgetRef ref,
  DateTime date,
) async {
  final dio = ref.read(dioClientProvider);
  final response = await dio.get(
    AppConfig.api.sleep.reportByDate(date.toIso8601String()),
  );

  final data = response as List;
  return data.map((e) => SleepReport.fromJson(e)).toList();
}
