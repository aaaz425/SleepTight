import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// Custom AppBar for MyPage screens with back button
class MyPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  const MyPageAppBar({super.key, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: InkWell(
          onTap: onBack ?? () => context.pop(),
          child: SvgPicture.asset('assets/icons/chevron_left.svg'),
        ),
      ),
    );
  }
}
