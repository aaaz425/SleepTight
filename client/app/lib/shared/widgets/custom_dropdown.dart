import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatelessWidget {
  final String name;
  final String? initialValue;
  final List<String> values;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const CustomDropdown({
    super.key,
    required this.name,
    this.initialValue,
    required this.values,
    this.hintText = '선택',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: name,
      // hintText를 표시하기 위해 기본값 없이 initialValue만 사용
      initialValue: initialValue,
      validator: validator,
      builder: (field) {
        bool isOpen = false;
        return Focus(
          canRequestFocus: false,
          skipTraversal: true,
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        field.hasError
                            ? AppColors.warning
                            : isOpen
                            ? AppColors.white
                            : AppColors.gray05,
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      hintText,
                      style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
                    ),
                    value: field.value,
                    items:
                        values
                            .map(
                              (val) => DropdownMenuItem<String>(
                                value: val,
                                child: Text(
                                  val,
                                  style:
                                      val == field.value
                                          ? AppTextStyles.bodyB2Sb(
                                            color: AppColors.white,
                                          )
                                          : AppTextStyles.bodyB2Rg(
                                            color: AppColors.font2,
                                          ),
                                ),
                              ),
                            )
                            .toList(),
                    selectedItemBuilder:
                        (context) =>
                            values.map((val) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  val,
                                  style: AppTextStyles.bodyB2Sb(
                                    color: AppColors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                    onChanged: (value) {
                      // 드롭다운 선택한 뒤 포커스 클리어
                      FocusScope.of(context).unfocus();
                      // 필요시 기존 로직 실행
                      field.didChange(value);
                    },
                    onMenuStateChange: (open) {
                      setLocalState(() => isOpen = open);
                      if (!isOpen) {
                        // 드롭다운이 닫힌 직후(포스트 프레임)에 전역 포커스 해제
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      }
                    },
                    iconStyleData: IconStyleData(
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SvgPicture.asset(
                          isOpen
                              ? 'assets/icons/chevron_up.svg'
                              : 'assets/icons/chevron_down.svg',
                        ),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 192,
                      decoration: BoxDecoration(
                        color: AppColors.gray03,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.white,
                            spreadRadius: 1,
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      offset: Offset(0, -4), // menu margin from button
                    ),
                    buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.zero,
                      height: 48,
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.focused) ||
                            states.contains(WidgetState.pressed)) {
                          return AppColors.gray04;
                        }
                        return null;
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
