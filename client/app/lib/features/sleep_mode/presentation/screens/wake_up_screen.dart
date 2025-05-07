import 'package:app/core/config/theme/color.dart';
import 'package:app/features/sleep_mode/presentation/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WakeUpScreen extends StatelessWidget {
  const WakeUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: ProgressBar(),
              ),
            ),

            const SizedBox(height: 207),

            Center(
              child: Image.asset(
                'assets/images/check_blue.png',
                width: 120,
                fit: BoxFit.fitWidth,
              ),
            ),

            SizedBox(height: 12),

            Text(
              '편안한 밤 되셨나요?',
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 167),

            Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 156),
                  child: SizedBox(
                    height: 48,
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
                        // Todo: 일지 작성 페이지로 이동
                      },
                      child: const Text(
                        '일지 작성하기',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 156),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.font2,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        context.go('/');
                      },
                      child: const Text('닫기', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
