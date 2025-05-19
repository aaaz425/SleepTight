import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_sound_request.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance =
      AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  Dio? _dio;

  // 큐 처리 관련
  final Queue<Future<void> Function()> _taskQueue = Queue();
  bool _isQueueRunning = false;
  bool _isRecordingInProgress = false;

  Future<void> init(Dio dio) async {
    if (!_isInitialized) {
      await _recorder.openRecorder();
      _isInitialized = true;
    }
    _dio = dio;
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
  }

  void enqueueRecord(String reportId) {
    _taskQueue.add(() async => await _recordAndSend(reportId));
    _runQueue();
  }

  Future<void> _runQueue() async {
    if (_isQueueRunning || _taskQueue.isEmpty) return;
    _isQueueRunning = true;

    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      try {
        await task();
      } catch (e) {
        print('큐 작업 실패: $e');
      }
    }

    _isQueueRunning = false;
  }

  Future<void> _recordAndSend(String reportId) async {
    if (_isRecordingInProgress) {
      print('이미 녹음 중입니다. 요청 무시');
      return;
    }

    _isRecordingInProgress = true;

    try {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        print('마이크 권한 거부됨');
        return;
      }

      if (!_isInitialized || _dio == null) {
        print('초기화되지 않은 상태');
        return;
      }

      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
      }

      final path = '${Directory.systemTemp.path}/audio_${Uuid().v4()}.m4a';

      // 시작 시점 확인용 Completer
      final Completer<void> ready = Completer();
      final subscription = _recorder.onProgress?.listen((event) {
        if (!ready.isCompleted) {
          print('실제 녹음 시작 감지');
          ready.complete();
        }
      });

      await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
      print('녹음 명령 실행됨: $path');

      await ready.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          print('1초 내 녹음 신호 없음 → 강제 진행');
        },
      );

      await Future.delayed(const Duration(seconds: 10));
      await _recorder.stopRecorder();
      await subscription?.cancel();

      final m4a = File(path);
      final exists = await m4a.exists();
      final length = exists ? await m4a.length() : 0;

      if (!exists || length < 2048) {
        print('파일 무효 (존재: $exists, 크기: $length bytes)');
        return;
      }

      final opusPath = await _convertToOpus(path);
      if (opusPath == null) return;

      final uploaded = await _sendToServer(opusPath, reportId);
      if (uploaded) {
        print('업로드 성공');
        await m4a.delete();
        await File(opusPath).delete();
      } else {
        print('업로드 실패');
      }
    } catch (e) {
      print('전체 녹음 처리 실패: $e');
    } finally {
      _isRecordingInProgress = false;
    }
  }

  Future<String?> _convertToOpus(String inputPath) async {
    try {
      final outputPath = inputPath.replaceAll('.m4a', '.opus');
      final cmd = '-y -i "$inputPath" -c:a libopus -b:a 48k "$outputPath"';

      print('FFmpeg 실행: $cmd');
      final session = await FFmpegKit.execute(cmd);
      final result = await session.getReturnCode();

      if (ReturnCode.isSuccess(result)) {
        print('변환 완료: $outputPath');
        return outputPath;
      } else {
        final logs = await session.getAllLogsAsString();
        print('변환 실패 로그:\n$logs');
        return null;
      }
    } catch (e) {
      print('Opus 변환 중 예외: $e');
      return null;
    }
  }

  Future<bool> _sendToServer(String filePath, String reportId) async {
    try {
      final file = File(filePath);
      final request = SleepSoundRequest(
        reportId: int.parse(reportId),
        segmentId: const Uuid().v4(),
        timestamp: DateTime.now().toIso8601String(),
        duration: 10.0,
        file: file,
      );

      final formData = await request.toFormData();
      await _dio!.post(AppConfig.api.sleep.sound, data: formData);

      return true;
    } catch (e) {
      print('서버 전송 실패: $e');
      return false;
    }
  }
}
