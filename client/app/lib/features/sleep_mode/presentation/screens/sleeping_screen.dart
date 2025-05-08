import 'package:app/core/config/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SleepingScreen extends StatelessWidget {
  const SleepingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat(
      'MM월 dd일 EEEE',
      'ko_KR',
    ).format(now);
    final String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(now);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 84, bottom: 114),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, color: AppColors.font2),
            ),

            SizedBox(height: 45),

            Text(
              formattedTime,
              style: const TextStyle(fontSize: 32, color: AppColors.primaryHv2),
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '알람',
                  style: const TextStyle(fontSize: 16, color: AppColors.font2),
                ),

                SizedBox(width: 10),

                Text(
                  // Todo: 알람 로직 완성 시 수정
                  '오전 07:30',
                  style: const TextStyle(fontSize: 16, color: AppColors.white),
                ),
              ],
            ),

            SizedBox(height: 14),

            Container(
              decoration: BoxDecoration(gradient: AppColors.linearGradient3),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 104,
                  bottom: 104,
                  left: 20,
                  right: 20,
                ),
                child: Center(
                  // Todo: 파형 그래프 수정
                  child: Image.asset(
                    'assets/images/sound_wave.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),

            SizedBox(height: 34),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 156),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgRegular,
                    foregroundColor: AppColors.primaryHv,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    // Todo: 수면 종료
                    context.go('/');
                  },
                  child: const Text('수면 종료', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
