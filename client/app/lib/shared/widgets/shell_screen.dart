import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/shared/widgets/shell_bottom_nav_bar.dart';

class ShellScreen extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? header;
  final bool hasPlayer;
  final bool hasBottomNav;
  const ShellScreen({
    super.key,
    required this.body,
    this.header,
    this.hasPlayer = true,
    this.hasBottomNav = true,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = ShellBottomNavBar.navItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    return idx == -1 ? 0 : idx;
  }

  void _onItemTapped(int index, BuildContext context) {
    GoRouter.of(context).go(ShellBottomNavBar.navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    Widget? bottomNav;
    if (hasBottomNav) {
      bottomNav = Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: ShellBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(index, context),
        ),
      );
    }

    return Scaffold(
      appBar: header,
      body: body,
      // bottomSheet: hasPlayer ? const MiniPlayer() : null, // 필요시 사용
      bottomNavigationBar: bottomNav,
    );
  }
}
