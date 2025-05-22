import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'alarm_provider.g.dart';

class AlarmTime {
  final String amPm;
  final int hour;
  final int minute;
  final bool isAlarmOn;

  AlarmTime({
    required this.amPm,
    required this.hour,
    required this.minute,
    required this.isAlarmOn,
  });

  AlarmTime copyWith({String? amPm, int? hour, int? minute, bool? isAlarmOn}) {
    return AlarmTime(
      amPm: amPm ?? this.amPm,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isAlarmOn: isAlarmOn ?? this.isAlarmOn,
    );
  }

  static Future<AlarmTime> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final amPm = prefs.getString('amPm') ?? '오전';
    final hour = prefs.getInt('hour') ?? 7;
    final minute = prefs.getInt('minute') ?? 0;
    final isAlarmOn = prefs.getBool('isAlarmOn') ?? true;

    return AlarmTime(
      amPm: amPm,
      hour: hour,
      minute: minute,
      isAlarmOn: isAlarmOn,
    );
  }

  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('amPm', amPm);
    await prefs.setInt('hour', hour);
    await prefs.setInt('minute', minute);
    await prefs.setBool('isAlarmOn', isAlarmOn);
  }
}

@Riverpod(keepAlive: true)
class AlarmTimeNotifier extends _$AlarmTimeNotifier {
  @override
  FutureOr<AlarmTime> build() async {
    return await AlarmTime.loadFromPreferences();
  }

  Future<void> toggleAlarm() async {
    final current = await future;
    final updated = current.copyWith(isAlarmOn: !current.isAlarmOn);
    await updated.saveToPreferences();
    state = AsyncValue.data(updated);
  }

  Future<void> updateTime(AlarmTime newTime) async {
    // 분 값이 제대로 바뀌었는지 확인하기
    final current = await future;
    final updated = current.copyWith(
      hour: newTime.hour,
      minute: newTime.minute,
      amPm: newTime.amPm,
    );

    await updated.saveToPreferences();
    state = AsyncValue.data(updated);
  }

  Future<void> snoozeAlarm() async {
    final current = await future;

    final now = DateTime.now();
    final snoozeTime = now.add(const Duration(minutes: 5));

    final int hour24 = snoozeTime.hour;
    final String amPm = hour24 >= 12 ? '오후' : '오전';
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    final updated = current.copyWith(
      hour: hour12,
      minute: snoozeTime.minute,
      amPm: amPm,
    );

    await updated.saveToPreferences();
    state = AsyncValue.data(updated);
  }
}
