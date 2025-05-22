import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';

Future<List<DateTime>> fetchSleepDates(WidgetRef ref, DateTime date) async {
  final dio = ref.read(dioClientProvider);

  final response = await dio.get(
    AppConfig.api.sleep.reportCalendarByMonth,
    queryParameters: {'year': date.year, 'month': date.month},
  );

  final data = response as Map<String, dynamic>;
  final dayList = List<int>.from(data['date'] ?? []);

  return dayList.map((day) => DateTime(date.year, date.month, day)).toList();
}
