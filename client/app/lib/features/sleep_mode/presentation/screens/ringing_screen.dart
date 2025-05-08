import 'package:app/core/config/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RingingScreen extends StatelessWidget {
  const RingingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat(
      'MM월 dd일 EEEE',
      'ko_KR',
    ).format(now);
    final String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(now);

    return Scaffold(
      backgroundColor: Color(0xFFDFDFE5),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 16, color: AppColors.gray01),
          ),
          const SizedBox(height: 72),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 32,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          Center(
            child: Image.asset(
              'assets/images/wake_up.png',
              width: 200,
              fit: BoxFit.fitWidth,
            ),
          ),

          const SizedBox(height: 125),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        // Todo: 알람 끄기
                        context.go('/');
                      },
                      child: const Text(
                        '알람 끄기',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDFDFE5),
                        foregroundColor: AppColors.primaryHv,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        // Todo: 5분 뒤 다시 알람
                      },
                      child: const Text(
                        '5분 뒤 다시 알람',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
