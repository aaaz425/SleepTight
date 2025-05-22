import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report_model.dart';
import 'package:intl/intl.dart';

Future<List<SleepReportModel>> fetchSleepReports(
  WidgetRef ref,
  DateTime date,
) async {
  final dio = ref.read(dioClientProvider);
  final formatted = DateFormat('yyyy-MM-dd').format(date.toUtc());

  final response = await dio.get(AppConfig.api.sleep.reportByDate(formatted));

  final data = response as List;

  return data.map((e) => SleepReportModel.fromJson(e)).toList();
}
