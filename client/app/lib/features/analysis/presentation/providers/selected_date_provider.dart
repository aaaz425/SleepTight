import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now(); // 초기값 = 오늘
  }

  void update(DateTime newDate) {
    state = newDate;
  }
}
