import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/shared/widgets/custom_time_picker.dart';

class MyPageSleeptimeScreen extends ConsumerWidget {
  const MyPageSleeptimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    // 목표수면시간 7시간 30분
    final minDurationInMin = user?.minSleepDurationInMinutes;
    String formattedMinSleepDuration = '';
    if (minDurationInMin != null) {
      final hours = minDurationInMin ~/ 60;
      final minutes = minDurationInMin % 60;
      if (hours > 0) {
        formattedMinSleepDuration += '${hours}시간';
      }
      if (minutes > 0) {
        formattedMinSleepDuration += ' ${minutes}분';
      }
    }

    // 취침시간을 '오전/오후 X시 Y분' 형식으로 포맷
    final sleepTimeStr = user?.sleepTime;
    String formattedSleepTime = '';
    if (sleepTimeStr != null && sleepTimeStr.isNotEmpty) {
      final parts = sleepTimeStr.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final ap = h >= 12 ? '오후' : '오전';
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      formattedSleepTime = '$ap $hour12시${m > 0 ? ' $m분' : ''}';
    }
    // 기상시간을 '오전/오후 X시 Y분' 형식으로 포맷
    final wakeTimeStr = user?.wakeTime;
    String formattedWakeTime = '';
    if (wakeTimeStr != null && wakeTimeStr.isNotEmpty) {
      final parts = wakeTimeStr.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final ap = h >= 12 ? '오후' : '오전';
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      formattedWakeTime = '$ap $hour12시${m > 0 ? ' $m분' : ''}';
    }

    Future<String?> _showTimePicker() async {
      final t = await showCustomTimePicker(
        context: context,
        initialHour: 7,
        initialMinute: 0,
        showPeriodPicker: true,
      );
      if (t != null) {
        // do something with the selected time
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(onBack: () => context.pop()),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // Avatar placeholder
                  SvgPicture.asset(
                    'assets/icons/alarm.svg',
                    colorFilter: ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '수면 시간 설정',
                    style: AppTextStyles.titleT3Sb(color: AppColors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '최소 목표 수면 시간을 설정해주세요',
                style: AppTextStyles.bodyB2Rg(color: AppColors.font1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: label과 값
                  Row(
                    children: [
                      Text(
                        '목표 수면 시간',
                        style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formattedMinSleepDuration,
                        style: AppTextStyles.bodyB4Lt(color: AppColors.font2),
                      ),
                    ],
                  ),
                  // 오른쪽: 설정 이동 아이콘
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray01,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        '수정하기',
                        style: AppTextStyles.button3Md(
                          color: AppColors.primaryHv,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 10, thickness: 2, color: AppColors.gray04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: label과 값
                  Row(
                    children: [
                      Text(
                        '취침 시간',
                        style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formattedSleepTime,
                        style: AppTextStyles.bodyB4Lt(color: AppColors.font2),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray01,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        '수정하기',
                        style: AppTextStyles.button3Md(color: AppColors.font1),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: label과 값
                  Row(
                    children: [
                      Text(
                        '기상 시간',
                        style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formattedWakeTime,
                        style: AppTextStyles.bodyB4Lt(color: AppColors.font2),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray01,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        final t = await _showTimePicker();
                        if (t != null) {
                          // do something with the selected time
                        }
                      },
                      child: Text(
                        '수정하기',
                        style: AppTextStyles.button3Md(color: AppColors.font1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
