import 'package:app/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShellBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const ShellBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static final navItems = [
    NavItem(
      route: AppConfig.routes.home,
      label: '홈',
      icon: 'assets/icons/home_outlined.svg',
      activeIcon: 'assets/icons/home_solid.svg',
    ),
    NavItem(
      route: AppConfig.routes.sleepAnalysis,
      label: '수면분석',
      icon: 'assets/icons/analysis_outlined.svg',
      activeIcon: 'assets/icons/analysis_solid.svg',
    ),
    NavItem(
      route: AppConfig.routes.sleepCoach,
      label: '수면코치',
      icon: 'assets/icons/bot_outlined.svg',
      activeIcon: 'assets/icons/bot_solid.svg',
    ),
    NavItem(
      route: AppConfig.routes.sound,
      label: '사운드',
      icon: 'assets/icons/headphone_outlined.svg',
      activeIcon: 'assets/icons/headphone_solid.svg',
    ),
    NavItem(
      route: AppConfig.routes.mypage,
      label: '마이페이지',
      icon: 'assets/icons/mypage_outlined.svg',
      activeIcon: 'assets/icons/mypage_solid.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF121212),
      items:
          navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    item.icon,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFA6A6A6),
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    item.activeIcon,
                    colorFilter:
                        item.label == '수면분석' ||
                                item.label == '사운드' ||
                                item.label == '마이페이지'
                            ? const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            )
                            : null,
                  ),
                  label: item.label,
                ),
              )
              .toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFFA6A6A6),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11.0,
        height: 1.4,
        letterSpacing: 11.0 * -0.025,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 11.0,
        height: 1.4,
        letterSpacing: 11.0 * -0.025,
      ),
    );
  }
}

class NavItem {
  final String route;
  final String label;
  final String icon;
  final String activeIcon;

  NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
