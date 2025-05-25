import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
import 'package:sleep_tight/shared/widgets/shell_bottom_nav_bar.dart'; // 경로 확인

class ShellScreen extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? header;
  final bool hasBottomNav;

  const ShellScreen({
    super.key,
    required this.body,
    this.header,
    this.hasBottomNav = true,
  });

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  final ValueNotifier<double> playerExpandProgress = ValueNotifier<double>(0.0);

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = ShellBottomNavBar.navItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    return idx == -1 ? 0 : idx;
  }

  void _onItemTapped(int index) {
    GoRouter.of(context).go(ShellBottomNavBar.navItems[index].route);
  }

  // shell_screen.dart
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final hasPlayer = ref.watch(
          audioControllerProvider.select((s) => s.music != null),
        );
        final currentIndex = _calculateSelectedIndex(context);
        final double miniPlayerMinHeight = 52.0; // 명확한 변수명 사용

        debugPrint(
          "ShellScreen: Building. hasPlayer: $hasPlayer, miniPlayerMinHeight: $miniPlayerMinHeight",
        );
        debugPrint(
          "ShellScreen: MediaQuery.of(context).size.height: ${MediaQuery.of(context).size.height}",
        );

        Widget? bottomNav;
        if (widget.hasBottomNav) {
          bottomNav = Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            child: ShellBottomNavBar(
              currentIndex: currentIndex,
              onTap: _onItemTapped,
            ),
          );
        }

        return Scaffold(
          appBar: widget.header,
          body: Stack(
            clipBehavior: Clip.none, // Stack 경계 밖으로 그리는 것을 허용
            children: [
              // widget.body는 Miniplayer 공간을 고려하여 Padding 적용
              Padding(
                padding: EdgeInsets.only(
                  bottom: hasPlayer ? miniPlayerMinHeight : 0.0,
                ),
                child: widget.body,
              ),
            ],
          ),
          bottomNavigationBar: widget.hasBottomNav ? bottomNav : null,
        );
      },
    );
  }
}
