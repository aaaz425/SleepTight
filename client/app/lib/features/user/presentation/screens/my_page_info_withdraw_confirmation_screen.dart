import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';
import 'dart:io';

class MyPageInfoWithdrawConfirmationScreen extends ConsumerWidget {
  const MyPageInfoWithdrawConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/sleep_moon.png',
                width: 240,
                height: 240,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: '당신의 밤이 편안하길 바래요\n그래도, 가끔은 저희가 생각날지도 몰라요\n\n',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Pretendard',
                    height: 1.4,
                    letterSpacing: -0.375,
                  ),
                  children: [
                    TextSpan(
                      text: '90일',
                      style: TextStyle(
                        color: AppColors.primaryHv,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Pretendard',
                        height: 1.4,
                        letterSpacing: -0.375,
                      ),
                    ),
                    TextSpan(
                      text: ' 내에 돌아온다면\n저희는 다시 만날 수 있어요',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Pretendard',
                        height: 1.4,
                        letterSpacing: -0.375,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  onPressed: () {
                    context.go(AppConfig.routes.welcome);
                  },
                  height: 48,
                  text: '다시 회원가입하기',
                ),
                SizedBox(height: 4),
                CustomButton(
                  onPressed: () {
                    exit(0);
                  },
                  height: 48,
                  text: '앱 종료하기',
                  theme: 'text',
                  textColor: AppColors.font2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
