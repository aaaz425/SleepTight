import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/home_screen.dart';
import 'package:app/features/auth/presentation/screens/placeholder_screen.dart';
import 'package:app/features/auth/presentation/widgets/shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/models/enums/auth_status.dart';
import 'app_config.dart';

// goRouterProvider를 Provider.family로 변경하고 GlobalKey<NavigatorState>를 인자로 받도록 수정합니다.
final goRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((
  ref,
  navigatorKey,
) {
  // AuthNotifier를 watch하여 인증 상태 변경 시 GoRouter가 재빌드되고 redirect 로직이 재실행되도록 함
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: navigatorKey, // 전달받은 navigatorKey를 GoRouter에 설정합니다.
    initialLocation: AppConfig.routes.welcome, // 초기 시작 지점
    debugLogDiagnostics: true, // 개발 중 로그 확인에 유용
    // redirect 로직: 인증 상태 및 현재 경로에 따라 적절한 페이지로 리다이렉션
    redirect: (BuildContext context, GoRouterState state) {
      final currentAuthStatus = authState.status;
      final location = state.matchedLocation; // 현재 이동하려는 경로 (정규화된 경로)

      // 1. 비로그인 사용자 (AuthStatus.guest)
      if (currentAuthStatus == AuthStatus.guest) {
        // '/welcome' 경로가 아니면 해당 경로로 보냄
        return location == AppConfig.routes.welcome
            ? null
            : AppConfig.routes.welcome;
      }

      // 2. 임시가입 사용자 (AuthStatus.incomplete_registration)
      final unauthenticatedAllowedPaths = [
        AppConfig.routes.appInit,
        AppConfig.routes.signUp,
      ];
      if (currentAuthStatus == AuthStatus.incompleteRegistration) {
        if (unauthenticatedAllowedPaths.contains(location)) {
          return null; // 허용된 경로면 그대로 진행
        }
        // 비인증 상태에서 허용되지 않은 경로 접근 시 '/signup'으로
        return AppConfig.routes.signUp;
      }

      // 3. 탈퇴보류 사용자 (AuthStatus.pending_withdraw)
      final pendingWithdrawAllowedPaths = [
        AppConfig.routes.appInit,
        AppConfig.routes.sayGoodbye,
      ];
      if (currentAuthStatus == AuthStatus.pendingWithdraw) {
        if (pendingWithdrawAllowedPaths.contains(location)) {
          return null; // 허용된 경로면 그대로 진행
        }
        // '/app-init', '/say-goodbye' 경로가 아니면 해당 경로로 보냄
        return AppConfig
            .routes
            .appInit; // 스플래시 화면이 끝나고 권한검사를 할때 복구를 할건지 말건지 confirm
      }

      // 4. 인증된 상태 (AuthStatus.active)
      if (currentAuthStatus == AuthStatus.active) {
        // 인증된 사용자가 회원가입, 온보딩, 웰컴 스플래시 화면으로 가려고 할 때 메인 화면('/home')으로 리다이렉트
        final disallowedPathsForAuthenticated = [
          AppConfig.routes.welcome,
          AppConfig.routes.signUp,
          AppConfig.routes.onboarding,
        ];
        if (disallowedPathsForAuthenticated.contains(location)) {
          return AppConfig.routes.home; // 메인 화면 (홈)
        }
      }

      return null; // 그 외의 경우는 리다이렉션 없음
    },

    routes: <RouteBase>[
      // --- 초기 및 인증 관련 라우트 ---
      GoRoute(
        path: AppConfig.routes.welcome,
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Before Login Splash'),
            ),
      ),
      GoRoute(
        path: AppConfig.routes.appInit, // 로그인 직후 데이터 로딩 등에 사용 가능
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'After Login Splash'),
            ),
      ),
      GoRoute(
        path: AppConfig.routes.signUp,
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Signup'),
            ),
      ),
      GoRoute(
        path: AppConfig.routes.onboarding,
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Onboarding'),
            ),
      ),
      GoRoute(
        path: AppConfig.routes.sayGoodbye, // 회원 탈퇴 후 안내 페이지
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: PlaceholderScreen(title: 'Say Goodbye'),
            ),
      ),

      // --- 메인 애플리케이션 라우트 (Shell 사용) ---
      // 기존에 정의된 ShellScreen을 활용한 라우트들
      GoRoute(
        path: AppConfig.routes.home, // 홈
        name: 'home', // 라우트에 이름을 부여하는 것이 좋습니다.
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: ShellScreen(body: HomeScreen()),
            ), // '/home' 경로의 기본 본문
        routes: <RouteBase>[
          // '/home' 경로 아래에 중첩될 라우트들
          GoRoute(
            path: 'sleeping', // 상대 경로이므로 '/home/sleeping'이 됩니다.
            name: 'home-sleeping',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: ShellScreen(
                    // 부모와 동일한 ShellScreen을 사용
                    body: PlaceholderScreen(title: 'Sleeping Mode'), // 본문만 교체
                  ),
                ),
          ),
          GoRoute(
            path: 'alarm-ringing', // 상대 경로이므로 '/home/alarm-ringing'이 됩니다.
            name: 'home-alarm-ringing',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: ShellScreen(
                    // 부모와 동일한 ShellScreen을 사용
                    body: PlaceholderScreen(title: 'Alarm Ringing!'), // 본문만 교체
                  ),
                ),
          ),
        ],
      ),

      GoRoute(
        path: AppConfig.routes.sleepAnalysis, // 수면분석
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: ShellScreen(
                body: PlaceholderScreen(title: 'Sleep Analysis'),
              ),
            ),
      ),
      GoRoute(
        path: AppConfig.routes.sleepCoach, // 수면코치
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: ShellScreen(body: PlaceholderScreen(title: 'Sleep Coach')),
            ),
      ),
      GoRoute(
        path: AppConfig.routes.sound, // 사운드
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: ShellScreen(body: PlaceholderScreen(title: 'Sound')),
            ),
      ),

      // --- 마이페이지 및 하위 라우트 ---
      // 마이페이지는 자체 Shell을 가질 수도 있고, 메인 Shell 내의 컨텐츠일 수도 있습니다.
      // 여기서는 메인 Shell 내의 컨텐츠로 가정하고 중첩 GoRoute를 사용합니다.
      // 만약 마이페이지가 별도의 BottomNavigationBar 등을 가진다면 ShellRoute 사용을 고려합니다.
      GoRoute(
        path: AppConfig.routes.mypage, // 마이페이지
        name: 'mypage', // 이름 지정 권장
        // 마이페이지 기본 화면은 ShellScreen 내에 표시
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: ShellScreen(body: PlaceholderScreen(title: 'MyPage Main')),
            ),
        routes: <RouteBase>[
          GoRoute(
            path: 'info', // 상대 경로: /mypage/info
            name: 'mypage-info',
            // pageBuilder를 사용하면 부모의 ShellScreen이 적용되지 않을 수 있으므로,
            // builder를 사용하고 컨텐츠만 교체하거나, MyPage 자체를 ShellRoute로 만들어야 함.
            // 여기서는 간단히 builder 사용. ShellScreen을 계속 사용하려면 MyPage 자체를 ShellRoute로 고려.
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(title: 'MyPage Info'),
                ), // 또는 MyPageInfoScreen()
            routes: <RouteBase>[
              GoRoute(
                path: 'name', // /mypage/info/name
                name: 'mypage-info-name',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(title: 'Info - Name'),
                    ),
              ),
              GoRoute(
                path: 'gender', // /mypage/info/gender
                name: 'mypage-info-gender',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(title: 'Info - Gender'),
                    ),
              ),
              GoRoute(
                path: 'nationality', // /mypage/info/nationality
                name: 'mypage-info-nationality',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(title: 'Info - Nationality'),
                    ),
              ),
              GoRoute(
                path: 'oauth', // /mypage/info/oauth
                name: 'mypage-info-oauth',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(
                        title: 'Info - OAuth Connections',
                      ),
                    ),
              ),
              GoRoute(
                path: 'logout', // /mypage/info/logout (로그아웃 확인 페이지)
                name: 'mypage-info-logout',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(title: 'Info - Logout Confirm'),
                    ),
              ),
              GoRoute(
                path: 'withdraw', // /mypage/info/withdraw (회원 탈퇴 페이지)
                name: 'mypage-info-withdraw',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(
                        title: 'Info - Withdraw Account',
                      ),
                    ),
              ),
            ],
          ),
          GoRoute(
            path: 'body', // /mypage/body
            name: 'mypage-body',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(title: 'MyPage Body Info'),
                ),
            routes: <RouteBase>[
              GoRoute(
                path: 'height', // /mypage/body/height
                name: 'mypage-body-height',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(title: 'Body - Height'),
                    ),
              ),
              GoRoute(
                path: 'weight', // /mypage/body/weight
                name: 'mypage-body-weight',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: PlaceholderScreen(title: 'Body - Weight'),
                    ),
              ),
            ],
          ),
          GoRoute(
            path: 'sleep-time', // /mypage/sleep-time
            name: 'mypage-sleep-time',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(title: 'MyPage Sleep Time Settings'),
                ),
          ),
          GoRoute(
            path: 'push', // /mypage/push
            name: 'mypage-push',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'MyPage Push Notification Settings',
                  ),
                ),
          ),
          GoRoute(
            path: 'app-info', // /mypage/app-info
            name: 'mypage-app-info',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(title: 'MyPage App Info'),
                ),
          ),
        ],
      ),
    ],
  );
});
