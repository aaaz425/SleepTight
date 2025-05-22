import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';

class MyPageBodyScreen extends ConsumerWidget {
  const MyPageBodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    final height = "${user?.height} ${user?.lengthUnit}";
    final weight = "${user?.weight} ${user?.weightUnit}";

    return SafeArea(
      child: Scaffold(
        appBar: MyPageAppBar(onBack: () => context.pop()),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // Avatar placeholder
                  SvgPicture.asset(
                    'assets/icons/body_run.svg',
                    colorFilter: ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '신체 정보 설정',
                    style: AppTextStyles.titleT3Sb(color: AppColors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            // Menu items
            _MenuItem(
              label: '키',
              value: height,
              onTap: () => context.go(AppConfig.routes.mypageBodyHeight),
            ),
            _MenuItem(
              label: '몸무게',
              value: weight,
              onTap: () => context.go(AppConfig.routes.mypageBodyWeight),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _MenuItem({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // 터치 시 배경색 변경
        highlightColor: Colors.white.withValues(alpha: 0.06),
        splashColor: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyB2Rg(color: AppColors.font1),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (value != null)
                      Text(
                        value!,
                        style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
                      ),
                    SizedBox(width: 4),
                    SvgPicture.asset('assets/icons/chevron_right.svg'),
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
