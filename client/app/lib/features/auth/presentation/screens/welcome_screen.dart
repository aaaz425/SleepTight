import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/auth/presentation/providers/auth_provider.dart';
import 'package:sleep_tight/features/auth/presentation/widgets/login_button.dart';
import 'package:sleep_tight/features/user/data/models/enums/auth_status.dart';
import 'package:sleep_tight/features/user/presentation/providers/user_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  double _titleOpacity = 0;
  double _opacity = 0;

  // 추가: 로고 애니메이션 관련 변수
  int _currentLogoIndex = -1;
  late final List<String> _logoPaths;
  Timer? _logoTimer;

  @override
  void initState() {
    super.initState();

    // 1. 유저 상태에 따라 라우팅 또는 타이틀 애니메이션
    Future.delayed(const Duration(milliseconds: 2200), () {
      setState(() {
        _titleOpacity = 1;
      });

      // 타이틀 애니메이션이 끝난 뒤(예: 1000ms 후) 라우팅 실행
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        // 1. provider의 notifier를 읽어서
        final userModel = ref.read(userModelProvider.notifier);
        userModel.loadUser(); // 조회

        // 3. 현재 상태가 pendingWithdraw일 때만 모달 띄우기
        final status = userModel.getStatus();
        if (status == AuthStatus.pendingWithdraw) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: const Color(0xFF353436), // 이미지와 비슷한 다크톤
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '탈퇴 진행 중',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '회원 탈퇴가 진행 중입니다.\n복구에 동의하시겠습니까?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            TextButton(
                              onPressed: () {
                                // userModelNotifier.setStatus(AuthStatus.active);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '확인',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          );
        }

        if (status == AuthStatus.guest) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            setState(() {
              _opacity = 1;
            });
          });
        }
      });
    });

    // 3. 로고 애니메이션
    _logoPaths = [
      'assets/images/sleeptight_logo_00.svg',
      'assets/images/sleeptight_logo_01.svg',
      'assets/images/sleeptight_logo_02.svg',
    ];
    _logoTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        if (_currentLogoIndex < _logoPaths.length - 1) {
          _currentLogoIndex++;
        } else {
          _logoTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _logoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.gray00),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: List.generate(_logoPaths.length, (idx) {
                    return AnimatedOpacity(
                      opacity: _currentLogoIndex < idx ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: SvgPicture.asset(
                        _logoPaths[idx],
                        width: 120,
                        height: 126,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: _titleOpacity,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeIn,
                  child: Text(
                    'SLEEP TIGHT',
                    style: TextStyle(
                      fontFamily: 'Teko',
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: AppColors.primary,
                      letterSpacing: -0.48,
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                // 페이드 인 부분 시작
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeIn,
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.4,
                            letterSpacing: -0.4,
                            color: Color(0xFFCCCCCC),
                          ),
                          children: [
                            TextSpan(text: '수면 '),
                            TextSpan(
                              text: '패턴 분석',
                              style: TextStyle(color: AppColors.primaryHv),
                            ),
                            TextSpan(text: '과 수면 '),
                            TextSpan(
                              text: '코칭',
                              style: TextStyle(color: AppColors.primaryHv),
                            ),
                            TextSpan(text: '을 한번에!'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 63),
                      LoginButton(
                        onPressed: () async {
                          await kakaoLoginProcess(ref, context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> kakaoLoginProcess(WidgetRef ref, BuildContext context) async {
  OAuthToken? token;
  try {
    // 카카오톡 설치 여부 확인
    final isInstalled = await isKakaoTalkInstalled();
    if (isInstalled) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
      } on PlatformException catch (e) {
        debugPrint('카카오톡으로 로그인 실패 $e');
        if (e.code == 'CANCELED') {
          // 사용자가 로그인 취소
          debugPrint('로그인 취소');
        } else {
          // 카카오톡에 연결된 계정 없음 등 기타 에러는 아래에서 카카오계정 로그인 시도
          try {
            token = await UserApi.instance.loginWithKakaoAccount();
          } catch (e) {
            debugPrint('카카오계정으로 로그인 실패 $e');
          }
        }
      } catch (e) {
        debugPrint('카카오톡으로 로그인 실패 $e');
        // 기타 예외 발생 시에도 카카오계정 로그인 시도
        try {
          token = await UserApi.instance.loginWithKakaoAccount();
        } catch (e) {
          debugPrint('카카오계정으로 로그인 실패 $e');
        }
      }
    } else {
      // 카카오톡 미설치 시 카카오계정 로그인
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
      } catch (e) {
        debugPrint('카카오계정으로 로그인 실패 $e');
      }
    }
  } catch (e) {
    debugPrint('카카오 로그인 전체 프로세스 실패: $e');
  }

  if (token != null) {
    // 1. 로그인 및 토큰 저장 (status도 반환받는다고 가정)
    await ref.read(authRepositoryProvider).loginWithKakao(token.accessToken);

    // 2. 유저 정보 fetch
    await ref.read(userRepositoryProvider).getUserInfo();

    // 3. userModelProvider의 상태 갱신
    // ref.read(userModelProvider.notifier).updateFromResponse(userInfo);
  }
}
