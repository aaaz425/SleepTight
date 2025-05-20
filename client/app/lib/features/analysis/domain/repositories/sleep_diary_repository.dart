import 'package:sleep_tight/features/analysis/data/models/responses/sleep_diary_response.dart';
import 'package:sleep_tight/features/analysis/data/models/requests/update_sleep_diary_request.dart';

abstract class SleepDiaryRepository {
  // 수면 일지 단건 조회
  Future<SleepDiaryResponse> fetchSleepDiary(int reportId);

  // 날짜별 수면 일지 조회
  Future<List<SleepDiaryResponse>> fetchSleepDiariesByDate(String date);

  // 수면 일지 수정
  Future<SleepDiaryResponse> updateSleepDiary(UpdateSleepDiaryRequest request);
}
