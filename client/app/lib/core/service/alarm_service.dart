import 'package:alarm/alarm.dart';
import 'package:app/features/sleep_mode/presentation/provider/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlarmService {
  static Future<void> init() async {
    await Alarm.init();
  }

  static Future<void> schedule(AlarmTime alarmTime) async {
    int hour = alarmTime.hour;
    if (alarmTime.amPm == '오후' && hour < 12) hour += 12;
    if (alarmTime.amPm == '오전' && hour == 12) hour = 0;

    final now = DateTime.now();
    DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      alarmTime.minute,
    );
    if (dateTime.isBefore(now)) {
      dateTime = dateTime.add(Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: 1,
      dateTime: dateTime,
      assetAudioPath: 'assets/sound/kirby-alarm-clock-127079.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.5,
        fadeDuration: Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: 'Sleep Tight',
        body: '기상 시간입니다!',
        stopButton: '알람끄기',
      ),
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> cancel() async {
    await Alarm.stop(1);
  }

  static void listenAlarm(BuildContext context) {
    bool _hasNavigatedToRinging = false;

    Alarm.ringing.listen((alarmSettings) async {
      if (_hasNavigatedToRinging) return;
      _hasNavigatedToRinging = true;
      context.go('/ringing');
    });
  }
}
