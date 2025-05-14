import 'package:sleep_tight/features/sleep_mode/presentation/provider/alarm_provider.dart';

class AlarmService {
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
  }
}
