import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';

import '../models/requests/update_sleep_diary_request.dart';
import '../models/responses/sleep_diary_response.dart';

/// 수면 일지 원격 데이터 소스
abstract class SleepDiaryRemoteDataSource {
  /// 수면 일지 단건 조회
  /// GET api/sleep-reports/diaries/{reportId}
  Future<SleepDiaryResponse> fetchSleepDiary(int reportId);

  /// 날짜별 수면 일지 조회
  /// GET api/sleep-reports/diaries/date/{date}
  Future<List<SleepDiaryResponse>> fetchSleepDiariesByDate(String date);

  /// 수면 일지 수정
  /// PATCH api/sleep-reports/diaries/{reportId}
  Future<SleepDiaryResponse> updateSleepDiary(UpdateSleepDiaryRequest request);
}

class SleepDiaryRemoteDataSourceImpl implements SleepDiaryRemoteDataSource {
  final Dio dio;
  final ApiPaths apiPaths;

  SleepDiaryRemoteDataSourceImpl(this.dio, this.apiPaths);

  @override
  Future<SleepDiaryResponse> fetchSleepDiary(int reportId) async {
    final response = await dio.get(apiPaths.sleep.diaryById(reportId));
    return SleepDiaryResponse.fromJson(response.data);
  }

  @override
  Future<List<SleepDiaryResponse>> fetchSleepDiariesByDate(String date) async {
    final response = await dio.get(apiPaths.sleep.diaryByDate(date));
    return (response.data as List)
        .map((e) => SleepDiaryResponse.fromJson(e))
        .toList();
  }

  @override
  Future<SleepDiaryResponse> updateSleepDiary(
    UpdateSleepDiaryRequest request,
  ) async {
    final response = await dio.patch(
      apiPaths.sleep.updateDiary,
      data: request.toJson(),
    );
    return SleepDiaryResponse.fromJson(response.data);
  }
}

final sleepDiaryRemoteDataSourceProvider = Provider<SleepDiaryRemoteDataSource>(
  (ref) {
    final dio = ref.watch(dioClientProvider).dio;
    final apiPaths = ApiPaths(); // API 경로 관리 객체
    return SleepDiaryRemoteDataSourceImpl(dio, apiPaths);
  },
);
