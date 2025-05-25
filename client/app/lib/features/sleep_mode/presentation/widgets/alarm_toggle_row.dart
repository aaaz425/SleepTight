import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:group_button/group_button.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/alarm_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

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
                                TextSpan(
                                  text: '알람이 울리지 않고,\n',
                                  style: AppTextStyles.bodyB1Rg(
                                    color: AppColors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: '수면만 분석',
                                  style: AppTextStyles.bodyB1Rg(
                                    color: AppColors.primaryHv,
                                  ),
                                ),
                                TextSpan(
                                  text: '할게요!',
                                  style: AppTextStyles.bodyB1Rg(
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
                            child: CustomButton(
                              height: 40,
                              onPressed: () => Navigator.of(context).pop(),
                              text: '확인',
                              theme: 'text',
                              textColor: AppColors.primary,
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

        return GroupButton<String>(
          isRadio: false,
          enableDeselect: true,
          controller: GroupButtonController(
            selectedIndexes: isChecked ? [0] : [],
          ),
          buttons: const ['알람 설정 안할래요'],
          buttonBuilder: (selected, value, context) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.gray06,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child:
                      selected
                          ? Expanded(
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/check.svg',
                                width: 12,
                                colorFilter: ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/no_alarm.svg',
                  width: 16,
                  colorFilter: ColorFilter.mode(
                    AppColors.gray06,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyB3Rg(color: AppColors.font2),
                ),
              ],
            );
          },
          options: GroupButtonOptions(
            groupingType: GroupingType.wrap,
            mainGroupAlignment: MainGroupAlignment.center,
            crossGroupAlignment: CrossGroupAlignment.center,
            direction: Axis.horizontal,
            spacing: 2,
            runSpacing: 0,
            selectedShadow: const [],
            unselectedShadow: const [],
            selectedColor: Colors.transparent,
            unselectedColor: Colors.transparent,
            selectedBorderColor: AppColors.primary,
            unselectedBorderColor: AppColors.gray06,
            elevation: 0,
          ),
          onSelected: (val, idx, selected) async {
            if (selected) {
              await showInfoDialog();
            } else {
              await ref.read(alarmTimeNotifierProvider.notifier).toggleAlarm();
            }
          },
        );
      },
    );
  }
}
