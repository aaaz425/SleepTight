import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
import 'package:sleep_tight/features/music/presentation/widgets/fullscreen_player.dart';
import 'package:sleep_tight/features/music/presentation/widgets/mini_player.dart';
import 'package:sleep_tight/shared/widgets/shell_bottom_nav_bar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  final PanelController _panelController = PanelController();

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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final hasPlayer = ref.watch(
          audioControllerProvider.select((s) => s.music != null),
        );
        final currentIndex = _calculateSelectedIndex(context);

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

        return SlidingUpPanel(
          controller: _panelController,
          margin: EdgeInsets.only(
            bottom: widget.hasBottomNav ? kBottomNavigationBarHeight : 0,
          ),
          minHeight: hasPlayer ? 52 : 0,
          maxHeight: MediaQuery.of(context).size.height,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          collapsed: hasPlayer ? const MiniPlayer() : const SizedBox.shrink(),
          panelBuilder: (sc) => FullscreenPlayer(scrollController: sc),
          onPanelClosed: () {
            _panelController.hide();
            // 패널 닫힐 때 audioController.stop() 호출
            ref.read(audioControllerProvider.notifier).stop();
          },
          body: Scaffold(
            appBar: widget.header,
            body: Padding(
              padding: EdgeInsets.only(bottom: hasPlayer ? 52 : 0),
              child: widget.body,
            ),
            bottomNavigationBar: widget.hasBottomNav ? bottomNav : null,
          ),
        );
      },
    );
  }
}
