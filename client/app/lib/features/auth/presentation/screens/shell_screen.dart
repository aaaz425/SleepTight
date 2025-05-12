import 'package:app/features/auth/presentation/widgets/shell_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScreen extends StatelessWidget {
  final Widget body;
  final bool hasBottomNav;

  const ShellScreen({super.key, required this.body, this.hasBottomNav = true});

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
    return Scaffold(
      body: body,
      bottomNavigationBar:
          hasBottomNav
              ? Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                ),
                child: ShellBottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (index) => _onItemTapped(index, context),
                ),
              )
              : null,
    );
  }
}
