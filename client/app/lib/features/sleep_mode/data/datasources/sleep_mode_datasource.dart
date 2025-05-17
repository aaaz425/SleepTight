import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_sound_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_start_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_end_response.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_sound_response.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_start_response.dart';
import 'package:dio/dio.dart';

class SleepModeDatasource {
  final Dio dio;

  SleepModeDatasource(this.dio);

  Future<SleepStartResponse> postSleepStart(SleepStartRequest request) async {
    final response = await dio.post(
      AppConfig.api.sleep.startSleep,
      data: request.toJson(),
    );

    return SleepStartResponse.fromJson(response.data);
  }

  Future<SleepEndResponse> postSleepEnd(SleepEndRequest request) async {
    final response = await dio.post(
      AppConfig.api.sleep.endSleep,
      data: request.toJson(),
    );

    return SleepEndResponse.fromJson(response.data);
  }

  Future<SleepSoundResponse> postSleepSound(SleepSoundRequest request) async {
    try {
      // FormData로 변환
      final formData = await request.toFormData();

      // 서버에 POST 요청 전송
      final response = await dio.post(
        AppConfig.api.sleep.sound,
        data: formData,
      );

      // 서버 응답 처리
      return SleepSoundResponse.fromJson(response.data);
    } catch (e) {
      // 오류 처리
      throw Exception('Failed to send sound: $e');
    }
  }
}
