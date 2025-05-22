import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/data/models/enums/country.dart';
import 'package:sleep_tight/features/user/data/models/enums/gender.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';

class MyPageInfoScreen extends ConsumerWidget {
  const MyPageInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    final fullName = "${user?.lastName}${user?.firstName}";
    final birthDate = user?.birthDate;
    // Parse the gender string into the enum, then get the Korean label
    final gender = Gender.fromJson(user?.gender)?.toKor ?? '';
    final nationality = Country.findByEnglishName(user?.country) ?? '';

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
                  SvgPicture.asset('assets/icons/user.svg'),
                  const SizedBox(width: 4),
                  Text(
                    "$fullName 님의 정보",
                    style: AppTextStyles.titleT3Sb(color: AppColors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            // Menu items
            _MenuItem(
              label: '이름',
              value: fullName,
              onTap: () => context.go(AppConfig.routes.mypageInfoName),
            ),
            _MenuItem(
              label: '생년월일',
              value: birthDate,
              onTap: () => context.go(AppConfig.routes.mypageInfoBirthDate),
            ),
            _MenuItem(
              label: '성별',
              value: gender,
              onTap: () => context.go(AppConfig.routes.mypageInfoGender),
            ),
            _MenuItem(
              label: '국적',
              value: nationality,
              onTap: () => context.go(AppConfig.routes.mypageInfoNationality),
            ),
            Divider(color: AppColors.gray04, thickness: 2, height: 10),
            _MenuItem(
              label: '간편 로그인',
              onTap: () => context.go(AppConfig.routes.mypageInfoOauth),
            ),
            _MenuItem(
              label: '로그아웃',
              onTap: () => context.go(AppConfig.routes.mypageInfoLogout),
            ),
            _MenuItem(
              label: 'SLEEP TIGHT 탈퇴하기',
              labelColor: AppColors.warning,
              onTap: () => context.go(AppConfig.routes.mypageInfoWithdraw),
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
  final Color? labelColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    this.value,
    this.labelColor,
    required this.onTap,
  });

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
                  style: AppTextStyles.bodyB2Rg(
                    color: labelColor ?? AppColors.font1,
                  ),
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
