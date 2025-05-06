import 'package:app/core/config/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({super.key});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Memo: 프로그레스 바 시간 변경
      duration: const Duration(seconds: 10),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: Color(0x29787880),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.accessibleBlue,
            ),
            borderRadius: BorderRadius.circular(6),
          );
        },
      ),
    );
  }
}
