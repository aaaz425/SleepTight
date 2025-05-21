import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/music/domain/entity/music_model.dart';
import 'package:flutter/material.dart';

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

  Future<void> play(MusicModel music, BuildContext context) async {
    try {
      final url = music.streamUrl;
      if (state.music?.streamUrl != url) {
        await state.player.setUrl(url);
      }
      // 상태를 먼저 즉시 갱신
      state = AudioState(state.player, music: music, isPlaying: true);
      // 재생 호출
      await state.player.play();
    } catch (e, st) {
      // 오류 발생 시 스낵바로 알림
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('음악 재생 중 오류가 발생했습니다: $e')));
      debugPrint('AudioController.play error: $e');
    }
  }

  Future<void> pause() async {
    // 상태를 먼저 즉시 갱신
    state = AudioState(state.player, music: state.music, isPlaying: false);
    // 일시정지 호출
    await state.player.pause();
  }

  /// 패널 닫힐 때 호출: 재생 중지 & music 필드 null 처리
  Future<void> stop() async {
    await state.player.pause();
    state = AudioState(state.player, music: null, isPlaying: false);
  }
}

final audioControllerProvider =
    StateNotifierProvider<AudioController, AudioState>((ref) {
      return AudioController();
    });
