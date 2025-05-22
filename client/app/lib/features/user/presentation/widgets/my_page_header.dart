import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';

/// Header title for MyPage screens
class MyPageHeader extends StatelessWidget {
  final String title;
  final String? icon;

  const MyPageHeader({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[SvgPicture.asset(icon!), SizedBox(width: 4)],
          Text(title, style: AppTextStyles.titleT3Sb(color: AppColors.white)),
        ],
      ),
    );
  }
}
