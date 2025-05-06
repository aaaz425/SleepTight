import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_mode_provider.g.dart';

enum HomeState {
  noAlarm, // 알람 설정 유도 화면
  waiting, // 알람 설정 및 수면 대기 화면
}

@riverpod
class HomeMode extends _$HomeMode {
  @override
  HomeState build() {
    return HomeState.noAlarm; // 초기값
  }

  void set(HomeState newState) => state = newState;
}
