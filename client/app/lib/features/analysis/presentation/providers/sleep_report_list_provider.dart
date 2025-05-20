import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report_model.dart';

final sleepReportListProvider =
    FutureProvider.family<List<SleepReportModel>, DateTime>((ref, date) async {
      final dio = ref.read(dioClientProvider);

      final now = DateTime.now();
      final response = await dio.get(
        AppConfig.api.sleep.reportByDate(now.toIso8601String()),
      );
      final data = response as List;
      return data.map((e) => SleepReportModel.fromJson(e)).toList();
    });
