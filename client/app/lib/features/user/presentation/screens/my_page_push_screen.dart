import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/user/presentation/widgets/my_page_appbar.dart';

class MyPagePushScreen extends ConsumerWidget {
  const MyPagePushScreen({super.key});

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
                    'assets/icons/bell_red_dot_solid.svg',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '알림 설정',
                    style: AppTextStyles.titleT3Sb(color: AppColors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Menu items
            _MenuItem(label: '수면 코칭 알림', onTap: () => context.pop()),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.label, required this.onTap});

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isEnabled = false;

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
                  FlutterSwitch(
                    width: 52,
                    height: 28,
                    toggleSize: 24, // thumb 직경
                    value: _isEnabled,
                    onToggle: (val) => setState(() => _isEnabled = val),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.gray04,
                    toggleColor: AppColors.white,
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
