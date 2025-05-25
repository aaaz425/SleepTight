import 'package:flutter/material.dart';
import 'package:sleep_tight/core/config/theme/color.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final String theme; // default, gray, text, outline
  final bool disabled;
  final Widget? icon;
  final String? text;
  final TextStyle? textStyle;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.height,
    this.text,
    this.disabled = false,
    this.width,
    this.theme = 'default',
    this.icon,
    this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = disabled || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ButtonStyle(
          // remove default padding to fit narrow buttons
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return _getDisabledStyle(theme).bgColor;
            } else if (states.contains(WidgetState.pressed)) {
              return _getPressedStyle(theme).bgColor;
            }
            return _getDefaultStyle(theme).bgColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return textColor ?? _getDisabledStyle(theme).textColor;
            } else if (states.contains(WidgetState.pressed)) {
              return textColor ?? _getPressedStyle(theme).textColor;
            }
            return textColor ?? _getDefaultStyle(theme).textColor;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final vals =
                states.contains(WidgetState.disabled)
                    ? _getDisabledStyle(theme)
                    : states.contains(WidgetState.pressed)
                    ? _getPressedStyle(theme)
                    : _getDefaultStyle(theme);
            return theme == 'outline'
                ? BorderSide(color: vals.borderColor, width: 1)
                : BorderSide.none;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.pressed)
                ? _getPressedStyle(theme).bgColor
                : Colors.transparent;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon!,
            if (icon != null && text != null) SizedBox(width: 4),
            if (text != null)
              Text(
                text!,
                style:
                    textStyle ??
                    TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600, // semibold
                      fontSize: 16,
                      height: 1.4, // 140%
                      letterSpacing: -0.4, // -2.5% of 16 = -0.4
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

// 스타일 값 보관용
class _ButtonStyleValues {
  final Color bgColor, textColor, borderColor;
  const _ButtonStyleValues(this.bgColor, this.textColor, this.borderColor);
}

// 비활성화 스타일
_ButtonStyleValues _getDisabledStyle(String theme) {
  switch (theme) {
    case 'outline':
      return const _ButtonStyleValues(
        Colors.transparent,
        AppColors.font3,
        AppColors.gray05,
      );
    case 'text':
      return const _ButtonStyleValues(
        Colors.transparent,
        AppColors.font3,
        Colors.transparent,
      );
    case 'gray':
      return _ButtonStyleValues(
        AppColors.white.withValues(alpha: 0.02),
        AppColors.font3,
        Colors.transparent,
      );
    default:
      return const _ButtonStyleValues(
        AppColors.gray04,
        AppColors.font3,
        Colors.transparent,
      );
  }
}

// 기본 스타일
_ButtonStyleValues _getDefaultStyle(String theme) {
  switch (theme) {
    case 'gray':
      return _ButtonStyleValues(
        AppColors.white.withValues(alpha: 0.06),
        AppColors.primaryHv,
        Colors.transparent,
      );
    case 'outline':
      return const _ButtonStyleValues(
        Colors.transparent,
        AppColors.primaryHv,
        AppColors.gray06,
      );
    case 'text':
      return const _ButtonStyleValues(
        Colors.transparent,
        AppColors.primaryHv,
        Colors.transparent,
      );
    default:
      return const _ButtonStyleValues(
        AppColors.primary,
        AppColors.white,
        Colors.transparent,
      );
  }
}

// 눌림(pressed) 스타일
_ButtonStyleValues _getPressedStyle(String theme) {
  switch (theme) {
    case 'gray':
      return _ButtonStyleValues(
        AppColors.white.withValues(alpha: 0.1),
        AppColors.primaryHv2,
        Colors.transparent,
      );
    case 'outline':
      return _ButtonStyleValues(
        Color(0xFF87A8FF).withValues(alpha: 0.04),
        AppColors.primaryHv2,
        AppColors.gray06,
      );
    case 'text':
      return _ButtonStyleValues(
        Color(0xFF87A8FF).withValues(alpha: 0.04),
        AppColors.primaryHv2,
        Colors.transparent,
      );
    default:
      return _ButtonStyleValues(
        AppColors.primaryHv,
        AppColors.white,
        Colors.transparent,
      );
  }
}
