import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';

class MyPagePushScreen extends ConsumerWidget {
  const MyPagePushScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(onBack: () => context.pop()),
        body: Center(
          child: Text(
            '알림 설정',
            style: AppTextStyles.titleT3Sb(color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
