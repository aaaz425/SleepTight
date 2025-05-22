import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/analysis/data/datasources/sleep_diary_remote_data_source.dart';
import 'package:sleep_tight/features/analysis/data/repositories/sleep_diary_repository_impl.dart';
import 'package:sleep_tight/features/analysis/domain/entity/sleep_diary_model.dart';
import 'package:sleep_tight/features/analysis/data/models/requests/update_sleep_diary_request.dart';
import 'package:sleep_tight/features/analysis/domain/repositories/sleep_diary_repository.dart';

/// 수면 일지 리포지토리 Provider
final sleepDiaryProvider = Provider<SleepDiaryRepository>((ref) {
  final remoteDataSource = ref.watch(sleepDiaryRemoteDataSourceProvider);
  return SleepDiaryRepositoryImpl(remoteDataSource);
});

/// 단일 수면 일지 조회 Async Provider
final sleepDiaryByIdProvider = FutureProvider.family<SleepDiaryModel, int>((
  ref,
  reportId,
) async {
  final repo = ref.watch(sleepDiaryProvider);
  final dto = await repo.fetchSleepDiary(reportId);
  return SleepDiaryModel(
    id: dto.id,
    sleepReportId: dto.sleepReportId,
    sleepDate: dto.sleepDate,
    sleepTime: dto.sleepTime,
    wakeTime: dto.wakeTime,
    sleepLatency: dto.sleepLatency,
    wakeCount: dto.wakeCount,
    sleepQuality: dto.sleepQuality,
    moodScore: dto.moodScore,
    wakeAwareness: dto.wakeAwareness,
    wakeMethod: dto.wakeMethod,
    wakeMethodEtc: dto.wakeMethodEtc,
  );
});

class SleepDiaryNotifier extends StateNotifier<SleepDiaryModel?> {
  final Ref ref;
  final SleepDiaryRepository _repo;

  SleepDiaryNotifier(this.ref, this._repo) : super(null);

  /// 단일 일지 조회
  Future<void> loadDiary(int reportId) async {
    final dto = await _repo.fetchSleepDiary(reportId);
    state = SleepDiaryModel(
      id: dto.id,
      sleepReportId: dto.sleepReportId,
      sleepDate: dto.sleepDate,
      sleepTime: dto.sleepTime,
      wakeTime: dto.wakeTime,
      sleepLatency: dto.sleepLatency,
      wakeCount: dto.wakeCount,
      sleepQuality: dto.sleepQuality,
      moodScore: dto.moodScore,
      wakeAwareness: dto.wakeAwareness,
      wakeMethod: dto.wakeMethod,
      wakeMethodEtc: dto.wakeMethodEtc,
    );
  }

  /// 일지 수정
  Future<void> updateDiary(UpdateSleepDiaryRequest request) async {
    final dto = await _repo.updateSleepDiary(request);
    state = SleepDiaryModel(
      id: dto.id,
      sleepReportId: dto.sleepReportId,
      sleepDate: dto.sleepDate,
      sleepTime: dto.sleepTime,
      wakeTime: dto.wakeTime,
      sleepLatency: dto.sleepLatency,
      wakeCount: dto.wakeCount,
      sleepQuality: dto.sleepQuality,
      moodScore: dto.moodScore,
      wakeAwareness: dto.wakeAwareness,
      wakeMethod: dto.wakeMethod,
      wakeMethodEtc: dto.wakeMethodEtc,
    );
  }

  /// 상태 초기화
  void clear() => state = null;
}
