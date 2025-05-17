import 'package:sleep_tight/features/sleep_mode/data/datasources/sleep_mode_datasource.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_sound_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_start_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_end_response.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_sound_response.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_start_response.dart';
import 'package:sleep_tight/features/sleep_mode/domain/repositories/sleep_mode_repository_impl.dart';

class SleepModeRepositoryImpl implements SleepModeRepository {
  final SleepModeDatasource datasource;

  SleepModeRepositoryImpl(this.datasource);

  @override
  Future<SleepStartResponse> postSleepStart(SleepStartRequest request) {
    return datasource.postSleepStart(request);
  }

  @override
  Future<SleepEndResponse> postSleepEnd(SleepEndRequest request) {
    return datasource.postSleepEnd(request);
  }

  @override
  Future<SleepSoundResponse> postSleepSound(SleepSoundRequest request) {
    return datasource.postSleepSound(request);
  }
}
