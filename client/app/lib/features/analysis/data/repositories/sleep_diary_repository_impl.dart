import 'package:sleep_tight/features/analysis/data/datasources/sleep_diary_remote_data_source.dart';
import 'package:sleep_tight/features/analysis/data/models/responses/sleep_diary_response.dart';
import 'package:sleep_tight/features/analysis/data/models/requests/update_sleep_diary_request.dart';
import 'package:sleep_tight/features/analysis/domain/repositories/sleep_diary_repository.dart';

class SleepDiaryRepositoryImpl implements SleepDiaryRepository {
  final SleepDiaryRemoteDataSource remoteDataSource;

  SleepDiaryRepositoryImpl(this.remoteDataSource);

  @override
  Future<SleepDiaryResponse> fetchSleepDiary(int reportId) {
    return remoteDataSource.fetchSleepDiary(reportId);
  }

  @override
  Future<List<SleepDiaryResponse>> fetchSleepDiariesByDate(String date) {
    return remoteDataSource.fetchSleepDiariesByDate(date);
  }

  @override
  Future<SleepDiaryResponse> updateSleepDiary(UpdateSleepDiaryRequest request) {
    return remoteDataSource.updateSleepDiary(request);
  }
}
