// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SvgPicture.asset 사용을 위해 추가

// --- Placeholder Screens (실제 화면으로 교체 필요) ---
enum AuthStatus {
  guest, // 비로그인 사용자
  incomplete_registration, // 임시 가입자
  active, // 정상 회원
  pending_withdraw, // 탈퇴 보류
}

class AuthState {
  final AuthStatus status;
  // final User? user; // 사용자 정보 (선택 사항)
  // final bool isLoading; // 로딩 상태 (선택 사항)

  AuthState({required this.status /*, this.user, this.isLoading = false*/});

  // 편의를 위한 팩토리 생성자 및 게터
  factory AuthState.initial() => AuthState(status: AuthStatus.guest);
  bool get isTemporaryRegistered =>
      status == AuthStatus.incomplete_registration;
  bool get isActiveUser => status == AuthStatus.active;
  bool get isPendingWithDrawUser => status == AuthStatus.pending_withdraw;
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(title)),
  );
}

// 기존 ShellScreen 및 HomeScreen (예시)
class ShellScreen extends StatelessWidget {
  final Widget body;
  final bool hasBottomNav;

  const ShellScreen({super.key, required this.body, this.hasBottomNav = true});

  // 현재 경로에 따라 BottomNavigationBar의 선택된 인덱스를 계산하는 함수
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/sleep-analysis')) {
      return 1;
    }
    if (location.startsWith('/sleep-coach')) {
      return 2;
    }
    if (location.startsWith('/sound')) {
      return 3;
    }
    if (location.startsWith('/mypage')) {
      return 4;
    }
    return 0; // 기본값 (예: 홈)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/sleep-analysis');
        break;
      case 2:
        GoRouter.of(context).go('/sleep-coach');
        break;
      case 3:
        GoRouter.of(context).go('/sound');
        break;
      case 4:
        GoRouter.of(context).go('/mypage');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar:
          hasBottomNav
              ? Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed, // 4개 이상일 때 아이템 고정을 위해 필요
                  backgroundColor: const Color(0xFF121212),
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/icons/home_outlined.svg',
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFA6A6A6),
                          BlendMode.srcIn,
                        ),
                      ),
                      activeIcon: SvgPicture.asset(
                        'assets/icons/home_solid.svg',
                      ),
                      label: '홈',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/icons/analysis_outlined.svg',
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFA6A6A6),
                          BlendMode.srcIn,
                        ),
                      ),
                      activeIcon: SvgPicture.asset(
                        'assets/icons/analysis_solid.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: '수면분석',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/icons/bot_outlined.svg',
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFA6A6A6),
                          BlendMode.srcIn,
                        ),
                      ),
                      activeIcon: SvgPicture.asset(
                        'assets/icons/bot_solid.svg',
                      ),
                      label: '수면코치',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/icons/headphone_outlined.svg',
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFA6A6A6),
                          BlendMode.srcIn,
                        ),
                      ),
                      activeIcon: SvgPicture.asset(
                        'assets/icons/headphone_solid.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: '사운드',
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset(
                        'assets/icons/mypage_outlined.svg',
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFA6A6A6),
                          BlendMode.srcIn,
                        ),
                      ),
                      activeIcon: SvgPicture.asset(
                        'assets/icons/mypage_solid.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: '마이페이지',
                    ),
                  ],
                  currentIndex: _calculateSelectedIndex(context),
                  onTap: (index) => _onItemTapped(index, context),
                  selectedItemColor: Colors.white,
                  unselectedItemColor: const Color(0xFFA6A6A6),
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600, // Semi-bold
                    fontSize: 11.0,
                    height: 1.4,
                    letterSpacing: 11.0 * -0.025,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w300, // Light
                    fontSize: 11.0,
                    height: 1.4,
                    letterSpacing: 11.0 * -0.025,
                  ),
                ),
              )
              : null,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(title: 'Home');
}
// --- End Placeholder Screens ---

// goRouterProvider를 Provider.family로 변경하고 GlobalKey<NavigatorState>를 인자로 받도록 수정합니다.
final goRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((ref, navigatorKey) {
  // AuthNotifier를 watch하여 인증 상태 변경 시 GoRouter가 재빌드되고 redirect 로직이 재실행되도록 함
  // final authState = ref.watch(authNotifierProvider);
  final authState = AuthState(status: AuthStatus.active);

  return GoRouter(
    navigatorKey: navigatorKey, // 전달받은 navigatorKey를 GoRouter에 설정합니다.
    initialLocation: '/welcome', // 초기 시작 지점
    debugLogDiagnostics: true, // 개발 중 로그 확인에 유용
    // redirect 로직: 인증 상태 및 현재 경로에 따라 적절한 페이지로 리다이렉션
    redirect: (BuildContext context, GoRouterState state) {
      final currentAuthStatus = authState.status;
      final location = state.matchedLocation; // 현재 이동하려는 경로 (정규화된 경로)

      // 1. 비로그인 사용자 (AuthStatus.guest)
      if (currentAuthStatus == AuthStatus.guest) {
        // '/welcome' 경로가 아니면 해당 경로로 보냄
        return location == '/welcome' ? null : '/welcome';
      }

      // 2. 임시가입 사용자 (AuthStatus.incomplete_registration)
      final unauthenticatedAllowedPaths = ['/app-init', '/signup'];
      if (currentAuthStatus == AuthStatus.incomplete_registration) {
        if (unauthenticatedAllowedPaths.contains(location)) {
          return null; // 허용된 경로면 그대로 진행
        }
        // 비인증 상태에서 허용되지 않은 경로 접근 시 '/signup'으로
        return '/signup';
      }

      // 3. 탈퇴보류 사용자 (AuthStatus.pending_withdraw)
      final pendingWithdrawAllowedPaths = ['/app-init', '/say-goodbye'];
      if (currentAuthStatus == AuthStatus.pending_withdraw) {
        if (pendingWithdrawAllowedPaths.contains(location)) {
          return null; // 허용된 경로면 그대로 진행
        }
        // '/app-init', '/say-goodbye' 경로가 아니면 해당 경로로 보냄
        return '/app-init'; // 스플래시 화면이 끝나고 권한검사를 할때 복구를 할건지 말건지 confirm
      }

      // 4. 인증된 상태 (AuthStatus.active)
      if (currentAuthStatus == AuthStatus.active) {
        // 인증된 사용자가 회원가입, 온보딩, 웰컴 스플래시 화면으로 가려고 할 때 메인 화면('/home')으로 리다이렉트
        final disallowedPathsForAuthenticated = [
          '/welcome',
          '/signup',
          '/onboarding',
        ];
        if (disallowedPathsForAuthenticated.contains(location)) {
          return '/home'; // 메인 화면 (홈)
        }
      }

      return null; // 그 외의 경우는 리다이렉션 없음
    },

    routes: <RouteBase>[
      // --- 초기 및 인증 관련 라우트 ---
      GoRoute(
        path: '/welcome',
        builder:
            (context, state) =>
                const PlaceholderScreen(title: 'Before Login Splash'),
      ),
      GoRoute(
        path: '/app-init', // 로그인 직후 데이터 로딩 등에 사용 가능
        builder:
            (context, state) =>
                const PlaceholderScreen(title: 'After Login Splash'),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const PlaceholderScreen(title: 'Signup'),
      ),
      GoRoute(
        path: '/onboarding',
        builder:
            (context, state) => const PlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        path: '/say-goodbye', // 회원 탈퇴 후 안내 페이지
        builder:
            (context, state) => const PlaceholderScreen(title: 'Say Goodbye'),
      ),

      // --- 메인 애플리케이션 라우트 (Shell 사용) ---
      // 기존에 정의된 ShellScreen을 활용한 라우트들
      GoRoute(
        path: '/home', // 홈
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
                    // hasBottomNav: true, // ShellScreen의 기본값 (true) 사용
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
                    // hasBottomNav: true, // ShellScreen의 기본값 (true) 사용
                  ),
                ),
          ),
        ],
      ),

      GoRoute(
        path: '/sleep-analysis', // 수면분석
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: ShellScreen(
                body: PlaceholderScreen(title: 'Sleep Analysis'),
              ),
            ),
      ),
      GoRoute(
        path: '/sleep-coach', // 수면코치
        pageBuilder:
            (context, state) => const NoTransitionPage(
              child: ShellScreen(body: PlaceholderScreen(title: 'Sleep Coach')),
            ),
      ),
      GoRoute(
        path: '/sound', // 사운드
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
        path: '/mypage', // 마이페이지
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
            builder:
                (context, state) => const PlaceholderScreen(
                  title: 'MyPage Info',
                ), // 또는 MyPageInfoScreen()
            routes: <RouteBase>[
              GoRoute(
                path: 'name', // /mypage/info/name
                name: 'mypage-info-name',
                builder:
                    (context, state) =>
                        const PlaceholderScreen(title: 'Info - Name'),
              ),
              GoRoute(
                path: 'gender', // /mypage/info/gender
                name: 'mypage-info-gender',
                builder:
                    (context, state) =>
                        const PlaceholderScreen(title: 'Info - Gender'),
              ),
              GoRoute(
                path: 'nationality', // /mypage/info/nationality
                name: 'mypage-info-nationality',
                builder:
                    (context, state) =>
                        const PlaceholderScreen(title: 'Info - Nationality'),
              ),
              GoRoute(
                path: 'oauth', // /mypage/info/oauth
                name: 'mypage-info-oauth',
                builder:
                    (context, state) => const PlaceholderScreen(
                      title: 'Info - OAuth Connections',
                    ),
              ),
              GoRoute(
                path: 'logout', // /mypage/info/logout (로그아웃 확인 페이지)
                name: 'mypage-info-logout',
                builder:
                    (context, state) =>
                        const PlaceholderScreen(title: 'Info - Logout Confirm'),
              ),
              GoRoute(
                path: 'withdraw', // /mypage/info/withdraw (회원 탈퇴 페이지)
                name: 'mypage-info-withdraw',
                builder:
                    (context, state) => const PlaceholderScreen(
                      title: 'Info - Withdraw Account',
                    ),
              ),
            ],
          ),
          GoRoute(
            path: 'body', // /mypage/body
            name: 'mypage-body',
            builder:
                (context, state) =>
                    const PlaceholderScreen(title: 'MyPage Body Info'),
            routes: <RouteBase>[
              GoRoute(
                path: 'height', // /mypage/body/height
                name: 'mypage-body-height',
                builder:
                    (context, state) =>
                        const PlaceholderScreen(title: 'Body - Height'),
              ),
              GoRoute(
                path: 'weight', // /mypage/body/weight
                name: 'mypage-body-weight',
                builder:
                    (context, state) =>
                        const PlaceholderScreen(title: 'Body - Weight'),
              ),
            ],
          ),
          GoRoute(
            path: 'sleep-time', // /mypage/sleep-time
            name: 'mypage-sleep-time',
            builder:
                (context, state) => const PlaceholderScreen(
                  title: 'MyPage Sleep Time Settings',
                ),
          ),
          GoRoute(
            path: 'push', // /mypage/push
            name: 'mypage-push',
            builder:
                (context, state) => const PlaceholderScreen(
                  title: 'MyPage Push Notification Settings',
                ),
          ),
          GoRoute(
            path: 'app-info', // /mypage/app-info
            name: 'mypage-app-info',
            builder:
                (context, state) =>
                    const PlaceholderScreen(title: 'MyPage App Info'),
          ),
        ],
      ),
    ],
  );
});
