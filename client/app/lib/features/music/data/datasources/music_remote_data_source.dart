import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/music/data/models/responses/music_response.dart';

abstract class MusicRemoteDataSource {
  // 명상 음악 조회
  Future<MusicResponse> fetchMusicById(int musicId);
  // 전체 명상 음악 목록 조회
  Future<List<MusicResponse>> fetchMusicsByCategory(String category);
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final Dio dio;
  final ApiPaths apiPaths;

  MusicRemoteDataSourceImpl(this.dio, this.apiPaths);

  @override
  Future<MusicResponse> fetchMusicById(int musicId) async {
    final response = await dio.get(
      apiPaths.music.musicById(musicId.toString()),
    );
    return MusicResponse.fromJson(response.data);
  }

  @override
  Future<List<MusicResponse>> fetchMusicsByCategory(String category) async {
    final response = await dio.get(apiPaths.music.musicsByCategory(category));
    final data = response.data as Map<String, dynamic>;
    final list = data['musicList'] as List<dynamic>;
    return list.map((e) {
      return MusicResponse.fromJson(e as Map<String, dynamic>);
    }).toList();
  }
}

final musicRemoteDataSourceProvider = Provider<MusicRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  final apiPaths = ApiPaths();
  return MusicRemoteDataSourceImpl(dio, apiPaths);
});
