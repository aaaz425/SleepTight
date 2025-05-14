import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/auth/presentation/widgets/login_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _titleOpacity = 0;
  double _opacity = 0;

  // 추가: 로고 애니메이션 관련 변수
  int _currentLogoIndex = -1;
  late final List<String> _logoPaths;
  Timer? _logoTimer;

  @override
  void initState() {
    super.initState();

    // 2200ms 후 텍스트 opacity 변경
    // 또는 /home으로 이동
    Future.delayed(const Duration(milliseconds: 2200), () {
      setState(() {
        _titleOpacity = 1;
      });
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      setState(() {
        _opacity = 1;
      });
    });

    // 로고 이미지 경로 리스트
    _logoPaths = [
      'assets/images/sleeptight_logo_00.svg',
      'assets/images/sleeptight_logo_01.svg',
      'assets/images/sleeptight_logo_02.svg',
    ];
    // 600ms마다 인덱스 변경
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
                        onPressed: () {
                          debugPrint('카카오로 로그인');
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
