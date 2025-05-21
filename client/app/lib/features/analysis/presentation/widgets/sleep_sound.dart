import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_sound_model.dart';
import 'package:sleep_tight/features/analysis/data/services/sleep_sound_sevice.dart';
import 'package:sleep_tight/features/analysis/data/services/sound_download_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

// 이상 현상 영역 표시 색상
const Color anomalyHighlightColor = Color(0xFF3A6EFF);

// 전역 이퀄라이저 데이터 캐싱 (앱 실행 중 지속적으로 유지)
final Map<int, List<double>> _globalWaveformCache = {};

class SleepSound extends ConsumerStatefulWidget {
  final int reportId;

  const SleepSound({super.key, required this.reportId});

  @override
  ConsumerState<SleepSound> createState() => _SleepSoundState();
}

class _SleepSoundState extends ConsumerState<SleepSound> {
  int? _currentlyPlayingId;
  late Future<List<SleepSoundModel>> _sleepSoundsFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SoundDownloadService _downloadService = SoundDownloadService();
  int _audioProgress = 0; // 재생 진행률 (0-100)

  // 각 음성 파일의 로컬 경로 캐싱
  final Map<int, String> _localFilePaths = {};

  // 현재 다운로드 중인 파일 ID 목록
  final Set<int> _downloadingFiles = {};

  // 음악 파일 재생 상태
  bool _isPlaying = false;

  // 재생이 완료된 파일 추적
  Set<int> _completedSoundIds = {};

  @override
  void initState() {
    super.initState();
    _sleepSoundsFuture = fetchSleepSounds(ref, widget.reportId).then((sounds) {
      // 리포트 조회 시 모든 음성 파일 자동 다운로드 및 파형 추출 시작
      _prefetchAllAudioFiles(sounds);
      return sounds;
    });

    // 오디오 플레이어 위치 업데이트 리스너
    _audioPlayer.positionStream.listen((position) {
      if (_audioPlayer.duration != null && _currentlyPlayingId != null) {
        final progress =
            (position.inMilliseconds /
                    _audioPlayer.duration!.inMilliseconds *
                    100)
                .round();
        if (progress != _audioProgress) {
          setState(() {
            _audioProgress = progress;
          });
        }
      }
    });

    // 오디오 플레이어 상태 리스너
    _audioPlayer.playerStateStream.listen((state) {
      // 재생/일시정지 상태 변경 처리
      final bool isCurrentlyPlaying =
          state.playing && state.processingState != ProcessingState.completed;

      if (_isPlaying != isCurrentlyPlaying) {
        setState(() {
          _isPlaying = isCurrentlyPlaying;
        });
      }

      // 재생 완료 시 초기화
      if (state.processingState == ProcessingState.completed &&
          _currentlyPlayingId != null) {
        final completedId = _currentlyPlayingId;
        setState(() {
          _isPlaying = false;
          _completedSoundIds.add(_currentlyPlayingId!); // 완료된 파일 추적
          _currentlyPlayingId = null; // 명시적으로 null로 설정하여 완전히 초기화
          _audioProgress = 0;
        });

        print('재생 완료 - soundID: $completedId');
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 모든 오디오 파일 미리 다운로드 및 파형 추출
  Future<void> _prefetchAllAudioFiles(List<SleepSoundModel> sounds) async {
    for (final sound in sounds) {
      // 이미 다운로드 중이거나 파형이 있으면 건너뛰기
      if (_downloadingFiles.contains(sound.soundId) ||
          _globalWaveformCache.containsKey(sound.soundId)) {
        continue;
      }

      _downloadingFiles.add(sound.soundId);
      setState(() {}); // UI 업데이트

      // 파일 다운로드 시도
      final localPath = await _downloadService.downloadSound(
        sound.soundId,
        sound.clipUrl,
      );

      if (localPath != null) {
        _localFilePaths[sound.soundId] = localPath;

        // 파형 데이터 추출
        final waveform = await _extractWaveform(localPath);
        if (waveform.isNotEmpty) {
          _globalWaveformCache[sound.soundId] = waveform;
        }
      }

      _downloadingFiles.remove(sound.soundId);
      if (mounted) setState(() {}); // UI 업데이트
    }
  }

  // 파형 데이터 추출
  Future<List<double>> _extractWaveform(String filePath) async {
    try {
      // 파일이 존재하는지 확인
      final file = File(filePath);
      if (!await file.exists()) {
        return _generateRandomWaveform();
      }

      // 파형 추출 작업
      final playerController = PlayerController();

      // 파일 준비
      try {
        await playerController.preparePlayer(path: filePath, noOfSamples: 100);

        // 파형 데이터 추출
        final waveformData = await playerController.extractWaveformData(
          path: filePath,
          noOfSamples: 100,
        );

        playerController.dispose();

        if (waveformData.isEmpty) {
          return _generateRandomWaveform();
        }

        // 데이터 정규화 (0.1 ~ 1.0 범위로)
        double maxValue = 0.1;
        for (final value in waveformData) {
          if (value > maxValue) maxValue = value;
        }

        final normalizedData =
            waveformData.map((value) {
              return 0.1 + (value / maxValue) * 0.9;
            }).toList();

        return normalizedData;
      } finally {
        // 항상 컨트롤러 정리
        playerController.dispose();
      }
    } catch (e) {
      print('파형 추출 오류: $e');
      return _generateRandomWaveform();
    }
  }

  // 파형 추출 실패 시 랜덤 데이터 생성 (대체용)
  List<double> _generateRandomWaveform() {
    final random = math.Random();
    return List.generate(100, (i) {
      return 0.1 + random.nextDouble() * 0.7;
    });
  }

  // 음성 파일 다운로드 및 재생
  Future<void> _togglePlayback(SleepSoundModel sound) async {
    final soundId = sound.soundId;

    // 재생이 완료된 파일 초기화
    if (_completedSoundIds.contains(soundId)) {
      _completedSoundIds.remove(soundId);
    }

    if (_currentlyPlayingId == soundId && _isPlaying) {
      // 현재 재생 중인 경우 => 일시정지
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
      return;
    } else if (_currentlyPlayingId == soundId && !_isPlaying) {
      // 현재 일시정지 중인 경우 => 이어서 재생
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
      return;
    }

    try {
      // 다른 음원이 재생 중이면 정지
      if (_currentlyPlayingId != null) {
        await _audioPlayer.stop();
      }

      setState(() {
        _currentlyPlayingId = soundId;
        _audioProgress = 0;
        _isPlaying = false; // 초기 상태는 재생 안함으로 설정
      });

      // 로컬 파일 경로 확인 및 다운로드
      String? localPath = _localFilePaths[soundId];

      if (localPath == null) {
        // 다운로드 진행 상태 표시
        setState(() {
          _downloadingFiles.add(soundId);
        });

        // 파일 다운로드
        localPath = await _downloadService.downloadSound(
          soundId,
          sound.clipUrl,
        );

        setState(() {
          _downloadingFiles.remove(soundId);
        });

        if (localPath == null) {
          // 다운로드 실패 시 URL 스트리밍으로 폴백
          await _audioPlayer.setUrl(sound.clipUrl);
        } else {
          // 다운로드 성공 시 로컬 파일 재생 및 캐싱
          _localFilePaths[soundId] = localPath;

          // 파형 데이터 추출 및 캐싱 (아직 없는 경우)
          if (!_globalWaveformCache.containsKey(soundId)) {
            // 파형 데이터 추출
            _extractWaveform(localPath).then((waveform) {
              if (mounted) {
                setState(() {
                  _globalWaveformCache[soundId] = waveform;
                });
              }
            });
          }

          await _audioPlayer.setFilePath(localPath);
        }
      } else {
        // 이미 다운로드된 파일 재생
        final file = File(localPath);
        if (await file.exists()) {
          // 아직 파형 데이터가 없으면 추출
          if (!_globalWaveformCache.containsKey(soundId)) {
            // 파형 데이터 추출
            _extractWaveform(localPath).then((waveform) {
              if (mounted) {
                setState(() {
                  _globalWaveformCache[soundId] = waveform;
                });
              }
            });
          }

          await _audioPlayer.setFilePath(localPath);
        } else {
          // 파일이 삭제된 경우 다시 다운로드
          _localFilePaths.remove(soundId);
          return _togglePlayback(sound);
        }
      }

      // 재생 시작
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('🎧 재생 오류: $e');
      setState(() {
        _currentlyPlayingId = null;
        _audioProgress = 0;
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SleepSoundModel>>(
      future: _sleepSoundsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '감지 된 이상 현상',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: CircularProgressIndicator(color: AppColors.font3),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '감지 된 이상 현상',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Center(child: Text('이상현상 데이터를 불러올 수 없습니다')),
              ],
            ),
          );
        }

        final sounds = snapshot.data!;
        if (sounds.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '감지 된 이상 현상',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    '감지된 이상현상이 없습니다.',
                    style: TextStyle(color: AppColors.font2),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '감지 된 이상 현상',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              for (final sound in sounds) _buildSoundItem(sound),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundItem(SleepSoundModel sound) {
    final soundId = sound.soundId;
    final isCurrentSound = _currentlyPlayingId == soundId;
    final isDownloading = _downloadingFiles.contains(soundId);
    final wasPlaybackCompleted = _completedSoundIds.contains(soundId);

    // 클립 길이 계산 (초 단위)
    final clipDuration = sound.getClipDurationInSeconds();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.gray02,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 헤더 (이름 및 시간)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이상현상 이름
                Expanded(
                  child: Text(
                    sound.getAnomalyText(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 시간 정보
                Text(
                  '${sound.soundStartTime} ~ ${sound.soundEndTime}',
                  style: const TextStyle(color: AppColors.font2, fontSize: 12),
                ),
              ],
            ),
          ),

          // 이퀄라이저 및 재생 버튼
          GestureDetector(
            onTap: () => _togglePlayback(sound),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  // 재생 버튼
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child:
                          isDownloading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    anomalyHighlightColor,
                                  ),
                                ),
                              )
                              : Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.gray04,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    (isCurrentSound && _isPlaying)
                                        ? "assets/icons/pause.svg"
                                        : "assets/icons/play.svg",
                                    color: AppColors.white,
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              ),
                    ),
                  ),

                  // 이퀄라이저 영역
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: Stack(
                        children: [
                          // 이퀄라이저 표시
                          _buildWaveformVisualizer(sound),

                          // 다운로드 중 표시 (블러 처리 및 텍스트)
                          if (isDownloading)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                child: Container(
                                  color: AppColors.gray01.withOpacity(0.3),
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: const Center(
                                    child: Text(
                                      '다운로드 중',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // 재생 진행 표시
                          // 현재 선택된 파일이고 완료되지 않은 경우에만 재생바 표시
                          if (isCurrentSound &&
                              !wasPlaybackCompleted &&
                              _audioProgress > 0)
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.65 *
                                  _audioProgress /
                                  100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.gray01.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 이퀄라이저 시각화
  Widget _buildWaveformVisualizer(SleepSoundModel sound) {
    // 캐시된 파형 데이터가 있는지 확인
    final waveform = _globalWaveformCache[sound.soundId];

    // 샘플 개수
    final sampleLength = 30;
    final eventList = sound.events;
    final clipDuration = sound.getClipDurationInSeconds();

    // 파형 데이터를 샘플 개수에 맞게 재샘플링
    List<double> sampledHeights = [];
    if (waveform != null) {
      // 실제 파형 데이터 사용
      for (int i = 0; i < sampleLength; i++) {
        final index = (i * waveform.length / sampleLength).floor();
        if (index < waveform.length) {
          sampledHeights.add(waveform[index]);
        } else {
          sampledHeights.add(0.2);
        }
      }
    } else {
      // 임시 파형 데이터 생성
      for (int i = 0; i < sampleLength; i++) {
        sampledHeights.add(0.1 + (i % 4) * 0.1);
      }
    }

    return Row(
      children: List.generate(sampleLength, (i) {
        final height = sampledHeights[i];

        // 이상현상 구간인지 확인
        final second = i * clipDuration / sampleLength;
        bool isAnomalySection = false;

        for (final event in eventList) {
          if (second >= event.eventStartSec && second <= event.eventEndSec) {
            isAnomalySection = true;
            break;
          }
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 36 * height,
                  width: 4,
                  decoration: BoxDecoration(
                    color:
                        isAnomalySection
                            ? anomalyHighlightColor
                            : AppColors.gray05,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

const mockSleepSoundData = {
  "reportId": 1,
  "date": "2025-04-27",
  "sounds": [
    {
      "soundId": 1,
      "soundStartTime": "04:52:12",
      "soundEndTime": "04:52:22",
      "clipUrl": "assets/sound/alarm.mp3",
      "events": [
        {
          "eventId": "ffggh1asdjsdzxc",
          "anomaly": "snore",
          "eventStartSec": 0,
          "eventEndSec": 2,
          "confidence": 0.92,
        },
        {
          "eventId": "asdgh1asdj1hjk5h",
          "anomaly": "talk",
          "eventStartSec": 2,
          "eventEndSec": 6,
          "confidence": 0.98,
        },
      ],
    },
    {
      "soundId": 2,
      "soundStartTime": "05:52:12",
      "soundEndTime": "05:52:22",
      "clipUrl": "assets/sound/alarm.mp3",
      "events": [
        {
          "eventId": "ffggh1asdjsdzxc",
          "anomaly": "snore",
          "eventStartSec": 0,
          "eventEndSec": 2,
          "confidence": 0.92,
        },
        {
          "eventId": "asdgh1asdj1hjk5h",
          "anomaly": "talk",
          "eventStartSec": 2,
          "eventEndSec": 6,
          "confidence": 0.98,
        },
      ],
    },
  ],
};
