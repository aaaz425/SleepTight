import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmTimeDisplay extends ConsumerWidget {
  const AlarmTimeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAlarm = ref.watch(alarmTimeNotifierProvider);

    return asyncAlarm.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (alarm) {
        final time =
            '${alarm.amPm} ${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}';
        return Text(
          time,
          style: const TextStyle(fontSize: 16, color: AppColors.primary),
        );
      },
    );
  }
}
