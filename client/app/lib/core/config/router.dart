import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/sleep_mode/presentation/screens/home_screen.dart';
import '../../shared/widgets/shell_screen.dart';

// Todo: 라우팅 설정
final appRouter = GoRouter(
  routes: [
    // Memo: 홈 화면
    GoRoute(
      path: '/',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: ShellScreen(body: HomeScreen())),
    ),
    GoRoute(
      path: '/sleeping',
      pageBuilder:
          (BuildContext context, GoRouterState state) => const NoTransitionPage(
            child: ShellScreen(hasBottomNav: false, body: HomeScreen()),
          ),
    ),
    GoRoute(
      path: '/ringing',
      pageBuilder:
          (BuildContext context, GoRouterState state) => const NoTransitionPage(
            child: ShellScreen(
              hasPlayer: false,
              hasBottomNav: false,
              body: HomeScreen(),
            ),
          ),
    ),
    GoRoute(
      path: '/wake_up',
      pageBuilder:
          (BuildContext context, GoRouterState state) => const NoTransitionPage(
            child: ShellScreen(
              hasPlayer: false,
              hasBottomNav: false,
              body: HomeScreen(),
            ),
          ),
    ),

    GoRoute(
      path: '/analysis',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: ShellScreen(body: HomeScreen())),
    ),
    GoRoute(
      path: '/coach',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: ShellScreen(body: HomeScreen())),
    ),
    GoRoute(
      path: '/sound',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: ShellScreen(body: HomeScreen())),
    ),
    GoRoute(
      path: '/mypage',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: ShellScreen(body: HomeScreen())),
    ),
  ],
);
