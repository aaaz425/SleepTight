import 'package:flutter/material.dart';

class AppColors {
  // 시스템 색상
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const gray00 = Color(0xFF121212);
  static const gray01 = Color(0xFF1C1C1E);
  static const gray02 = Color(0xFF2C2C2E);
  static const gray03 = Color(0xFF3A3A3C);
  static const gray04 = Color(0xFF48484A);
  static const gray05 = Color(0xFF636366);
  static const gray06 = Color(0xFFA6A6A6);
  static const gray07 = Color(0xFFDCDDEB);

  static const red = Color(0xFFFF453A);
  static const orange = Color(0xFFFF9F0A);
  static const yellow = Color(0xFFFFD60A);
  static const green = Color(0xFF30D158);
  static const teal = Color(0xFF64D2FF);
  static const blue = Color(0xFF0A84FF);
  static const indigo = Color(0xFF7675D7);
  static const purple = Color(0xFFBF5AF2);
  static const pink = Color(0xFFFF2D55);

  static const accessibleRed = Color(0xFFFF6961);
  static const accessibleOrange = Color(0xFFFFB340);
  static const accessibleYellow = Color(0xFFFFD426);
  static const accessibleGreen = Color(0xFF30DB5B);
  static const accessibleTeal = Color(0xFF70D7FF);
  static const accessibleBlue = Color(0xFF409CFF);
  static const accessibleIndigo = Color(0xFF7D7AFF);
  static const accessiblePurple = Color(0xFFDA8FFF);
  static const accessiblePink = Color(0xFFFF6482);

  // 상태 색상
  static const warning = Color(0xFFFF5959);
  static const success = Color(0xFF61CB6B);
  static const caution = Color(0xFFFFD153);

  // 브랜드 색상
  static const primary = Color(0xFF1A4FFF);
  static const primaryVr = Color(0xFF153FCC);
  static const primaryHv = Color(0xFF3A6EFF);
  static const primaryHv2 = Color(0xFF7EA6FF);
  static const sub1 = Color(0xFF7A6FF0);
  static const sub1Vr = Color(0xFF4032D4);
  static const sub2 = Color(0xFF3AAD85);
  static const sub2Vr = Color(0xFF248B67);
  static const linearGradient = LinearGradient(
    colors: [Color(0xFF3A6EFF), Color(0xFF1339CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const linearGradient2 = LinearGradient(
    colors: [Color(0xFF7EA6FF), Color(0xFF1A4FFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const linearGradient3 = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF000000), Color(0xFF1C1C1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 폰트 색상
  static const font1 = Color(0xDEFFFFFF);
  static const font2 = Color(0x99FFFFFF);
  static const font3 = Color(0x4DFFFFFF);

  // 라인 색상
  static const lineLight = Color(0xFFEEEEEE);
  static const lineRegular = Color(0xFF515151);
  static const lineDark = Color(0xFF404040);

  // 배경 색상
  static const bgLight = Color(0xFF383838);
  static const bgRegular = Color(0xFF2D2D2D);
  static const bgDark = Color(0xFF222222);
}
