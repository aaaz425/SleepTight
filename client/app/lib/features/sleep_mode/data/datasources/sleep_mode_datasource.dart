import 'package:app/core/config/app_config.dart';
import 'package:app/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:app/features/sleep_mode/data/models/requests/sleep_sound_request.dart';
import 'package:app/features/sleep_mode/data/models/requests/sleep_start_request.dart';
import 'package:app/features/sleep_mode/data/models/responses/sleep_end_response.dart';
import 'package:app/features/sleep_mode/data/models/responses/sleep_sound_response.dart';
import 'package:app/features/sleep_mode/data/models/responses/sleep_start_response.dart';
import 'package:dio/dio.dart';

class SleepModeDatasource {
  final Dio dio;

  SleepModeDatasource(this.dio);

  Future<SleepStartResponse> postSleepStart(SleepStartRequest request) async {
    final response = await dio.post(
      AppConfig.api.sleep.startSleep,
      data: request.toJson(),
    );

    return SleepStartResponse.fromJson(response.data['data']);
  }

  Future<SleepEndResponse> postSleepEnd(SleepEndRequest request) async {
    final response = await dio.post(
      AppConfig.api.sleep.endSleep,
      data: request.toJson(),
    );

    return SleepEndResponse.fromJson(response.data['data']);
  }

  Future<SleepSoundResponse> postSleepSound(SleepSoundRequest request) async {
    final response = await dio.post(
      AppConfig.api.sleep.sound,
      data: request.toJson(),
    );

    return SleepSoundResponse.fromJson(response.data['data']);
  }
}
