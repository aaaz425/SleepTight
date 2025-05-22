import 'package:sleep_tight/features/music/data/models/enums/music_category.dart';
import 'package:sleep_tight/features/music/data/models/responses/music_response.dart';
import 'package:sleep_tight/features/music/data/datasources/music_remote_data_source.dart';
import 'package:sleep_tight/features/music/domain/repositories/music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource remoteDataSource;

  MusicRepositoryImpl(this.remoteDataSource);

  @override
  Future<MusicResponse> getMusicById(int musicId) {
    return remoteDataSource.fetchMusicById(musicId);
  }

  @override
  Future<List<MusicResponse>> getMusicsByCategory(MusicCategory category) {
    return remoteDataSource.fetchMusicsByCategory(category.name);
  }
}
