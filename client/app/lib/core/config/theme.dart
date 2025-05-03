import 'package:flutter/material.dart';

// Todo: 디자인 시스템 완성될 시 수정
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(28, 28, 30, 1)),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(28, 28, 30, 1),
      foregroundColor: Colors.white,
    ),
  );
}
