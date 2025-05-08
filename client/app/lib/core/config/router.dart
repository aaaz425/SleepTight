import 'package:app/features/sleep_mode/presentation/screens/home_screen.dart';
import 'package:app/features/sleep_mode/presentation/screens/sleeping_screen.dart';
import 'package:app/shared/widgets/shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Todo: 라우팅 설정
final appRouter = GoRouter(
  initialLocation: '/',

  // Memo: 인증 정보 바뀔 시 새로고침 -> deprecated 되었으니, 커스텀 필요
  // refreshListenable: GoRouterRefreshStream(
  //   ref.watch(authProvider.notifier).stream,
  // ),

  // Memo: 로그인 여부 확인하여 로그인 페이지로 보냄, 가입 대기 여부 로직도 추가 해야함
  // redirect: (context, state) {
  //   final isLoggedIn = ref.read(authProvider);

  //   if (!isLoggedIn) {
  //     return '/login';
  //   }

  //   if (isLoggedIn) {
  //     return '/'; // 로그인한 유저가 /login 가면 홈으로
  //   }

  //   return null;
  // },
  routes: [
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
            child: ShellScreen(hasBottomNav: false, body: SleepingScreen()),
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
