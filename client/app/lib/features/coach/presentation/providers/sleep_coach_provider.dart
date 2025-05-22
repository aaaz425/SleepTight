import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/coach/data/datasources/sleep_coach_remote_data_source.dart';
import 'package:sleep_tight/features/coach/data/repositories/sleep_coach_repository_impl.dart';
import 'package:sleep_tight/features/coach/domain/repositories/sleep_coach_repository.dart';

class SleepCoachingItem {
  final String activity;
  final String type;
  final String value;
  final String description;

  SleepCoachingItem({
    required this.activity,
    required this.type,
    required this.value,
    required this.description,
  });

  factory SleepCoachingItem.fromJson(Map<String, dynamic> json) {
    return SleepCoachingItem(
      activity: json['activity'],
      type: json['type'],
      value: json['value'],
      description: json['description'],
    );
  }
}

final sleepCoachingProvider =
    FutureProvider.family<List<SleepCoachingItem>, String>((ref, date) async {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.get(AppConfig.api.sleep.coaching(date));
      final data = response.data['data'] as List;
      return data.map((e) => SleepCoachingItem.fromJson(e)).toList();
    });

final sleepCoachRepositoryProvider = Provider<SleepCoachRepository>((ref) {
  final remoteDataSource = ref.read(sleepCoachRemoteDataSourceProvider);
  return SleepCoachRepositoryImpl(remoteDataSource);
});
