import 'package:sleep_tight/features/sleep_mode/presentation/provider/alarm_provider.dart';

DateTime getNextAlarmDateTime(AlarmTime alarm) {
  final now = DateTime.now();
  int hour = alarm.hour;
  if (alarm.amPm == '오후' && hour != 12) hour += 12;
  if (alarm.amPm == '오전' && hour == 12) hour = 0;

  final alarmTime = DateTime(now.year, now.month, now.day, hour, alarm.minute);

  if (alarmTime.difference(now).inSeconds < -1) {
    return alarmTime.add(const Duration(days: 1));
  } else {
    return alarmTime;
  }
}
