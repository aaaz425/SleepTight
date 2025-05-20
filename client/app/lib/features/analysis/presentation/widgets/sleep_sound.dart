import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_sound_model.dart';
import 'package:sleep_tight/features/analysis/data/services/sleep_sound_sevice.dart';

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

  @override
  void initState() {
    super.initState();
    _sleepSoundsFuture = fetchSleepSounds(ref, widget.reportId);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback(int soundId, String url) async {
    if (_currentlyPlayingId == soundId) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingId = null;
      });
    } else {
      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        setState(() {
          _currentlyPlayingId = soundId;
        });

        // 자동 종료 후 상태 초기화
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _currentlyPlayingId = null;
            });
          }
        });
      } catch (e) {
        print('🎧 재생 오류: $e');
      }
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
              for (int i = 0; i < sounds.length; i++)
                _buildSoundItem(i, sounds[i]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundItem(int index, SleepSoundModel sound) {
    final isPlaying = _currentlyPlayingId == sound.soundId;

    return GestureDetector(
      onTap: () => _togglePlayback(sound.soundId, sound.clipUrl),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '이상현상 ${index + 1}',
                  style: TextStyle(color: AppColors.font1, fontSize: 12),
                ),
                const SizedBox(width: 2),
                SvgPicture.asset(
                  isPlaying
                      ? "assets/icons/pause.svg"
                      : "assets/icons/play.svg",
                  color: AppColors.gray06,
                  width: 12,
                  height: 12,
                ),
              ],
            ),
            Text(
              '${sound.soundStartTime} ~ ${sound.soundEndTime}',
              style: TextStyle(color: AppColors.font2, fontSize: 12),
            ),
          ],
        ),
      ),
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
