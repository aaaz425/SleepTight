import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class SleepSoundRequest {
  final int reportId;
  final String segmentId; // UUID
  final String timestamp;
  final double duration; // 초 단위
  final File file; // 녹음된 파일

  SleepSoundRequest({
    required this.reportId,
    required this.segmentId,
    required this.timestamp,
    required this.duration,
    required this.file,
  });

  /// multipart/form-data에 맞게 변환
  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'reportId': reportId,
      'segmentId': segmentId,
      'timestamp': timestamp, // 서버가 정수 timestamp 원할 경우
      'duration': duration,
      'file': await MultipartFile.fromFile(
        file.path, // 실제 파일 경로
        filename: 'audio_${segmentId}.opus', // 파일 이름 설정
        contentType: MediaType('audio', 'opus'), // 올바른 MIME 타입
      ),
    });
  }
}
