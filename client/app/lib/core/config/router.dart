import 'package:sleep_tight/features/analysis/presentation/screens/analysis_screen.dart';
import 'package:sleep_tight/features/auth/presentation/screens/placeholder_screen.dart';
import 'package:sleep_tight/features/auth/presentation/screens/welcome_screen.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_birthdate_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_withdraw_confirmation_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/signup_screen.dart';
import 'package:sleep_tight/shared/widgets/shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/user/data/models/enums/auth_status.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/screens/home_screen.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/screens/sleeping_screen.dart';

import 'app_config.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_name_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_gender_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_nationality_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_oauth_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_logout_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_info_withdraw_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_body_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_body_height_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_body_weight_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_sleeptime_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_push_screen.dart';
import 'package:sleep_tight/features/user/presentation/screens/my_page_appinfo_screen.dart';

// goRouterProvider를 Provider.family로 변경하고 GlobalKey<NavigatorState>를 인자로 받도록 수정합니다.
final goRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((
  ref,
  navigatorKey,
) {
  // 1. userModelProvider에서 status만 선택하여 감시하는 새로운 Listenable을 만듭니다.
  //    ValueNotifier를 사용하거나 Riverpod의 select와 listen을 조합할 수 있습니다.
  final authStatusNotifier = ValueNotifier<AuthStatus?>(
    ref.watch(userModelProvider.select((model) => model?.status)), // 초기값 설정
  );

  // userModelProvider의 status가 변경될 때마다 authStatusNotifier의 값을 업데이트합니다.
  ref.listen<AuthStatus?>(userModelProvider.select((model) => model?.status), (
    previousStatus,
    newStatus,
  ) {
    authStatusNotifier.value = newStatus;
  });

  return GoRouter(
    navigatorKey: navigatorKey, // 전달받은 navigatorKey를 GoRouter에 설정합니다.
    initialLocation: AppConfig.routes.welcome, // 초기 시작 지점
    debugLogDiagnostics: true, // 개발 중 로그 확인에 유용
    refreshListenable: authStatusNotifier, // status 변경만 감지하도록 설정
    // redirect 로직: 인증 상태 및 현재 경로에 따라 적절한 페이지로 리다이렉션
    redirect: (BuildContext context, GoRouterState state) {
      final currentAuthStatus = authStatusNotifier.value ?? AuthStatus.guest;
      // 또는 final currentAuthStatus = ref.read(userModelProvider)?.status ?? AuthStatus.guest;

      final location = state.matchedLocation;
      // 여기에 userModel?.status 대신 currentAuthStatus를 사용하도록 로그 수정
      debugPrint(
        'GoRouter Redirect: status=$currentAuthStatus, location=$location',
      );

      // 1. 비로그인 사용자 (AuthStatus.guest)
      if (currentAuthStatus == AuthStatus.guest) {
        // '/welcome' 경로가 아니면 해당 경로로 보냄
        return location == AppConfig.routes.welcome
            ? null
            : AppConfig.routes.welcome;
      }

      // 2. 임시가입 사용자 (AuthStatus.incomplete_registration)
      final unauthenticatedAllowedPaths = [AppConfig.routes.signUp];
      if (currentAuthStatus == AuthStatus.incompleteRegistration) {
        if (unauthenticatedAllowedPaths.contains(location)) {
          return null; // 허용된 경로면 그대로 진행
        }
        // 비인증 상태에서 허용되지 않은 경로 접근 시 '/signup'으로
        return AppConfig.routes.signUp;
      }

      // 3. 탈퇴보류 사용자 (AuthStatus.pending_withdraw)
      final pendingWithdrawAllowedPaths = [
        AppConfig.routes.welcome,
        AppConfig.routes.sayGoodbye,
      ];
      if (currentAuthStatus == AuthStatus.pendingWithdraw) {
        if (pendingWithdrawAllowedPaths.contains(location)) {
          return null; // 허용된 경로면 그대로 진행
        }
        // '/app-init', '/say-goodbye' 경로가 아니면 해당 경로로 보냄
        return AppConfig
            .routes
            .welcome; // 스플래시 화면이 끝나고 권한검사를 할때 복구를 할건지 말건지 confirm
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
        return null;
      }

      return null; // 그 외의 경우는 리다이렉션 없음
    },

    routes: <RouteBase>[
      // --- 초기 및 인증 관련 라우트 ---
      GoRoute(
        path: AppConfig.routes.welcome,
        pageBuilder:
            (context, state) => const NoTransitionPage(child: WelcomeScreen()),
      ),
      GoRoute(
        path: AppConfig.routes.signUp,
        pageBuilder:
            (context, state) => const NoTransitionPage(child: SignupScreen()),
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
                    body: SleepingScreen(), // 본문만 교체
                    hasBottomNav: false,
                  ),
                ),
          ),
        ],
      ),

      GoRoute(
        path: AppConfig.routes.sleepAnalysis, // 수면 분석
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final tabIndex = (tabParam == 'diary') ? 1 : 0;

          return NoTransitionPage(
            child: ShellScreen(body: AnalysisScreen(initialTabIndex: tabIndex)),
          );
        },
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
              child: ShellScreen(body: MyPageScreen()),
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
                  child: ShellScreen(body: MyPageInfoScreen()),
                ),
            routes: <RouteBase>[
              GoRoute(
                path: 'name', // /mypage/info/name
                name: 'mypage-info-name',
                pageBuilder:
                    (context, state) => NoTransitionPage(
                      child: ShellScreen(body: MyPageInfoNameScreen()),
                    ),
              ),
              GoRoute(
                path: 'birth-date', // /mypage/info/birth-date
                name: 'mypage-info-birth-date',
                pageBuilder:
                    (context, state) => NoTransitionPage(
                      child: ShellScreen(body: MyPageInfoBirthDateScreen()),
                    ),
              ),
              GoRoute(
                path: 'gender', // /mypage/info/gender
                name: 'mypage-info-gender',
                pageBuilder:
                    (context, state) => NoTransitionPage(
                      child: ShellScreen(body: MyPageInfoGenderScreen()),
                    ),
              ),
              GoRoute(
                path: 'nationality', // /mypage/info/nationality
                name: 'mypage-info-nationality',
                pageBuilder:
                    (context, state) => NoTransitionPage(
                      child: ShellScreen(body: MyPageInfoNationalityScreen()),
                    ),
              ),
              GoRoute(
                path: 'oauth', // /mypage/info/oauth
                name: 'mypage-info-oauth',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: ShellScreen(body: MyPageInfoOauthScreen()),
                    ),
              ),
              GoRoute(
                path: 'logout', // /mypage/info/logout (로그아웃 확인 페이지)
                name: 'mypage-info-logout',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: ShellScreen(body: MyPageInfoLogoutScreen()),
                    ),
              ),
              GoRoute(
                path: 'withdraw', // /mypage/info/withdraw (회원 탈퇴 페이지)
                name: 'mypage-info-withdraw',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: ShellScreen(body: MyPageInfoWithdrawScreen()),
                    ),
              ),
              GoRoute(
                path:
                    'withdraw-confirmation', // “/mypage/info/withdraw-confirmation”
                name: 'mypage-info-withdraw-confirmation',
                pageBuilder:
                    (context, state) => const NoTransitionPage(
                      child: MyPageInfoWithdrawConfirmationScreen(),
                    ),
              ),
            ],
          ),
          GoRoute(
            path: 'body', // /mypage/body
            name: 'mypage-body',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: ShellScreen(body: MyPageBodyScreen()),
                ),
            routes: <RouteBase>[
              GoRoute(
                path: 'height', // /mypage/body/height
                name: 'mypage-body-height',
                pageBuilder:
                    (context, state) => NoTransitionPage(
                      child: ShellScreen(body: MyPageBodyHeightScreen()),
                    ),
              ),
              GoRoute(
                path: 'weight', // /mypage/body/weight
                name: 'mypage-body-weight',
                pageBuilder:
                    (context, state) => NoTransitionPage(
                      child: ShellScreen(body: MyPageBodyWeightScreen()),
                    ),
              ),
            ],
          ),
          GoRoute(
            path: 'sleep-time', // /mypage/sleep-time
            name: 'mypage-sleep-time',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: ShellScreen(body: MyPageSleeptimeScreen()),
                ),
          ),
          GoRoute(
            path: 'push', // /mypage/push
            name: 'mypage-push',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: ShellScreen(body: MyPagePushScreen()),
                ),
          ),
          GoRoute(
            path: 'app-info', // /mypage/app-info
            name: 'mypage-app-info',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: ShellScreen(body: MyPageAppInfoScreen()),
                ),
          ),
        ],
      ),
    ],
  );
});
