import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 다운로드 상태를 관리하는 프로바이더
final soundDownloadProvider =
    StateNotifierProvider<SoundDownloadNotifier, Map<int, String>>((ref) {
      return SoundDownloadNotifier();
    });

class SoundDownloadNotifier extends StateNotifier<Map<int, String>> {
  SoundDownloadNotifier() : super({});

  void addDownloadedFile(int soundId, String filePath) {
    state = {...state, soundId: filePath};
  }

  void removeDownloadedFile(int soundId) {
    final newState = Map<int, String>.from(state);
    newState.remove(soundId);
    state = newState;
  }

  String? getLocalPath(int soundId) {
    return state[soundId];
  }
}

class SoundDownloadService {
  static final SoundDownloadService _instance =
      SoundDownloadService._internal();
  factory SoundDownloadService() => _instance;
  SoundDownloadService._internal();

  final Dio _dio = Dio();

  // 음성 파일 다운로드
  Future<String?> downloadSound(int soundId, String url) async {
    try {
      // 앱의 캐시 디렉토리 얻기
      final cacheDir = await getTemporaryDirectory();
      final filePath = '${cacheDir.path}/sound_$soundId.opus';

      // 파일이 이미 존재하는지 확인
      final file = File(filePath);
      if (await file.exists()) {
        print('파일이 이미 존재합니다: $filePath');
        return filePath;
      }

      // 파일 다운로드
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('다운로드 진행률: $progress%');
          }
        },
      );

      print('다운로드 완료: $filePath');
      return filePath;
    } catch (e) {
      print('다운로드 오류: $e');
      return null;
    }
  }

  // 모든 음성 파일 삭제 (캐시 정리용)
  Future<void> cleanupFiles() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final soundFiles = cacheDir.listSync().where(
        (entity) =>
            entity is File &&
            entity.path.contains('sound_') &&
            entity.path.endsWith('.opus'),
      );

      for (final file in soundFiles) {
        await (file as File).delete();
        print('파일 삭제됨: ${file.path}');
      }
    } catch (e) {
      print('캐시 정리 오류: $e');
    }
  }
}
