import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String name;
  final String? label;
  final String hintText;
  final TextInputType? keyboardType;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextAlign? textAlign;

  const CustomTextField({
    super.key,
    required this.name,
    this.label,
    required this.hintText,
    this.keyboardType,
    this.initialValue,
    this.focusNode,
    this.validator,
    this.textAlign,
  });

  InputDecoration _inputDecoration(String? label) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyB2Rg(color: AppColors.font2),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      filled: true,
      fillColor: Colors.transparent,
      isDense: true,
      isCollapsed: false,
      errorMaxLines: 1, // 0은 허용되지 않음
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray05, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray05, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray07, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.warning, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.warning, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      errorStyle: TextStyle(fontSize: 0, height: 0, color: AppColors.warning),
      hoverColor: const Color(0x0AFFFFFF),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final bool isFocused = focusNode?.hasFocus ?? false;

        final formState = FormBuilder.of(context);
        final isFieldValid = formState?.fields[name]?.isValid ?? true;
        final errorText = formState?.fields[name]?.errorText;

        bool isValid = isFieldValid;
        String? currentErrorText = errorText;

        TextStyle textStyle;

        // 입력 중이거나 입력이 완료되고 유효성 검사가 통과된 경우 semibold 사용
        if (isFocused ||
            (formState != null &&
                formState.fields[name] != null &&
                formState.fields[name]!.value != null &&
                formState.fields[name]!.value.toString().isNotEmpty &&
                isValid)) {
          textStyle = AppTextStyles.bodyB2Sb(color: AppColors.white);
        } else {
          textStyle = AppTextStyles.bodyB2Rg(color: AppColors.font2);
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null && label!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  label!,
                  style: AppTextStyles.bodyB4Lt(color: AppColors.font1),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: name,
                  focusNode: focusNode,
                  initialValue: initialValue,
                  keyboardType: keyboardType,
                  style: textStyle,
                  decoration: _inputDecoration(label),
                  validator: validator,
                  textAlign: textAlign ?? TextAlign.start,
                  onChanged: (value) {
                    final validatorFn = validator;

                    if (validatorFn != null) {
                      final error = validatorFn(value);
                      setState(() {
                        isValid = error == null;
                        currentErrorText = error;
                      });
                    }
                  },
                ),
                if (!isValid &&
                    currentErrorText != null &&
                    currentErrorText!.isNotEmpty)
                  SizedBox(
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        currentErrorText!,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(height: 20),
              ],
            ),
          ],
        );
      },
    );
  }
}
