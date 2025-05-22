import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/coach/data/models/requests/create_sleep_coaching_request.dart';

abstract class SleepCoachRemoteDataSource {
  Future<void> postSleepCoach(CreateSleepCoachingRequest request);
}

class SleepCoachRemoteDataSourceImpl implements SleepCoachRemoteDataSource {
  final Dio dio;
  final ApiPaths apiPaths;

  SleepCoachRemoteDataSourceImpl(this.dio, this.apiPaths);

  @override
  Future<void> postSleepCoach(CreateSleepCoachingRequest request) async {
    await dio.post(apiPaths.sleep.coachRequest, data: request.toJson());
  }
}

final sleepCoachRemoteDataSourceProvider = Provider<SleepCoachRemoteDataSource>(
  (ref) {
    final dioClient = ref.read(dioClientProvider);
    final apiPaths = ApiPaths();
    return SleepCoachRemoteDataSourceImpl(dioClient.dio, apiPaths);
  },
);
