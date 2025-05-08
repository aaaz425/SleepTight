import 'package:app/core/config/theme/color.dart';
import 'package:app/features/sleep_mode/presentation/widgets/alarm_toggle_row.dart';
import 'package:app/features/sleep_mode/presentation/widgets/time_slot_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Todo: 알람 조회 및 설정 로직 추가
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.timer_outlined, size: 28),
            SizedBox(width: 4),
            Text(
              '알람 시간을 설정해보세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        const SizedBox(height: 40),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TimeSlotPicker(),
          ),
        ),

        const SizedBox(height: 4),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AlarmToggleRow(),
          ),
        ),

        const SizedBox(height: 60),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 156),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                // Todo: 수면 시작
                context.go('/sleeping');
              },
              child: const Text('수면 시작', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}
