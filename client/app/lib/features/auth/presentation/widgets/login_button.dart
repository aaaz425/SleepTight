import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.text = '카카오로 로그인',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 아이콘 (이미지 경로에 맞게 수정)
            SvgPicture.asset(
              'assets/images/kakao_logo.svg',
              width: 20,
              height: 20,
            ),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.gray00,
              ),
            ),
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: SvgPicture.asset(
                'assets/images/kakao_logo.svg',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
