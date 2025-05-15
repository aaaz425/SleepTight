import 'package:app/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:app/features/sleep_mode/data/models/requests/sleep_sound_request.dart';
import 'package:app/features/sleep_mode/data/models/requests/sleep_start_request.dart';
import 'package:app/features/sleep_mode/data/models/responses/sleep_end_response.dart';
import 'package:app/features/sleep_mode/data/models/responses/sleep_sound_response.dart';
import 'package:app/features/sleep_mode/data/models/responses/sleep_start_response.dart';

abstract class SleepModeRepository {
  Future<SleepStartResponse> postSleepStart(SleepStartRequest request);
  Future<SleepEndResponse> postSleepEnd(SleepEndRequest request);
  Future<SleepSoundResponse> postSleepSound(SleepSoundRequest request);
}
