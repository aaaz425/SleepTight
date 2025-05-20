import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:group_button/group_button.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';

class CustomRadioGroup<T> extends FormBuilderField<T> {
  final List<T> options;
  final List<String> labels;
  final Color selectedColor;
  final Color unselectedColor;
  final Color borderColor;
  final TextStyle? _selectedTextStyle;
  final TextStyle? _unselectedTextStyle;
  final Axis direction;

  TextStyle get selectedTextStyle =>
      _selectedTextStyle ?? AppTextStyles.bodyB2Sb(color: Colors.white);
  TextStyle get unselectedTextStyle =>
      _unselectedTextStyle ?? AppTextStyles.bodyB2Rg(color: AppColors.font2);

  CustomRadioGroup({
    super.key,
    required super.name,
    super.validator,
    super.initialValue,
    required this.options,
    required this.labels,
    this.selectedColor = AppColors.primary,
    this.unselectedColor = Colors.transparent,
    this.borderColor = AppColors.gray06,
    TextStyle? selectedTextStyle,
    TextStyle? unselectedTextStyle,
    this.direction = Axis.horizontal,
    super.enabled = true,
  }) : _selectedTextStyle = selectedTextStyle,
       _unselectedTextStyle = unselectedTextStyle,
       super(
         builder: (FormFieldState<T?> field) {
           return Focus(
             canRequestFocus: false,
             skipTraversal: true,
             child: _CustomRadioGroupBody<T>(
               field: field,
               options: options,
               labels: labels,
               selectedColor: selectedColor,
               unselectedColor: unselectedColor,
               borderColor: borderColor,
               selectedTextStyle:
                   selectedTextStyle ??
                   AppTextStyles.bodyB2Sb(color: Colors.white),
               unselectedTextStyle:
                   unselectedTextStyle ??
                   AppTextStyles.bodyB2Rg(color: AppColors.font2),
               enabled: enabled,
               direction: direction,
             ),
           );
         },
       );
}

class _CustomRadioGroupBody<T> extends StatelessWidget {
  final FormFieldState<T?> field;
  final List<T> options;
  final List<String> labels;
  final Color selectedColor;
  final Color unselectedColor;
  final Color borderColor;
  final TextStyle selectedTextStyle;
  final TextStyle unselectedTextStyle;
  final bool enabled;
  final Axis direction;

  const _CustomRadioGroupBody({
    required this.field,
    required this.options,
    required this.labels,
    required this.selectedColor,
    required this.unselectedColor,
    required this.borderColor,
    required this.selectedTextStyle,
    required this.unselectedTextStyle,
    required this.enabled,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 값에 해당하는 인덱스 찾기
    int selectedIndex = -1;
    if (field.value != null) {
      selectedIndex = options.indexOf(field.value as T);
    } else if (labels.isNotEmpty) {
      selectedIndex = 0;
    }

    final groupButtonWidget = GroupButton<String>(
      isRadio: true,
      onSelected: (String value, int index, bool selected) {
        if (selected) {
          // 라디오 선택 시 포커스 해제 및 새로운 포커스 노드 요청
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FocusScope.of(context).requestFocus(FocusNode());
          });
          field.didChange(options[index]);
        }
      },
      buttons: labels,
      controller: GroupButtonController(selectedIndex: selectedIndex),
      buttonBuilder: (selected, value, context) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? selectedColor : unselectedColor,
                  border: Border.all(
                    color: selected ? selectedColor : borderColor,
                    width: 1.0,
                  ),
                ),
                child:
                    selected
                        ? Center(
                          child: Container(
                            height: 5,
                            width: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.5),
              child: Text(
                value,
                style: selected ? selectedTextStyle : unselectedTextStyle,
              ),
            ),
          ],
        );
      },
      options: GroupButtonOptions(
        spacing: direction == Axis.horizontal ? 20 : 4,
        runSpacing: 0,
        direction: direction,
        selectedShadow: const [],
        unselectedShadow: const [],
        selectedColor: Colors.transparent,
        unselectedColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        unselectedBorderColor: Colors.transparent,
        mainGroupAlignment: MainGroupAlignment.start,
        crossGroupAlignment: CrossGroupAlignment.start,
        groupingType: GroupingType.wrap,
        alignment: Alignment.centerLeft,
        elevation: 0,
      ),
    );

    final errorWidget =
        field.hasError
            ? Padding(
              padding: EdgeInsets.only(
                left: direction == Axis.horizontal ? 6 : 0,
                top: direction == Axis.vertical ? 6 : 0,
              ),
              child: Text(
                field.errorText!,
                style: AppTextStyles.bodyB4Lt(color: AppColors.warning),
              ),
            )
            : const SizedBox.shrink();

    if (direction == Axis.horizontal) {
      return Row(children: [groupButtonWidget, errorWidget]);
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [groupButtonWidget, errorWidget],
        ),
      );
    }
  }
}
