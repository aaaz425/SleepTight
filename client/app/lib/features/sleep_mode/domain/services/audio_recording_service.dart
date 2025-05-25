import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data'; // Uint8List 사용을 위해 추가

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:sleep_tight/core/config/app_config.dart'; // AppConfig 경로 확인 필요
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_sound_request.dart'; // 경로 확인 필요

class AudioRecordingService {
  static final AudioRecordingService _instance =
      AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  Dio? _dio;

  // StreamController 타입을 Uint8List (non-nullable)로 변경
  final StreamController<Uint8List> _pcmDataStreamController =
      StreamController<Uint8List>.broadcast();

  final StreamController<Uint8List> _rawPcmUiStreamController =
      StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get rawPcmUiStream => _rawPcmUiStreamController.stream;

  final StreamController<List<double>> _amplitudeStreamController =
      StreamController<List<double>>.broadcast();
  Stream<List<double>> get amplitudeStream => _amplitudeStreamController.stream;

  StreamSubscription? _pcmDataSubscription;
  final BytesBuilder _pcmBuffer = BytesBuilder();

  final int _sampleRate = 16000;
  final int _numChannels = 1;
  final int _bitDepth = 16;

  late int _bytesPerSample;
  late int _bytesPerSecond;
  late int _bytesFor10Seconds;

  final Queue<Future<void> Function()> _taskQueue = Queue();
  bool _isQueueRunning = false;
  bool _isRecordingSessionActive = false;

  Future<void> init(Dio dio) async {
    if (!_isInitialized) {
      // flutter_sound 로거 레벨 설정 (디버깅 시 유용)
      // await FlutterSoundRecorder().setLogLevel(LogLevel.debug);
      // await FlutterSoundPlayer().setLogLevel(LogLevel.debug);

      await _recorder.openRecorder();
      _isInitialized = true;
      _bytesPerSample = (_bitDepth ~/ 8) * _numChannels;
      _bytesPerSecond = _sampleRate * _bytesPerSample;
      _bytesFor10Seconds = _bytesPerSecond * 10;
      debugPrint(
        'AudioRecordingService initialized. Bytes for 10s: $_bytesFor10Seconds',
      );
    }
    _dio = dio;
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await stopRecordingSession();
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
    await _pcmDataStreamController.close();
    await _rawPcmUiStreamController.close();
    await _amplitudeStreamController.close();
    _taskQueue.clear();
    _isQueueRunning = false;
    debugPrint('AudioRecordingService disposed.');
  }

  Future<void> startRecordingSession(String reportId) async {
    debugPrint(
      'AudioRecordingService: startRecordingSession 호출됨. Report ID: $reportId',
    );
    if (_isRecordingSessionActive) {
      debugPrint('이미 녹음 세션이 진행 중입니다.');
      return;
    }
    if (!_isInitialized || _dio == null) {
      debugPrint('AudioRecordingService가 초기화되지 않았거나 Dio가 설정되지 않았습니다.');
      return;
    }

    final micStatus = await Permission.microphone.request();
    debugPrint('AudioRecordingService: 마이크 권한 상태 - ${micStatus.isGranted}');
    if (!micStatus.isGranted) {
      debugPrint('마이크 권한이 거부되었습니다.');
      return; // 권한 없으면 여기서 중단
    }

    _isRecordingSessionActive = true;
    _pcmBuffer.clear();

    debugPrint('녹음 세션 시작 중... Report ID: $reportId');

    try {
      debugPrint('AudioRecordingService: _recorder.startRecorder 호출 시도...');
      // toStream은 StreamSink<Uint8List> 타입을 기대 (내부적으로)
      await _recorder.startRecorder(
        toStream: _pcmDataStreamController.sink, // 이제 StreamSink<Uint8List> 타입
        codec: Codec.pcm16,
        sampleRate: _sampleRate,
        numChannels: _numChannels,
        // 기본적으로 flutter_sound는 16비트 PCM을 Uint8List로 변환하여 스트리밍합니다.
      );
      debugPrint(
        'AudioRecordingService: FlutterSoundRecorder 시작됨. PCM 스트림 대기 중...',
      );

      _pcmDataSubscription = _pcmDataStreamController.stream.listen(
        (Uint8List pcmDataChunk) {
          // 콜백 파라미터 타입을 Uint8List (non-nullable)로 변경
          // pcmDataChunk가 null일 수 없으므로 null 체크 제거 (단, empty 체크는 유효)
          debugPrint(
            'AudioRecordingService: pcmDataStream 리스너 호출됨. 데이터 크기: ${pcmDataChunk.length}',
          );
          if (pcmDataChunk.isNotEmpty) {
            if (!_rawPcmUiStreamController.isClosed) {
              _rawPcmUiStreamController.add(pcmDataChunk);
              debugPrint(
                'AudioRecordingService: _rawPcmUiStreamController에 데이터 추가됨. 크기: ${pcmDataChunk.length}',
              );
            }

            List<double> amplitudes = _convertPcmToAmplitudes(pcmDataChunk);
            if (!_amplitudeStreamController.isClosed) {
              _amplitudeStreamController.add(amplitudes);
            }

            _pcmBuffer.add(pcmDataChunk);

            while (_pcmBuffer.length >= _bytesFor10Seconds) {
              final segmentBytes = Uint8List.fromList(
                _pcmBuffer.toBytes().sublist(0, _bytesFor10Seconds),
              );
              final remainingBytes = _pcmBuffer.toBytes().sublist(
                _bytesFor10Seconds,
              );
              _pcmBuffer.clear();
              _pcmBuffer.add(remainingBytes);

              debugPrint(
                '10초 PCM 세그먼트 추출됨 (크기: ${segmentBytes.length} bytes). 변환/업로드 큐에 추가.',
              );
              _taskQueue.add(
                () => _processAndUploadPcmSegment(segmentBytes, reportId),
              );
              _runQueue();
            }
          } else {
            debugPrint('AudioRecordingService: pcmDataChunk is empty.');
          }
        },
        onError: (error, stackTrace) {
          debugPrint('AudioRecordingService: 오디오 스트림 에러: $error');
          debugPrint('AudioRecordingService: StackTrace: $stackTrace');
          stopRecordingSession();
        },
        onDone: () {
          debugPrint('AudioRecordingService: 오디오 스트림 완료 (onDone 호출됨).');
        },
        cancelOnError: true,
      );
    } catch (e, s) {
      // startRecorder 호출 자체에서 발생하는 예외 처리
      debugPrint('AudioRecordingService: _recorder.startRecorder 실패: $e');
      debugPrint('AudioRecordingService: StackTrace: $s');
      _isRecordingSessionActive = false; // 실패 시 상태 복원
    }
  }

  Future<void> stopRecordingSession() async {
    // ... (이전과 동일한 stopRecordingSession 로직) ...
    if (!_isRecordingSessionActive &&
        !_recorder.isRecording &&
        _pcmDataSubscription == null) {
      return;
    }
    debugPrint('녹음 세션 중지 중...');

    await _pcmDataSubscription?.cancel();
    _pcmDataSubscription = null;

    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
      debugPrint('FlutterSoundRecorder 중지됨.');
    }

    _isRecordingSessionActive = false;

    if (_pcmBuffer.isNotEmpty) {
      debugPrint('남은 PCM 데이터 처리 중 (크기: ${_pcmBuffer.length} bytes)...');
      final lastSegmentBytes = _pcmBuffer.toBytes();
      _pcmBuffer.clear();
      if (lastSegmentBytes.length > _bytesPerSample * 2) {
        debugPrint('마지막 세그먼트 큐에 추가.');
        _taskQueue.add(
          () => _processAndUploadPcmSegment(
            lastSegmentBytes,
            "final_chunk_report_id_placeholder",
            isFinalChunk: true,
          ),
        );
        _runQueue();
      } else {
        debugPrint('마지막 세그먼트가 너무 짧아 무시합니다.');
      }
    }
    debugPrint('녹음 세션이 완전히 중지되었습니다.');
  }

  // _convertPcmToAmplitudes, _processAndUploadPcmSegment, _convertToOpusFromPcm, _sendToServer, _runQueue 메소드는 이전과 동일하게 유지
  List<double> _convertPcmToAmplitudes(Uint8List pcmData) {
    List<double> amplitudes = [];
    for (int i = 0; i < pcmData.lengthInBytes; i += 2) {
      int byte1 = pcmData[i];
      int byte2 = pcmData[i + 1];
      int sampleValue = (byte2 << 8) | byte1;
      if (sampleValue > 32767) {
        sampleValue -= 65536;
      }
      amplitudes.add(sampleValue / 32768.0);
    }
    return amplitudes;
  }

  Future<void> _processAndUploadPcmSegment(
    Uint8List pcmSegment,
    String reportId, {
    bool isFinalChunk = false,
  }) async {
    final String tempFileNameBase = 'audio_segment_${Uuid().v4()}';
    final String pcmFilePath =
        '${Directory.systemTemp.path}/$tempFileNameBase.pcm';
    File pcmFile = File(pcmFilePath);

    try {
      await pcmFile.writeAsBytes(pcmSegment, flush: true);
      debugPrint('PCM 세그먼트 임시 저장: $pcmFilePath');

      final opusPath = await _convertToOpusFromPcm(pcmFilePath);

      if (await pcmFile.exists()) {
        await pcmFile.delete();
      }

      if (opusPath == null) {
        debugPrint('Opus 변환 실패 (세그먼트: $reportId)');
        return;
      }

      double duration =
          isFinalChunk ? (pcmSegment.length / _bytesPerSecond) : 10.0;
      if (duration < 0.1 && isFinalChunk) {
        debugPrint('최종 청크의 길이가 너무 짧아 업로드하지 않습니다: $duration 초');
        File(opusPath).delete().catchError((_) {
          debugPrint('Opus 파일 삭제 실패: $opusPath');
        });
        return;
      }

      final uploaded = await _sendToServer(opusPath, reportId, duration);
      File opusFile = File(opusPath);
      if (uploaded) {
        debugPrint('Opus 파일 업로드 성공: $opusPath');
        if (await opusFile.exists()) await opusFile.delete();
      } else {
        debugPrint('Opus 파일 업로드 실패: $opusPath');
        if (await opusFile.exists()) await opusFile.delete();
      }
    } catch (e) {
      debugPrint('PCM 세그먼트 처리 중 오류: $e');
      if (await pcmFile.exists()) {
        await pcmFile.delete().catchError((_) {
          debugPrint('PCM 파일 삭제 실패: $pcmFilePath');
        });
      }
    }
  }

  Future<String?> _convertToOpusFromPcm(String inputPcmPath) async {
    final outputPath = inputPcmPath.replaceAll('.pcm', '.opus');
    final cmd =
        '-y -f s16le -ar $_sampleRate -ac $_numChannels -i "$inputPcmPath" -c:a libopus -b:a 48k "$outputPath"';
    debugPrint('FFmpeg (PCM to Opus) 실행: $cmd');

    try {
      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Opus 변환 성공: $outputPath');
        return outputPath;
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint('Opus 변환 실패 (RC: $returnCode). 로그: $logs');
        final failedOpusFile = File(outputPath);
        if (await failedOpusFile.exists()) {
          await failedOpusFile.delete().catchError((_) {});
        }
        return null;
      }
    } catch (e) {
      debugPrint('FFmpeg 실행 중 예외: $e');
      return null;
    }
  }

  Future<bool> _sendToServer(
    String filePath,
    String reportId,
    double duration,
  ) async {
    if (_dio == null) {
      debugPrint('Dio 인스턴스가 없습니다. 서버 전송 불가.');
      return false;
    }
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('업로드할 파일이 존재하지 않습니다: $filePath');
        return false;
      }
      int parsedReportId;
      if (reportId == "final_chunk_report_id_placeholder") {
        debugPrint("경고: 최종 청크에 대한 실제 reportId가 필요합니다. 임시 ID 사용 또는 전송 스킵 고려.");
        return false;
      } else {
        try {
          parsedReportId = int.parse(reportId);
        } catch (e) {
          debugPrint("reportId '$reportId'를 int로 파싱하는데 실패했습니다: $e");
          return false;
        }
      }

      final request = SleepSoundRequest(
        reportId: parsedReportId,
        segmentId: const Uuid().v4(),
        timestamp: DateTime.now().toUtc().toIso8601String(),
        duration: double.parse(duration.toStringAsFixed(2)),
        file: file,
      );

      final formData = await request.toFormData();
      debugPrint(
        '서버로 전송 시도: $filePath, Report ID: $parsedReportId, Duration: $duration',
      );
      await _dio!.post(AppConfig.api.sleep.sound, data: formData);
      debugPrint('서버 전송 성공 응답 받음.');
      return true;
    } catch (e) {
      debugPrint('서버 전송 실패: $e');
      if (e is DioException) {
        debugPrint('DioException Response: ${e.response}');
      }
      return false;
    }
  }

  Future<void> _runQueue() async {
    if (_isQueueRunning || _taskQueue.isEmpty) return;
    _isQueueRunning = true;

    debugPrint('큐 실행 시작. 대기 작업 수: ${_taskQueue.length}');
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      try {
        await task();
      } catch (e) {
        debugPrint('큐 작업 실행 중 예외 발생: $e');
      }
    }
    _isQueueRunning = false;
    debugPrint('큐 실행 완료.');
  }
}
