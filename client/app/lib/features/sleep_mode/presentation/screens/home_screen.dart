import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/home_mode_provider.dart';
import 'no_alarm_screen.dart';
import 'waiting_screen.dart';
import 'sleeping_screen.dart';
import 'ringing_screen.dart';
import 'wake_up_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeModeProvider);

    switch (homeState) {
      case HomeState.noAlarm:
        return const NoAlarmScreen();
      case HomeState.waiting:
        return const NoAlarmScreen();
      case HomeState.sleeping:
        return const NoAlarmScreen();
      case HomeState.ringing:
        return const NoAlarmScreen();
      case HomeState.wakeUp:
        return const NoAlarmScreen();
    }
  }
}
