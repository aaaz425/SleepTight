import 'package:sleep_tight/features/music/data/models/enums/music_category.dart';
import 'package:sleep_tight/features/music/data/models/responses/music_response.dart';

abstract class MusicRepository {
  Future<MusicResponse> getMusicById(int musicId);
  Future<List<MusicResponse>> getMusicsByCategory(MusicCategory category);
}
