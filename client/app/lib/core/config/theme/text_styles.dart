import 'package:flutter/material.dart';

class AppTextStyles {
  // Title/T3_Sb
  static TextStyle titleT3Sb({required Color color}) => TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600, // semibold
    fontSize: 16,
    height: 1.4, // 140%
    letterSpacing: -0.4, // -2.5% of 16 = -0.4
    color: color,
  );

  // Body/B4_Lt
  static TextStyle bodyB4Lt({required Color color}) => TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w300, // light
    fontSize: 12,
    height: 1.4, // 140%
    letterSpacing: -0.3, // -2.5% of 12 = -0.3
    color: color,
  );

  // Body/B2_Rg
  static TextStyle bodyB2Rg({required Color color}) => TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400, // regular
    fontSize: 14,
    height: 1.4, // 140%
    letterSpacing: -0.4, // -2.5% of 14 = -0.4
    color: color,
  );

  // Body/B2_Sb
  static TextStyle bodyB2Sb({required Color color}) => TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600, // semibold
    fontSize: 14,
    height: 1.4, // 140%
    letterSpacing: -0.4, // -2.5% of 14 = -0.4
    color: color,
  );

  // Button1/Sb
  static TextStyle button1Sb({required Color color}) => TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600, // semibold
    fontSize: 16,
    height: 1.4, // 140%
    letterSpacing: -0.4, // -2.5% of 16 = -0.4
    color: color,
  );
}
