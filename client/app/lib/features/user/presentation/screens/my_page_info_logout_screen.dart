import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

class MyPageInfoLogoutScreen extends ConsumerWidget {
  const MyPageInfoLogoutScreen({super.key});

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
                  child: Text(
                    '정말 로그아웃하시겠습니까?',
                    style: AppTextStyles.titleT2Sb(color: AppColors.white),
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
                    // TODO: 로그아웃 API
                    ref.read(userModelProvider.notifier).logout();
                    context.pop();
                  },
                  height: 48,
                  text: '로그아웃',
                  theme: 'gray',
                ),
                SizedBox(height: 4),
                CustomButton(
                  onPressed: () => context.pop(),
                  height: 48,
                  text: '이전으로 돌아가기',
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
