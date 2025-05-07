import 'package:app/core/config/theme/theme.dart';
import 'package:app/core/state/navigation/bottom_nav_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        ref.read(bottomNavIndexProvider.notifier).set(index);

        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/analysis');
            break;
          case 2:
            context.go('/coach');
            break;
          case 3:
            context.go('/sound');
            break;
          case 4:
            context.go('/mypage');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: '홈',
          backgroundColor: AppTheme.theme.colorScheme.primary,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: '수면분석',
          backgroundColor: AppTheme.theme.colorScheme.primary,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.smart_toy_outlined),
          label: '수면코치',
          backgroundColor: AppTheme.theme.colorScheme.primary,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.headphones_outlined),
          label: '사운드',
          backgroundColor: AppTheme.theme.colorScheme.primary,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: '마이페이지',
          backgroundColor: AppTheme.theme.colorScheme.primary,
        ),
      ],
      selectedItemColor:
          AppTheme.theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          AppTheme.theme.bottomNavigationBarTheme.unselectedItemColor,
      selectedLabelStyle: const TextStyle(fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
    );
  }
}
