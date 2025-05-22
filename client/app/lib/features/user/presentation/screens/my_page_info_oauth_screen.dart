import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_header.dart';

class MyPageInfoOauthScreen extends ConsumerWidget {
  const MyPageInfoOauthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    // TODO: 추후 oauth 사이트가 늘어나면 분기 처리해야 함.

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
              MyPageHeader(title: '간편로그인'),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  '현재 카카오 계정과 간편 로그인이 연동되어 있습니다. ',
                  style: AppTextStyles.bodyB4Lt(color: AppColors.font2),
                ),
              ),
              SizedBox(height: 28),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/kakao_oauth.svg'),
                    const SizedBox(height: 10),
                    Text(
                      '카카오',
                      style: AppTextStyles.bodyB4Rg(color: AppColors.font1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
