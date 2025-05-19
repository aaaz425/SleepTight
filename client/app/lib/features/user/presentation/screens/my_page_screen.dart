import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    final fullName = "${user?.lastName}${user?.firstName}";
    final displayName = fullName != "" ? '$fullName 님' : '게스트 님';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9.5),
            child: Text(
              '마이페이지',
              style: AppTextStyles.headlineH3Sb(color: AppColors.white),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go(AppConfig.routes.mypageInfo),
                // 터치 시 배경색 변경
                highlightColor: AppColors.white.withValues(alpha: 0.06),
                splashColor: AppColors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Avatar placeholder
                      Image.asset(
                        'assets/images/profile_3d.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.titleT3Sb(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '내 정보 설정',
                              style: AppTextStyles.bodyB4Rg(
                                color: AppColors.font2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SvgPicture.asset('assets/icons/chevron_right.svg'),
                    ],
                  ),
                ),
              ),
            ),
            Divider(color: AppColors.gray06, thickness: 0.25, height: 0),
            SizedBox(height: 20),
            // Menu items
            _MenuItem(
              icon: SvgPicture.asset('assets/icons/body_run.svg'),
              label: '신체 정보 설정',
              onTap: () => context.go(AppConfig.routes.mypageBody),
            ),
            Divider(height: 4, color: Colors.transparent),
            _MenuItem(
              icon: SvgPicture.asset('assets/icons/alarm.svg'),
              label: '수면 시간 설정',
              onTap: () => context.go(AppConfig.routes.mypageSleepTime),
            ),
            Divider(height: 4, color: Colors.transparent),
            _MenuItem(
              icon: SvgPicture.asset('assets/icons/bell_red_dot.svg'),
              label: '알림 설정',
              onTap: () => context.go(AppConfig.routes.mypagePush),
            ),
            Divider(height: 4, color: Colors.transparent),
            _MenuItem(
              icon: SvgPicture.asset('assets/icons/moon.svg'),
              label: 'SLEEP TIGHT 정보',
              onTap: () => context.go(AppConfig.routes.mypageAppInfo),
            ),
            Divider(height: 4, color: Colors.transparent),
            _MenuItem(
              icon: SvgPicture.asset('assets/icons/info.svg'),
              label: '내 정보 내보내기',
              onTap: () {
                debugPrint('내 정보 내보내기');
              },
              trailing: SvgPicture.asset('assets/icons/paper_plane.svg'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  // Optional trailing icon; use default SVG arrow if null
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback to custom SVG arrow if no trailing provided
    final trailingWidget =
        trailing ?? SvgPicture.asset('assets/icons/chevron_right.svg');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // 터치 시 배경색 변경
        highlightColor: Colors.white.withValues(alpha: 0.06),
        splashColor: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            children: [
              icon,
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.titleT3Rg(color: AppColors.font1),
                ),
              ),
              SizedBox(width: 8),
              trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}
