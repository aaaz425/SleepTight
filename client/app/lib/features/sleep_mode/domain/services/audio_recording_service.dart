import 'dart:io';
import 'package:app/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:uuid/uuid.dart';
import 'package:app/features/sleep_mode/data/models/requests/sleep_sound_request.dart';

class AudioRecordingService {
  final FlutterSoundRecorder flutterSound;
  final Dio dio;

  AudioRecordingService(this.flutterSound, this.dio);

  Future<void> recordAndSendAudio(String reportId) async {
    try {
      // 1. 녹음 시작
      final filePath = await _startRecording();
      if (filePath == null) {
        print('녹음 실패');
        return;
      }

      // 2. 10초 후 녹음 중지
      await Future.delayed(Duration(seconds: 10));

      // 3. 녹음 중지
      await _stopRecording();

      // 4. 파일 전송
      final success = await _sendAudioToServer(filePath, reportId);

      // 5. 성공 시 파일 삭제
      if (success) {
        File(filePath).delete();
      }
    } catch (e) {
      // Todo: retry
      print('에러 발생: $e');
    }
  }

  Future<String?> _startRecording() async {
    try {
      final filePath = '/path/to/save/audio_${Uuid().v4()}.opus';
      await flutterSound.startRecorder(toFile: filePath, codec: Codec.opusOGG);
      print('녹음 시작: $filePath');
      return filePath;
    } catch (e) {
      print('녹음 시작 실패: $e');
      return null;
    }
  }

  Future<void> _stopRecording() async {
    try {
      await flutterSound.stopRecorder();
      print('녹음 중지');
    } catch (e) {
      print('녹음 중지 실패: $e');
    }
  }

  // 파일 전송
  Future<bool> _sendAudioToServer(String filePath, String reportId) async {
    try {
      final file = File(filePath);
      final segmentId = Uuid().v4();
      final timestamp = DateTime.now().toIso8601String();
      final duration = 10.0;

      final request = SleepSoundRequest(
        reportId: int.parse(reportId),
        segmentId: segmentId,
        timestamp: timestamp,
        duration: duration,
        file: file,
      );

      // FormData 생성
      FormData formData = await request.toFormData();

      // 서버로 POST 요청
      Response response = await dio.post(
        AppConfig.api.sleep.sound,
        data: formData,
      );

      if (response.data != null && response.data['success'] == true) {
        print('파일 전송 성공');
        return true;
      } else {
        print('파일 전송 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('파일 전송 중 오류 발생: $e');
      return false;
    }
  }
}
