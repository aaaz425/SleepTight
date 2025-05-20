import 'package:sleep_tight/features/music/data/models/responses/music_response.dart';
import 'package:sleep_tight/features/music/data/models/responses/musics_by_category_dart.dart';

abstract class MusicRepository {
  Future<MusicResponse> getMusicById(int musicId);
  Future<List<MusicsByCategory>> getMusicsByCategory();
}
