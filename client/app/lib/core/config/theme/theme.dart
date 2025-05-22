import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color.dart';

// Todo: 디자인 시스템 완성될 시 수정
class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'Pretendard',
    useMaterial3: true,
    // Memo: 기본 배경 설정
    scaffoldBackgroundColor: AppColors.gray01,
    // Memo: Material 스플래쉬 효과 제거
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    // Memo: 컬러 스키마 설정
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: Color(0x0FFFFFFF),
      onSecondary: AppColors.primaryHv,
      error: AppColors.warning,
      onError: AppColors.font1,
      surface: AppColors.gray01,
      onSurface: AppColors.font1,
    ),
    // Memo: 앱 바 스타일 설정
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.gray01,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    // Memo: 하단 네비게이션 바 설정
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.gray00,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.gray06,
      type: BottomNavigationBarType.fixed,
    ),
    // Memo: 텍스트 스타일 설정
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.white),
      bodyMedium: TextStyle(color: AppColors.font1),
    ),
  );
}
