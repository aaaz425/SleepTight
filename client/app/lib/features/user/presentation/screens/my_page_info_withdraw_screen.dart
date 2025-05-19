import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

class MyPageInfoWithdrawScreen extends ConsumerWidget {
  const MyPageInfoWithdrawScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);

    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(
          onBack: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: '정말 SLEEP TIGHT를 \n',
                      style: AppTextStyles.titleT2Sb(color: AppColors.white),
                      children: [
                        TextSpan(
                          text: '탈퇴',
                          style: AppTextStyles.titleT2Sb(color: AppColors.red),
                        ),
                        TextSpan(
                          text: '하시겠습니까?',
                          style: AppTextStyles.titleT2Sb(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                    // TODO: 탈퇴하기 API
                    // ref.read(userModelProvider.notifier).logout();
                    context.go(AppConfig.routes.mypageInfoWithdrawConfirmation);
                  },
                  height: 48,
                  text: 'SLEEP TIGHT 탈퇴하기',
                  theme: 'gray',
                  textColor: AppColors.warning,
                ),
                SizedBox(height: 4),
                CustomButton(
                  onPressed: () => context.pop(),
                  height: 48,
                  text: '이전으로 돌아가기',
                  theme: 'text',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
