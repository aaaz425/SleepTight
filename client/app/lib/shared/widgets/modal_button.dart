import 'package:flutter/material.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';

class ModalButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const ModalButton({
    super.key,
    required this.text,
    this.textStyle,
    this.onPressed,
    this.width = 60.0,
    this.height = 34.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = AppTextStyles.button3Md(
      color: AppColors.font1,
    );

    // textStyle이 null이 아니고 color도 지정되어 있다면 해당 색상 사용, 아니면 기본 텍스트 색상 사용
    final Color effectiveTextColor =
        textStyle?.color ?? defaultTextStyle.color!;

    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: padding,
          minimumSize: Size(width, height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          foregroundColor: effectiveTextColor, // 텍스트 및 아이콘 기본 색상
        ).copyWith(
          // overlayColor는 ButtonStyle의 일부이므로, styleFrom() 내부 또는 copyWith() 내부에서
          // MaterialStateProperty (또는 WidgetStateProperty)를 사용해야 합니다.
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            // WidgetStateProperty도 가능
            (Set<WidgetState> states) {
              // Flutter 3.13+ 에서는 Set<WidgetState>
              if (states.contains(WidgetState.pressed)) {
                // WidgetState.pressed
                return effectiveTextColor.withValues(
                  alpha: 0.12,
                ); // 눌렀을 때 텍스트 색상 기반의 약한 오버레이
              }
              if (states.contains(WidgetState.hovered)) {
                // WidgetState.hovered
                return effectiveTextColor.withValues(
                  alpha: 0.08,
                ); // 호버 시 약한 오버레이
              }
              return null; // 기본값 (효과 없음)
            },
          ),
          visualDensity: VisualDensity.compact,
        ),
        child: Text(text, style: textStyle ?? defaultTextStyle),
      ),
    );
  }
}
