import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/widgets/progress_bar.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

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
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/check_blue.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(height: 12),

                    Text(
                      '편안한 밤 되셨나요?',
                      style: AppTextStyles.titleT2Rg(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Column(
                children: [
                  CustomButton(
                    width: 156,
                    height: 48,
                    onPressed: () {
                      context.go(
                        Uri(
                          path: AppConfig.routes.sleepAnalysis,
                          queryParameters: {'tab': 'diary'},
                        ).toString(),
                      );
                    },
                    text: '일지 작성하기',
                    textStyle: AppTextStyles.button1Sb(color: AppColors.white),
                    textColor: AppColors.white,
                  ),
                  SizedBox(height: 4),
                  CustomButton(
                    width: 156,
                    height: 48,
                    onPressed: () {
                      context.go(AppConfig.routes.home);
                    },
                    text: '닫기',
                    theme: 'text',
                    textStyle: AppTextStyles.button1Sb(color: AppColors.font2),
                    textColor: AppColors.font2,
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
