import 'dart:async';
import 'package:sleep_tight/core/utils/time.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AlarmTriggerWatcher extends ConsumerStatefulWidget {
  final Widget child;
  const AlarmTriggerWatcher({super.key, required this.child});

  @override
  ConsumerState<AlarmTriggerWatcher> createState() =>
      _AlarmTriggerWatcherState();
}

class _AlarmTriggerWatcherState extends ConsumerState<AlarmTriggerWatcher> {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final asyncAlarm = ref.read(alarmTimeNotifierProvider);
      final alarmData = asyncAlarm.value;

      if (alarmData == null || _navigated) return;

      final alarmDateTime = getNextAlarmDateTime(alarmData);
      final now = DateTime.now();

      if (now.isAfter(alarmDateTime)) {
        _navigated = true;
        _timer?.cancel();
        if (!mounted) return;

        if (alarmData.isAlarmOn) {
          context.go('/ringing');
        } else {
          context.go('/wake_up');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
