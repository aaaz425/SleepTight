import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmToggleRow extends ConsumerWidget {
  const AlarmToggleRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmAsync = ref.watch(alarmTimeNotifierProvider);

    return alarmAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (alarm) {
        final isChecked = !alarm.isAlarmOn;

        Future<void> showInfoDialog() async {
          if (!isChecked) {
            await showDialog(
              context: context,
              barrierColor: Colors.black.withValues(
                alpha: 0.7,
                red: 0,
                green: 0,
                blue: 0,
              ),
              barrierDismissible: true,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Image.asset(
                            'assets/images/clock_no_alarm.png',
                            width: 100,
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '알람이 울리지 않고,\n',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: '수면만 분석',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const TextSpan(
                                  text: '할게요!',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 0.25,
                            color: AppColors.gray05,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '확인',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          await ref.read(alarmTimeNotifierProvider.notifier).toggleAlarm();
        }

        return InkWell(
          onTap: showInfoDialog,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (_) => showInfoDialog(),
                checkColor: AppColors.white,
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return Colors.transparent;
                }),
                side: const BorderSide(color: AppColors.font2, width: 2),
              ),
              const Icon(
                Icons.timer_off_outlined,
                size: 16,
                color: AppColors.font2,
              ),
              const SizedBox(width: 4),
              const Text(
                '알람 설정 안할래요',
                style: TextStyle(fontSize: 13, color: AppColors.font2),
              ),
            ],
          ),
        );
      },
    );
  }
}
