import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alarm_checkbox_provider.g.dart';

@riverpod
class AlarmCheckbox extends _$AlarmCheckbox {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
