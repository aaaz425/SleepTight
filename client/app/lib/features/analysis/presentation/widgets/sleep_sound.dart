import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';

class SleepSound extends ConsumerStatefulWidget {
  const SleepSound({super.key});

  @override
  ConsumerState<SleepSound> createState() => _SleepSoundState();
}

class _SleepSoundState extends ConsumerState<SleepSound> {
  int? _currentlyPlayingId;

  void _togglePlayback(int soundId) {
    // Todo: 음성 재생 추가
    setState(() {
      if (_currentlyPlayingId == soundId) {
        _currentlyPlayingId = null; // 멈춤
      } else {
        _currentlyPlayingId = soundId; // 재생 시작
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = mockSleepSoundData;
    final sounds = data['sounds'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          const SizedBox(height: 16),
          for (var i = 0; i < sounds.length; i++) _buildSoundItem(i, sounds[i]),
        ],
      ),
    );
  }

  Widget _buildSoundItem(int index, Map<String, dynamic> sound) {
    final soundId = sound['soundId'] as int;
    final start = sound['soundStartTime'];
    final end = sound['soundEndTime'];
    final isPlaying = _currentlyPlayingId == soundId;

    return GestureDetector(
      onTap: () => _togglePlayback(soundId),
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
              '$start ~ $end',
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
