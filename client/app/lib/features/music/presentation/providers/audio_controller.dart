import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/music/domain/entity/music_model.dart'; // MusicModel 경로
import 'package:flutter/material.dart'; // 디버깅용

// AudioState 클래스 정의 (위의 AudioState.dart 내용과 동일해야 함)
// 이 파일에 직접 AudioState를 정의하거나, 별도 파일에서 import 해야 합니다.
// 여기서는 설명을 위해 AudioState 정의를 다시 한번 포함합니다. (실제로는 한 곳에만 있어야 함)

class AudioState {
  final AudioPlayer player;
  final MusicModel? music;
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;

  AudioState(
    this.player, {
    this.music,
    this.isPlaying = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AudioState copyWith({
    AudioPlayer? player,
    MusicModel? music,
    bool? setIsPlaying,
    bool? setIsLoading,
    String? setErrorMessage,
    bool clearMusic = false,
    bool clearError = false,
  }) {
    return AudioState(
      player ?? this.player,
      music: clearMusic ? null : (music ?? this.music),
      isPlaying: setIsPlaying ?? this.isPlaying,
      isLoading: setIsLoading ?? this.isLoading,
      errorMessage: clearError ? null : (setErrorMessage ?? this.errorMessage),
    );
  }
}

// AudioController: 오디오 재생 로직 및 상태 관리를 담당하는 StateNotifier
class AudioController extends StateNotifier<AudioState> {
  // 생성자에서 AudioPlayer 인스턴스 생성 및 리스너 초기화
  AudioController() : super(AudioState(AudioPlayer())) {
    _initPlayerListeners();
  }

  DateTime? _lastPlayCallTime;
  String? _lastPlayedMusicIdForDebounce;

  void _initPlayerListeners() {
    state.player.setLoopMode(LoopMode.one); // 예: 한 곡 반복

    state.player.playerStateStream.listen(
      (playerState) {
        final newIsPlaying = playerState.playing;
        ProcessingState processingState = playerState.processingState;
        bool newIsLoading = false;

        switch (processingState) {
          case ProcessingState.loading:
          case ProcessingState.buffering:
            newIsLoading = true;
            break;
          case ProcessingState.ready:
          case ProcessingState.completed:
          case ProcessingState.idle:
            newIsLoading = false;
            break;
        }

        // 현재 상태와 다를 경우에만 업데이트 (불필요한 재빌드 방지)
        if (state.isPlaying != newIsPlaying ||
            state.isLoading != newIsLoading) {
          state = state.copyWith(
            setIsPlaying: newIsPlaying,
            setIsLoading: newIsLoading,
            // 로딩이 완료되거나 재생이 시작되면 오류 메시지를 지울 수 있음
            clearError:
                (newIsLoading == false && newIsPlaying) ||
                (processingState == ProcessingState.ready),
          );
        }
      },
      onError: (Object e, StackTrace stackTrace) {
        // playerStateStream 자체에서 오류 발생 시 (드문 경우)
        debugPrint('AudioController playerStateStream error: $e');
        _handlePlaybackError(e, stackTrace);
      },
    );

    state.player.playbackEventStream.listen(
      (event) {
        // 필요한 경우 여기서 특정 이벤트를 처리 (예: event.duration)
      },
      onError: (Object e, StackTrace stackTrace) {
        // 재생 중 발생하는 대부분의 오류 (네트워크, 디코딩 등)
        debugPrint('AudioController playbackEventStream error: $e');
        _handlePlaybackError(e, stackTrace);
      },
    );
  }

  void _handlePlaybackError(Object e, StackTrace stackTrace) {
    debugPrintStack(stackTrace: stackTrace);
    String displayError = "음악 재생 중 오류가 발생했습니다.";
    if (e is PlayerException) {
      displayError = "플레이어 오류: ${e.message ?? '알 수 없는 오류'} (코드: ${e.code})";
    } else if (e is PlatformException) {
      displayError = "시스템 오류: ${e.message ?? '알 수 없는 오류'} (코드: ${e.code})";
      if (e.code == 'abort') {
        displayError = "음악 로딩이 중단되었습니다. 네트워크 연결을 확인하거나 잠시 후 다시 시도해주세요.";
      }
    }
    state = state.copyWith(
      setErrorMessage: displayError,
      setIsLoading: false,
      setIsPlaying: false,
      // 오류 발생 시 현재 음악 정보를 유지할지, null로 할지는 정책에 따라 결정
      // clearMusic: true, // 필요하다면 주석 해제
    );
  }

  Future<void> play(MusicModel music) async {
    // 디바운싱 로직 (짧은 시간 내 동일 곡 반복 재생 방지 - 이전 로그 패턴 대응용 임시)
    final now = DateTime.now();
    if (_lastPlayCallTime != null &&
        _lastPlayedMusicIdForDebounce == music.id &&
        now.difference(_lastPlayCallTime!).inMilliseconds < 500) {
      debugPrint(
        "AudioController: Play call for ${music.title} ignored due to rapid repeat.",
      );
      return;
    }
    _lastPlayCallTime = now;
    _lastPlayedMusicIdForDebounce = music.id;

    debugPrint(
      "AudioController: Attempting to play - ${music.title} (URL: ${music.streamUrl})",
    );

    // 상태 업데이트: 새 음악 정보 설정, 로딩 시작, 오류 메시지 초기화
    // music 필드를 새로운 music 객체로 설정 (clearMusic은 false 또는 생략)
    state = state.copyWith(
      music: music,
      setIsLoading: true,
      setIsPlaying: false, // 재생 시작 전이므로 false
      clearError: true,
    );

    try {
      // setUrl은 내부적으로 이전 소스를 해제하고 새 소스를 준비
      await state.player.setUrl(music.streamUrl);
      await state.player.play(); // 재생 시작
      debugPrint("AudioController: Play command issued for - ${music.title}");
      // isPlaying, isLoading 등의 상태는 playerStateStream 리스너가 업데이트함
    } catch (e, st) {
      // setUrl이나 play 자체에서 즉시 발생하는 예외 처리
      debugPrint('AudioController.play direct catch error: $e');
      _handlePlaybackError(e, st); // 통합 오류 처리 함수 사용
      // 직접 catch된 오류의 경우, music을 null로 만들 수 있음 (정책에 따라)
      state = state.copyWith(clearMusic: true);
    }
  }

  Future<void> pause() async {
    if (!state.isPlaying && !state.isLoading) {
      debugPrint(
        "AudioController: Pause called but not playing or already paused.",
      );
      return;
    }
    debugPrint("AudioController: Pause called.");
    try {
      await state.player.pause();
      // isPlaying 상태는 playerStateStream 리스너가 업데이트
    } catch (e, st) {
      debugPrint('AudioController.pause error: $e');
      _handlePlaybackError(e, st);
    }
  }

  Future<void> resume() async {
    if (state.isPlaying || state.music == null) {
      debugPrint(
        "AudioController: Resume called but already playing or no music to resume.",
      );
      return;
    }
    debugPrint("AudioController: Resume called for ${state.music?.title}.");
    try {
      await state.player.play();
      // isPlaying 상태는 playerStateStream 리스너가 업데이트
    } catch (e, st) {
      debugPrint('AudioController.resume error: $e');
      _handlePlaybackError(e, st);
    }
  }

  Future<void> stop() async {
    debugPrint("AudioController: Stop called.");
    try {
      await state.player.stop(); // 네이티브 플레이어 정지
      // music을 null로, isPlaying을 false로 설정
      state = state.copyWith(
        clearMusic: true, // *** 여기가 핵심: music을 null로 설정 ***
        setIsPlaying: false,
        setIsLoading: false, // 정지 시 로딩 상태도 해제
        clearError: true, // 오류 메시지도 초기화
      );
      debugPrint(
        "AudioController: state.music after stop() is ${state.music}, isPlaying is ${state.isPlaying}",
      );
    } catch (e, st) {
      debugPrint('AudioController.stop error: $e');
      _handlePlaybackError(e, st);
    }
  }

  @override
  void dispose() {
    debugPrint("AudioController: Disposing player.");
    state.player.dispose(); // AudioPlayer 인스턴스 해제
    super.dispose();
  }
}

// Riverpod Provider
final audioControllerProvider =
    StateNotifierProvider.autoDispose<AudioController, AudioState>((ref) {
      return AudioController();
    });
