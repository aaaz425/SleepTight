import 'package:flutter/material.dart';

/// 전체 화면을 덮는 일반 다이얼로그를 띄우는 헬퍼 함수
Future<void> showOverlay({
  required BuildContext context,
  required Widget child,

  // 필요시 필수인자로 변경
  bool barrierDismissible = false,
  Color barrierColor = const Color.fromRGBO(0, 0, 0, 0.5),
  Duration transitionDuration = const Duration(milliseconds: 300),
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return child;
    },
  );
}
