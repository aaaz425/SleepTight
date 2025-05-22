import 'package:sleep_tight/features/coach/data/datasources/sleep_coach_remote_data_source.dart';
import 'package:sleep_tight/features/coach/data/models/requests/create_sleep_coaching_request.dart';
import 'package:sleep_tight/features/coach/domain/repositories/sleep_coach_repository.dart';

class SleepCoachRepositoryImpl implements SleepCoachRepository {
  final SleepCoachRemoteDataSource remoteDataSource;

  SleepCoachRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createSleepCoach(CreateSleepCoachingRequest request) {
    return remoteDataSource.postSleepCoach(request);
  }
}
