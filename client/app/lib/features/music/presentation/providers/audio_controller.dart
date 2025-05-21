import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/music/domain/entity/music_model.dart';

/// 현재 재생중인 트랙 정보
class AudioState {
  final AudioPlayer player;
  final MusicModel? music;
  final bool isPlaying;
  AudioState(this.player, {this.music, this.isPlaying = false});
}

class AudioController extends StateNotifier<AudioState> {
  AudioController()
    : super(AudioState(AudioPlayer(), music: null, isPlaying: false)) {
    // 트랙 재생 완료 시 자동 반복
    state.player.setLoopMode(LoopMode.one);
  }

  Future<void> play(MusicModel music) async {
    final url = music.streamUrl;
    if (state.music?.streamUrl != url) {
      await state.player.setUrl(url);
    }
    // ➊ 상태를 먼저 즉시 갱신
    state = AudioState(state.player, music: music, isPlaying: true);
    // ➋ 재생 호출 (await 있든 없든 UI는 오늘 바로 반영됨)
    await state.player.play();
  }

  Future<void> pause() async {
    // ➊ 상태를 먼저 즉시 갱신
    state = AudioState(state.player, music: state.music, isPlaying: false);
    // ➋ 일시정지 호출
    await state.player.pause();
  }
}

final audioControllerProvider =
    StateNotifierProvider<AudioController, AudioState>((ref) {
      return AudioController();
    });
