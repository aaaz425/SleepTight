import 'package:app/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShellScreen extends ConsumerWidget {
  final PreferredSizeWidget? header;
  final Widget body;
  final bool hasPlayer;
  final bool hasBottomNav;

  const ShellScreen({
    super.key,
    this.header,
    required this.body,
    this.hasPlayer = true,
    this.hasBottomNav = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: header,
      body: body,
      // Todo: 미니 플레이어 추가 시 주석 해제
      // bottomSheet: hasPlayer ? const MiniPlayer() : null,
      bottomNavigationBar: hasBottomNav ? const AppBottomNavigationBar() : null,
    );
  }
}
