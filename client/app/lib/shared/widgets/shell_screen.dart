import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
import 'package:sleep_tight/features/music/presentation/widgets/fullscreen_player.dart';
import 'package:sleep_tight/features/music/presentation/widgets/mini_player.dart';
import 'package:sleep_tight/shared/widgets/shell_bottom_nav_bar.dart'; // 경로 확인
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
  bool _panelWasOpen = false;

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
        // audioControllerProvider에서 music 객체의 존재 여부만 관찰 (불필요한 재빌드 최소화)
        final hasPlayer = ref.watch(
          audioControllerProvider.select((s) => s.music != null),
        );
        final currentIndex = _calculateSelectedIndex(context);

        // --- 디버깅 로그 추가 ---
        final currentMinHeight = hasPlayer ? 52.0 : 0.0;
        debugPrint(
          "ShellScreen: Building SlidingUpPanel. hasPlayer: $hasPlayer, minHeight: $currentMinHeight",
        );
        // ----------------------

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
            // 하단 네비게이션 바가 있을 경우 그 높이만큼 마진을 줌
            bottom: widget.hasBottomNav ? kBottomNavigationBarHeight : 0,
          ),
          minHeight: currentMinHeight, // 계산된 minHeight 사용
          maxHeight: MediaQuery.of(context).size.height,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          // hasPlayer 상태에 따라 MiniPlayer 또는 빈 SizedBox를 collapsed 위젯으로 제공
          collapsed: hasPlayer ? const MiniPlayer() : const SizedBox.shrink(),
          panelBuilder:
              (scrollController) =>
                  FullscreenPlayer(scrollController: scrollController),
          onPanelOpened: () {
            debugPrint("ShellScreen: Panel Opened");
            _panelWasOpen = true;
          },
          onPanelClosed: () {
            debugPrint(
              "ShellScreen: Panel Closed callback triggered. _panelWasOpen: $_panelWasOpen",
            );
            if (_panelWasOpen) {
              // 패널이 FullscreenPlayer 상태에서 MiniPlayer 상태로 돌아갈 때
              _panelWasOpen = false;
            } else {
              // 패널이 MiniPlayer 상태에서 완전히 닫히려고 할 때 (스와이프 다운 등)
              final audioState = ref.read(
                audioControllerProvider,
              ); // 현재 상태 읽기 (watch 아님)
              if (audioState.music != null) {
                debugPrint(
                  "ShellScreen: onPanelClosed - Calling stop() because music exists.",
                );
                ref.read(audioControllerProvider.notifier).stop();
              } else {
                debugPrint(
                  "ShellScreen: onPanelClosed - Not calling stop() because music is already null.",
                );
              }
              // _panelController.hide(); // 이 호출은 제거하거나 주석 처리합니다.
              // minHeight가 0이 되면 패널은 자연스럽게 사라져야 합니다.
            }
          },
          body: Scaffold(
            appBar: widget.header,
            body: Padding(
              // MiniPlayer가 있을 경우 body 내용이 가려지지 않도록 하단에 패딩 추가
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
