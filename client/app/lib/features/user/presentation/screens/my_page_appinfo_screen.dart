import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';

class MyPageAppInfoScreen extends ConsumerWidget {
  const MyPageAppInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    'assets/icons/moon.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SLEEP TIGHT 정보',
                    style: AppTextStyles.titleT3Sb(color: AppColors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Menu items
            _MenuItem(label: '앱 버전', value: '1.00 ver', onTap: () => {}),
            _MenuItem(label: '이용 약관', value: '보기', onTap: () => {}),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: AppTextStyles.bodyB2Rg(color: AppColors.font1),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.value,
                    style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
                  ),
                  // SvgPicture.asset('assets/icons/chevron_right.svg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
